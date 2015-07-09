//
//  PhotoDetailViewController.m
//  Photopography
//
//  Created by Alex on 2015-07-07.
//  Copyright (c) 2015 Daniel Hooper. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "APIKey.h"

@interface PhotoDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *photoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoLocationLabel;
@property (strong, nonatomic) UIImage *photoImage;

@end

@implementation PhotoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.photoTitleLabel.text= self.photo.photoTitle;
    self.photoLocationLabel.text = [NSString stringWithFormat:@"%@, %@", self.photo.photoCity, self.photo.photoCountry];
    [self loadPhoto];
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

- (IBAction)saveButtonPressed:(id)sender {
     UIImageWriteToSavedPhotosAlbum(self.photoImage, nil, nil, nil);
}

@end
