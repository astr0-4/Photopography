//
//  PhotoDetailViewController.m
//  Photopography
//
//  Created by Alex on 2015-07-07.
//  Copyright (c) 2015 Daniel Hooper. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "APIKey.h"

@interface PhotoDetailViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *photoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoLocationLabel;
@property (strong, nonatomic) UIImage *photoImage;


@end

@implementation PhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 2.0;
    //self.scrollView.zoomScale = 0.1;
    self.scrollView.contentSize = self.photoImageView.frame.size;
    self.scrollView.delegate = self;
    
    self.photoTitleLabel.text= self.photo.photoTitle;
    self.photoLocationLabel.text = [NSString stringWithFormat:@"%@, %@", self.photo.photoCity, self.photo.photoCountry];
    [self loadPhoto];
}

-(void)viewDidAppear:(BOOL)animated {

    
//    [self.scrollView zoomToRect:self.photoImageView.frame animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadPhoto {
    NSString *imageString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_b.jpg", self.photo.farm, self.photo.server, self.photo.photoID, self.photo.secret];
    NSURL *imageURL = [NSURL URLWithString:imageString];
    NSLog(@"%@", imageURL);
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:imageURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        self.photoImage = [[UIImage alloc] initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoImageView.image = self.photoImage;
        });
    }];
    [task resume];
}

-(NSURL *)photoURL {
    NSString *imageString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_b.jpg", self.photo.farm, self.photo.server, self.photo.photoID, self.photo.secret];
    NSURL *imageURL = [NSURL URLWithString:imageString];
    return imageURL;
}


- (IBAction)saveButtonPressed:(id)sender {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:@"Check out the photo in %@, coordinates: %f, %f", self.photo.photoCity, self.photo.userLocation.longitude, self.photo.userLocation.latitude],[self photoURL]] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoImageView;
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
}

                                                        
                                                        
@end
