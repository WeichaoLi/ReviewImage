//
//  ReviewImageViewController.h
//  ReviewImage
//
//  Created by 李伟超 on 14-10-27.
//  Copyright (c) 2014年 LWC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewImageViewController : UIViewController<UIGestureRecognizerDelegate,UIScrollViewDelegate> {
    UIScrollView *_reviewImageView;
    UIImageView *_ImageView;
    UIToolbar *_toolBar;
}

@property (nonatomic, retain) NSURL *url;

@end
