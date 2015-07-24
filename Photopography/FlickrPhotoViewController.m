//
//  FlickrPhotoViewController.m
//
//
//  Created by Alex on 2015-07-04.
//
//

#import "FlickrPhotoViewController.h"
#include "APIKey.h"
#import "FlickrPhotoCell.h"
#import "GraphViewController.h"


@interface FlickrPhotoViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL isLoading;

//@property (assign, nonatomic) INTULocationRequestID locationRequestID;

@end

@implementation FlickrPhotoViewController

#pragma mark loadPhotos from Flickr

- (void)getPhotoDetails:(Photo *)photo {
    NSString *photoInfoString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1", API_KEY, photo.photoID];
    NSURL *photoInfoURL = [NSURL URLWithString:photoInfoString];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:photoInfoURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        NSDictionary *photoInfo = resultDict[@"photo"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            photo.photoTitle = [[photoInfo objectForKey:@"title"] objectForKey:@"_content"];
            photo.photographer = [[photoInfo objectForKey:@"owner"] objectForKey:@"realname"];
            photo.photoCity = [[[photoInfo objectForKey:@"location"] objectForKey:@"locality"] objectForKey:@"_content"];
            photo.photoCountry = [[[photoInfo objectForKey:@"location"] objectForKey:@"country"] objectForKey:@"_content"];
            NSString *dateString = [[photoInfo objectForKey:@"dates"] objectForKey:@"taken"];
            photo.photoDate = [self convertStringtoDateObject:dateString];
            [self.collectionView reloadData];
        });
    }];
    
    [task resume];
}

- (void)loadPhotos {
    self.isLoading = YES;
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&has_geo=1&lat=%f&lon=%f&radius=0.1&format=json&nojsoncallback=1", API_KEY, self.latitude, self.longitude];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"url: %@ ", url);
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        NSDictionary *photosDict = [resultDict objectForKey:@"photos"];
        NSArray *photosArray = [photosDict objectForKey:@"photo"];
        
        if(!photosDict) {
            NSLog(@"there was an error! %@", error);
        } else {
            
            // change core data to background thread later!!!!
            dispatch_async(dispatch_get_main_queue(), ^{
                Location *location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
                location.latitude = self.latitude;
                location.longitude = self.longitude;
                
                for(NSDictionary *flickrDict in photosArray) {
                    
                    Photo *photo = [self addPhotoWithID:[flickrDict objectForKey:@"id"]];
                    photo.farm = [NSString stringWithFormat: @"%@", [flickrDict objectForKey:@"farm"]];
                    photo.secret = [flickrDict objectForKey:@"secret"];
                    photo.server = [flickrDict objectForKey:@"server"];
                    photo.userLocation = location;
                    
                    [self getPhotoDetails:photo];
                    
                }
                self.isLoading = NO;
                [self.collectionView reloadData];
            });
        }
    }];
    
    [task resume];
}

-(Photo *)addPhotoWithID:(NSString *)photoID {
    Photo *photo = [self photoWithID:photoID];
    
    if(!photo) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
        photo.photoID = photoID;
    }
    return photo;
    
    //    NSError *error = nil;
    //    if (![self.managedObjectContext save:&error]) {
    //        // Replace this implementation with code to handle the error appropriately.
    //        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    //        abort();
    //    }
}

//-(void)addLocation {
//
//    self.userLocation.latitude = self.latitude;
//    self.userLocation.longitude = self.longitude;
//}


-(Photo *)photoWithID:(NSString *)photoID {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"photoID == %@", photoID];
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    Photo *foundPhoto = [results firstObject];
    
    return foundPhoto;
}


- (void)viewDidLoad {
    self.isLoading = NO;
    [super viewDidLoad];
    [self loadPhotos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FlickrPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    [self getAndConfigurePhotoImage:indexPath forCell:cell];
//    [self configurePhotoDetails:indexPath forCell:cell];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showPhotoDetail" sender:self];
}

#pragma mark getPhotoImages and getPhotoDetails

-(void)getAndConfigurePhotoImage:(NSIndexPath *)indexPath forCell:(FlickrPhotoCell *)cell {
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (!photo.photoImage) {
        [cell.photoTask cancel];
        
        cell.photoImageView.image = nil;
    
        NSString *imageString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_b.jpg", photo.farm, photo.server, photo.photoID, photo.secret];
        NSURL *imageURL = [NSURL URLWithString:imageString];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            UIImage *myImage = [[UIImage alloc] initWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                photo.photoImage = myImage;
                cell.photoImageView.image = myImage;
            });
        }];
        cell.photoTask = task;
        [task resume];
    }
    else {
        cell.photoImageView.image = photo.photoImage;
    }
}

//-(void)configurePhotoDetails:(NSIndexPath *)indexPath forCell:(FlickrPhotoCell *)cell {
//    
//    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    
//    cell.photographerLabel.text = photo.photographer;
//    cell.titleLabel.text = photo.photoTitle;
//}



#pragma mark set the inset on the photo view

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(100, 0, 100, 0);
}

#pragma mark FetchedResultsController
// create NSFetchedResultsController in our view controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // Initialize Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Photo"];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Add Sort Descriptors
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"photoDate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    // Initialize Fetched Results Controller
    const float rangeValue = 0.0005;
    NSNumber *minLatitude = [NSNumber numberWithDouble:(self.latitude - rangeValue)];
    NSNumber *maxLatitude = [NSNumber numberWithDouble:(self.latitude + rangeValue)];
    NSNumber *minLongitude = [NSNumber numberWithDouble:(self.longitude - rangeValue)];
    NSNumber *maxLongitude = [NSNumber numberWithDouble:(self.longitude + rangeValue)];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userLocation.latitude > %@) AND (userLocation.latitude < %@) AND (userLocation.longitude > %@) AND (userLocation.longitude < %@)", minLatitude,maxLatitude, minLongitude, maxLongitude];
    [fetchRequest setPredicate:predicate];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    // Configure Fetched Results Controller
    [_fetchedResultsController setDelegate:self];
    
    // Perform Fetch
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    return _fetchedResultsController;
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if(!self.isLoading) {
    //[self.collectionView reloadData];
    }
}

#pragma mark dateFormatter
// We want to format the date string into an NSDate object that Core Data can use as a sort descriptor

-(NSDate *)convertStringtoDateObject:(NSString *)dateString {
    static NSDateFormatter *dateFormatter = nil;
    if (nil == dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [dateFormatter dateFromString:dateString];
        return date;
    }
    else {
        NSDate *date = [dateFormatter dateFromString:dateString];
        return date;
    }
}

#pragma prepareForSegue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"showPhotoDetail"]){
        PhotoDetailViewController *photoDetailViewController = (PhotoDetailViewController *)segue.destinationViewController;
        photoDetailViewController.managedObjectContext = self.managedObjectContext;
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        photoDetailViewController.photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        photoDetailViewController.location = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
    }
    
    if ([segue.identifier isEqualToString:@"showGraph"]){
        GraphViewController *graphViewController = (GraphViewController *)segue.destinationViewController;
        graphViewController.longitude = self.longitude;
        graphViewController.latitude = self.latitude;
    }
}

@end