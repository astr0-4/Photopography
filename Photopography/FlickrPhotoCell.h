//
//  FlickrPhotoCell.h
//  FlickrGetter
//
//  Created by Alex on 2015-07-04.
//  Copyright (c) 2015 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrPhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *photographerLabel;

@end
