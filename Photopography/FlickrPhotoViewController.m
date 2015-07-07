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

@interface FlickrPhotoViewController ()
@property (assign, nonatomic) INTULocationRequestID locationRequestID;
@end

@implementation FlickrPhotoViewController

- (void)loadPhotos {
    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&has_geo=1&lat=%f&lon=%f&radius=0.1&format=json&nojsoncallback=1", API_KEY, self.latitude, self.longitude];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@"url: %@ ", url);
    
    NSLog(@"latitude: %f , longitude: %f", self.latitude, self.longitude);
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        NSDictionary *photosDict = [resultDict objectForKey:@"photos"];
        NSArray *photosArray = [photosDict objectForKey:@"photo"];
        
        if(!photosDict) {
            NSLog(@"there was an error! %@", error);
        } else {
            NSMutableArray *photosTemp = [NSMutableArray array];
            
            for(NSDictionary *flickrDict in photosArray) {
                Photo *photo = [[Photo alloc] init];
                photo.farm = [flickrDict objectForKey:@"farm"];
                photo.photoID = [flickrDict objectForKey:@"id"];
                photo.secret = [flickrDict objectForKey:@"secret"];
                photo.server = [flickrDict objectForKey:@"server"];
                [photosTemp addObject:photo];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.photoObjects = [photosTemp mutableCopy];
                [self.collectionView reloadData];
                NSLog(@"photo object %@", [self.photoObjects firstObject]);
                
            });
        }
    }];
    
    [task resume];
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
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.photoObjects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FlickrPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    [self getPhotoImage:indexPath forCell:cell];
    [self getPhotoDetails:indexPath forCell:cell];
    return cell;
}


-(void)getPhotoImage:(NSIndexPath *)indexPath forCell:(FlickrPhotoCell *)cell {
    [cell.photoTask cancel];
    cell.photoImageView.image = nil;
    Photo *photo = [self.photoObjects objectAtIndex:indexPath.row];
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

- (void)startSingleLocationRequest
{
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    self.locationRequestID = [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock
                                                                timeout:10
                                                                  block:
                              ^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                  
                                  if (status == INTULocationStatusSuccess) {
                                      self.longitude = currentLocation.coordinate.longitude;
                                      self.latitude = currentLocation.coordinate.latitude;
                                      NSLog (@"coordinate 1: %f, coordinate 2: %f\n", self.longitude, self.latitude);
                                      [self loadPhotos];
                                  }
                              }];
}

-(void)getPhotoDetails:(NSIndexPath *)indexPath forCell:(FlickrPhotoCell *)cell  {
    [cell.detailTask cancel];
    cell.titleLabel.text = nil;
    cell.photographerLabel.text = nil;
    Photo *photo = [self.photoObjects objectAtIndex:indexPath.row];
    NSString *photoInfoString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1", API_KEY, photo.photoID];
    NSURL *photoInfoURL = [NSURL URLWithString:photoInfoString];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:photoInfoURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        //for (NSString *dictKey in resultDict) {
            NSDictionary *photoInfo = resultDict[@"photo"];
            photo.photoTitle = [[photoInfo objectForKey:@"title"] objectForKey:@"_content"];
            photo.photographer = [[photoInfo objectForKey:@"owner"] objectForKey:@"realname"];
            photo.photoDate = [[photoInfo objectForKey:@"dates"] objectForKey:@"taken"];
        //}
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.photographerLabel.text = photo.photographer;
            cell.titleLabel.text = photo.photoTitle;
            cell.dateLabel.text = photo.photoDate;
            
        });
        

    }];
    cell.detailTask = task;
    [task resume];
    
}



- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(200, 0, 200, 0);
}
@end
