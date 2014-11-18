//
//  ReviewImageViewController.h
//  ReviewImage
//
//  Created by 李伟超 on 14-10-27.
//  Copyright (c) 2014年 LWC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ImageOrientation) {
    ImageOrientationPortrait = UIInterfaceOrientationPortrait,
    ImageOrientationLandScapeLeft = UIInterfaceOrientationLandscapeLeft,
    ImageOrientationLandScapeRight = UIInterfaceOrientationLandscapeRight,
    ImageOrientationPortraitUpsideDown = UIInterfaceOrientationPortraitUpsideDown,
};

@interface ReviewImageViewController : UIViewController<UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) NSString *ImageURL;
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) ImageOrientation imageOrientation;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, readonly) BOOL isViewing;

@end
