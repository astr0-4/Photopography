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

@end

@implementation FlickrPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&group_id=35034362597%%40N01&has_geo=1&lat=43.655704&lon=-79.380644&radius//=0.1&format=json&nojsoncallback=1", API_KEY];
       NSString *urlString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&has_geo=1&lat=43.655704&lon=-79.380644&radius=0.1&format=json&nojsoncallback=1", API_KEY];

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
    return cell;
}


-(void)getPhotoImage:(NSIndexPath *)indexPath forCell:(FlickrPhotoCell *)cell {
    [cell.task cancel];
    cell.photoImageView.image = nil;
    Photo *photo = [self.photoObjects objectAtIndex:indexPath.row];
    NSString *imageString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_z.jpg", photo.farm, photo.server, photo.photoID, photo.secret];
    NSURL *imageURL = [NSURL URLWithString:imageString];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        UIImage *myImage = [[UIImage alloc] initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.photoImageView.image = myImage;
        });
    }];
    cell.task = task;
    [task resume];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
