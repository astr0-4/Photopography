//
//  FlickrPhotoViewController.m
//  
//
//  Created by Alex on 2015-07-04.
//
//

#import "FlickrPhotoViewController.h"
#import "APIKey.h"
#import "FlickrPhotoCell.h"



@interface FlickrPhotoViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (assign, nonatomic) INTULocationRequestID locationRequestID;

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
            photo.photoLocation = [[photoInfo objectForKey:@"owner"] objectForKey:@"location"];
            NSString *dateString = [[photoInfo objectForKey:@"dates"] objectForKey:@"taken"];
            photo.photoDate = [self convertStringtoDateObject:dateString];
        });
    }];
    
    [task resume];
}

- (void)loadPhotos {
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&has_geo=1&lat=%f&lon=%f&radius=0.1&format=json&nojsoncallback=1", API_KEY, self.userLocation.latitude, self.userLocation.longitude];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"url: %@ ", url);
    
  //  NSLog(@"latitude: %f , longitude: %f", location.latitude, location.longitude);
    
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
                for(NSDictionary *flickrDict in photosArray) {
                    
                    Photo *photo = [self addPhotoWithID:[flickrDict objectForKey:@"id"]];
                    photo.farm = [NSString stringWithFormat: @"%@", [flickrDict objectForKey:@"farm"]];
                    photo.secret = [flickrDict objectForKey:@"secret"];
                    photo.server = [flickrDict objectForKey:@"server"];
                    photo.userLocation = self.userLocation;

                    [self getPhotoDetails:photo];
                }
                
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
}


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
    [super viewDidLoad];
    
    [self startSingleLocationRequest];
    
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
    [self configurePhotoDetails:indexPath forCell:cell];
    return cell;
}

#pragma mark getPhotoImages and getPhotoDetails

-(void)getAndConfigurePhotoImage:(NSIndexPath *)indexPath forCell:(FlickrPhotoCell *)cell {
    [cell.photoTask cancel];
    cell.photoImageView.image = nil;
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *imageString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_b.jpg", photo.farm, photo.server, photo.photoID, photo.secret];
    NSURL *imageURL = [NSURL URLWithString:imageString];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        UIImage *myImage = [[UIImage alloc] initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.photoImageView.image = myImage;
            
        });
    }];
    cell.photoTask = task;
    [task resume];
}

-(void)configurePhotoDetails:(NSIndexPath *)indexPath forCell:(FlickrPhotoCell *)cell {
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
        cell.photographerLabel.text = photo.photographer;
        cell.titleLabel.text = photo.photoTitle;


}

#pragma mark startSingleLocationRequest

- (void)startSingleLocationRequest {
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    self.locationRequestID = [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock
                                                                timeout:10
                                                                  block:
                              ^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                  
                                  if (status == INTULocationStatusSuccess) {
                                      self.userLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
                                      self.userLocation.latitude = currentLocation.coordinate.latitude;
                                      self.userLocation.longitude = currentLocation.coordinate.longitude;
                                      
                                      NSLog (@"coordinate 1: %f, coordinate 2: %f\n", self.userLocation.longitude, self.userLocation.latitude);
                                      [self loadPhotos];
                                  }
                              }];
}

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
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    
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
    [self.collectionView reloadData];
}

#pragma mark dateFormatter
//want to format the date string into an NSDate object that Core Data can use as a sort descriptor

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

@end
