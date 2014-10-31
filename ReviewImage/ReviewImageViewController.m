//
//  ReviewImageViewController.m
//  ReviewImage
//
//  Created by 李伟超 on 14-10-27.
//  Copyright (c) 2014年 LWC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ReviewImageViewController.h"

const CGFloat minScale = 1.f;
const CGFloat maxScale = 2.5f;

@interface ReviewImageViewController (){
    CGPoint _startPoint;
    CGPoint scaleCenter;
    CGPoint touchCenter;
    CGPoint rotationCenter;
    
    CGFloat _Scale;
    
    NSUInteger gestureCount;
    
    UILabel *promptLable;
}

@end

@implementation ReviewImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
//    NSLog(@"%@",NSStringFromCGRect(self.view.bounds));
    //单击
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    //双击
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesture:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.delegate = self;
    [self.view addGestureRecognizer:doubleTapGesture];
    
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture]; //要求双击时，单击failto 单击
    
    //拖动
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
//    [self.view addGestureRecognizer:panGesture];
    
    //旋转
//    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGesture:)];
//    [self.view addGestureRecognizer:rotationGesture];
    
    //捏合
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
    
    
    _Scale = minScale;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    [super loadView];
    
    //************* scrollview *******************************/
    
    _reviewImageView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _reviewImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _reviewImageView.bounces = YES;
    _reviewImageView.contentSize = CGSizeMake(self.view.frame.size.width + 1, self.view.frame.size.height + 1);
    _reviewImageView.directionalLockEnabled = NO;
    _reviewImageView.showsHorizontalScrollIndicator = YES;
    _reviewImageView.showsVerticalScrollIndicator = YES;
    _reviewImageView.decelerationRate = 0.1f;
    _reviewImageView.delaysContentTouches = YES;
    [self.view addSubview:_reviewImageView];
    
    //**************** ImageView *******************************/
    
    _ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _reviewImageView.frame.size.width, _reviewImageView.frame.size.height)];
//    _url = [[NSURL alloc] initWithString:@"http://www.jingan.gov.cn/newscenter/jobnews/201410/W020141024576266359059.jpg"];
//    NSData *data = [[NSData alloc] initWithContentsOfURL:_url];
//    _ImageView.image = [UIImage imageWithData:data];
    _ImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _ImageView.image = [UIImage imageNamed:@"5.png"];
    [_reviewImageView addSubview:_ImageView];
    
    //******************* toolbar *******************************/
    
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _toolBar.barStyle = self.navigationController.navigationBar.barStyle;
    [_toolBar setBackgroundImage:[UIImage imageNamed:@"clearBG.png"] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
    [_toolBar setShadowImage:[UIImage imageNamed:@"clearBG.png"] forToolbarPosition:UIBarPositionBottom];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *zoomOut = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zoomOut.png"] style:UIBarButtonItemStylePlain target:self action:@selector(zoomOut)];
    UIBarButtonItem *zoomIn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zoomIn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(zoomIn)];
    UIBarButtonItem *Save = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save.png"] style:UIBarButtonItemStylePlain target:self action:@selector(savePhoto)];
    UIBarButtonItem *leftRotate = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftRotation.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftRotation)];
    UIBarButtonItem *rightRotate = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rightRotation.png"] style:UIBarButtonItemStylePlain target:self action:@selector(rightRotation)];
    
    NSArray *Items = @[leftRotate,flexibleSpace,zoomOut,flexibleSpace,zoomIn,flexibleSpace,rightRotate,flexibleSpace,Save];
//    NSArray *Items = @[flexibleSpace,zoomOut,flexibleSpace,zoomIn,flexibleSpace,Save];
    [_toolBar setItems:Items animated:YES];
    [self.view insertSubview:_toolBar aboveSubview:_reviewImageView];
    
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"clearBG.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    [self adjustImageView];
    [self setContentInset];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"clearBG.png"] forBarMetrics:UIBarMetricsDefault];
}

- (void)setContentInset {

    CGRect frame = _ImageView.frame;
    
    if (frame.size.height < _reviewImageView.frame.size.height) {
        NSLog(@"图片高度小于视图的高度");
        
        frame.origin.y = (_reviewImageView.frame.size.height - frame.size.height)/2;
        _ImageView.frame = frame;
    }
    
    _reviewImageView.contentInset = UIEdgeInsetsMake(-frame.origin.y, -frame.origin.x, 0, 0);
    _reviewImageView.contentSize = CGSizeMake(frame.size.width - _reviewImageView.contentInset.left +1, frame.size.height - _reviewImageView.contentInset.top + 1);
    _reviewImageView.bounds = _reviewImageView.frame;
    
//    NSLog(@"\n%s \n contentsize: %@\n contentInset:%@\n\n",__func__, NSStringFromCGSize(_reviewImageView.contentSize),NSStringFromUIEdgeInsets(_reviewImageView.contentInset));
}

- (void)adjustImageView {
    CGRect frame = _ImageView.frame;
    
    if (frame.origin.x > 0) {
        NSLog(@"左");
        
        _ImageView.transform = CGAffineTransformTranslate(_ImageView.transform,  -_ImageView.frame.origin.x/_Scale, 0);
        
    }else if (frame.origin.x + frame.size.width < _reviewImageView.frame.size.width) {
        NSLog(@"右");
        _ImageView.transform = CGAffineTransformTranslate(_ImageView.transform,  (_reviewImageView.frame.size.width - frame.size.width - frame.origin.x)/_Scale, 0);
        
    }
    
    if (frame.size.height >= _reviewImageView.frame.size.height) {
        if (frame.origin.y > 0) {
            NSLog(@"上");
            _ImageView.transform = CGAffineTransformTranslate(_ImageView.transform,  0, -_ImageView.frame.origin.y/_Scale);
            
        }else if (frame.origin.y + frame.size.height < _reviewImageView.frame.size.height) {
            NSLog(@"下");
            _ImageView.transform = CGAffineTransformTranslate(_ImageView.transform,  0, (_reviewImageView.frame.size.height - frame.size.height - frame.origin.y)/_Scale);
        }
    }else {
        
    }
}

#pragma mark - toolBar method

//左转
- (void)leftRotation {
    
    CGFloat angle = - M_PI_2;
    _ImageView.transform = CGAffineTransformRotate(_ImageView.transform, angle);
    
    if (_ImageView.transform.b != 0) {
        CGRect frame = _reviewImageView.frame;
        CGFloat rotationScale = frame.size.width/frame.size.height;
        _ImageView.transform = CGAffineTransformScale(_ImageView.transform, rotationScale, rotationScale);
        _Scale = rotationScale;
    }else {
        _ImageView.transform = CGAffineTransformScale(_ImageView.transform, minScale/_Scale, minScale/_Scale);
    }
    
    NSLog(@"%@",NSStringFromCGRect(_ImageView.frame));
    [self adjustImageView];
    NSLog(@"%@",NSStringFromCGRect(_ImageView.frame));
    [self setContentInset];
    NSLog(@"%@\n\n",NSStringFromCGRect(_ImageView.frame));
}

//右转
- (void)rightRotation {
    _ImageView.transform = CGAffineTransformRotate(_ImageView.transform, M_PI_2);
    
    if (_ImageView.transform.b != 0) {
        CGRect frame = _reviewImageView.frame;
        CGFloat rotationScale = frame.size.width/frame.size.height;
        _ImageView.transform = CGAffineTransformScale(_ImageView.transform, rotationScale, rotationScale);
        _Scale = rotationScale;
    }else {
        _ImageView.transform = CGAffineTransformScale(_ImageView.transform, minScale/_Scale, minScale/_Scale);
    }
    
    [self adjustImageView];
    [self setContentInset];
}

//缩小
- (void)zoomOut {
    if (_Scale == minScale) {
        [self showPrompt:@"已缩小到最小比例"];
        return;
    }
    CGFloat scale = 0.5f;
    if (_Scale - scale >= minScale) {
        _ImageView.transform = CGAffineTransformScale(_ImageView.transform, 1 - scale/_Scale, 1 - scale/_Scale);
        _Scale -= scale;
    }else if(_Scale - scale < minScale){
        _ImageView.transform = CGAffineTransformScale(_ImageView.transform, minScale/_Scale, minScale/_Scale);
        _Scale = minScale;
    }
    [self adjustImageView];
    [self setContentInset];
}

//放大
- (void)zoomIn {
    if (_Scale == maxScale) {
        [self showPrompt:@"已放大到最大比例"];
        return;
    }
    CGFloat scale = 0.5f;
    if (_Scale + scale <= maxScale) {
        _ImageView.transform = CGAffineTransformScale(_ImageView.transform, 1 + scale/_Scale, 1 + scale/_Scale);
        _Scale += scale;
    }else if(_Scale + scale > maxScale){
        _ImageView.transform = CGAffineTransformScale(_ImageView.transform, maxScale/_Scale, maxScale/_Scale);
        _Scale = maxScale;
    }
    [self adjustImageView];
    [self setContentInset];
}

//保存
- (void)savePhoto {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:_ImageView.image.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            [self showPrompt:@"保存失败"];
        }else {
            [self showPrompt:@"保存成功"];
        }
    }];
//    UIImageWriteToSavedPhotosAlbum(_ImageView.image, nil, @selector(SaveImageSuccessed), nil);
}

#pragma mark prompt

- (void)showPrompt:(NSString *)message {
    [self canPerformAction:@selector(hiddenPrompt) withSender:nil];
    if (promptLable == nil) {
        promptLable = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 180)/2, self.view.frame.size.height - 100, 180, 40)];
        promptLable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        promptLable.backgroundColor = [UIColor blackColor];
        promptLable.textAlignment = NSTextAlignmentCenter;
        promptLable.textColor = [UIColor whiteColor];
        
        promptLable.layer.shadowColor = [UIColor blackColor].CGColor;
        promptLable.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        promptLable.layer.shadowOpacity = 3;
        promptLable.layer.shadowRadius = 10.0;
        promptLable.layer.cornerRadius = 20.0;
        
        [self.view insertSubview:promptLable aboveSubview:_reviewImageView];
    }
    promptLable.hidden = NO;
    promptLable.text = message;
    [self performSelector:@selector(hiddenPrompt) withObject:nil afterDelay:1.5f];
}

- (void)hiddenPrompt {
    promptLable.hidden = YES;
}

#pragma mark - handle gesture

//单击, 导航栏的隐藏
- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    [UIView animateWithDuration:0.1f animations:^(){
        if (self.navigationController.navigationBarHidden) {
            self.navigationController.navigationBarHidden = NO;
        }else {
            self.navigationController.navigationBarHidden = YES;
        }
    }];
    [self adjustImageView];
    [self setContentInset];
}

//双击， 放大到最大的比例
- (void)doubleTapGesture:(UITapGestureRecognizer *)gestureRecognizer {
    if (_Scale == minScale) {
        _Scale = maxScale;
        
        CGPoint touchPoint = [gestureRecognizer locationInView:_ImageView];
        touchCenter = touchPoint;
        
        [UIView animateWithDuration:0.4f animations:^{
            _ImageView.transform = CGAffineTransformScale(_ImageView.transform, maxScale, maxScale);
//            _ImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, maxScale, maxScale);
        }];
        _ImageView.transform = CGAffineTransformTranslate(_ImageView.transform, _ImageView.center.x - touchPoint.x, _ImageView.center.y - touchPoint.y);
        
        [self adjustImageView];
        
    }else {
        [UIView animateWithDuration:0.2f animations:^{
//            _ImageView.transform = CGAffineTransformIdentity;
            _ImageView.transform = CGAffineTransformScale(_ImageView.transform, minScale/_Scale, minScale/_Scale);
        }];
        _Scale = minScale;
        _ImageView.transform = CGAffineTransformTranslate(_ImageView.transform,  -_ImageView.frame.origin.x/_Scale, -_ImageView.frame.origin.y/_Scale);
        
    }
    [self setContentInset];
}


//旋转
- (void)rotationGesture:(UIGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _startPoint = [gestureRecognizer locationInView:self.view];
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint currentPoint = [gestureRecognizer locationInView:self.view];
            CGFloat deltaX = currentPoint.x - _startPoint.x;
            CGFloat deltaY = currentPoint.y - _startPoint.y;
            CGFloat angleInRadians = atan2f(deltaY, deltaX);
            [self rotationImageWithX:angleInRadians];
        }
            break;
        case UIGestureRecognizerStateEnded:{
            
        }
            break;
        default:
            break;
    }
}

//捏合
- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {

    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            
            CGPoint point1 = [gestureRecognizer locationOfTouch:0 inView:_ImageView];
            CGPoint point2 = [gestureRecognizer locationOfTouch:1 inView:_ImageView];
            
            scaleCenter = CGPointMake((point1.x + point2.x)/2, (point1.y + point2.y)/2);
//            NSLog(@"\n\n============%@==============\n\n",NSStringFromCGPoint(scaleCenter));
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (gestureRecognizer.numberOfTouches == 2) {
                
                _Scale = _ImageView.frame.size.width/_reviewImageView.frame.size.width;
                
                CGFloat deltaX = scaleCenter.x-_ImageView.center.x;
                CGFloat deltaY = scaleCenter.y-_ImageView.center.y;
                
                CGAffineTransform transform =  CGAffineTransformTranslate(_ImageView.transform, deltaX, deltaY);
                transform = CGAffineTransformScale(transform, gestureRecognizer.scale, gestureRecognizer.scale);
                transform = CGAffineTransformTranslate(transform, -deltaX, -deltaY);

                _ImageView.transform = transform;
                gestureRecognizer.scale = 1;
                
            }
        }
            break;
        
        case UIGestureRecognizerStateEnded:{
//            NSLog(@"%f",_Scale);
            if (_Scale > maxScale) {
//                CGRect previousFrame = _ImageView.frame;
//                NSLog(@"%@",NSStringFromCGRect(previousFrame));
                [UIView animateWithDuration:0.4f animations:^{
                    
                    _ImageView.transform = CGAffineTransformScale(_ImageView.transform, maxScale/_Scale, maxScale/_Scale);
                }];
//                CGRect currentFrame = _ImageView.frame;
//                NSLog(@"%@\n",NSStringFromCGRect(currentFrame));
//                NSLog(@"\n%@\n%@\n",NSStringFromCGAffineTransform(transform),NSStringFromCGAffineTransform(_ImageView.transform));
//                _ImageView.transform = CGAffineTransformTranslate(_ImageView.transform, scaleCenter.x * (1 -  _Scale/maxScale), scaleCenter.y * (1 - _Scale/maxScale));
            }
            if (_ImageView.frame.size.width < _reviewImageView.frame.size.width) {
                [UIView animateWithDuration:0.2f animations:^{
                    _ImageView.transform = CGAffineTransformIdentity;
                    _Scale = minScale;
                }];
            }
            _Scale = _ImageView.frame.size.width/_reviewImageView.frame.size.width;
            [self adjustImageView];
            [self setContentInset];
        }
            break;
        
        default:
            break;
    }
}

#pragma mark - handle ImageView

//旋转图片
- (void)rotationImageWithX:(float)angle {
    _ImageView.transform = CGAffineTransformMakeRotation(angle);
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:_toolBar];
    if (touchPoint.y >= 0 && touchPoint.y <= _toolBar.frame.size.height) {
        return NO;
    }
    return YES;
}

//是否允许多种手势同时响应
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer == _reviewImageView.panGestureRecognizer) {
        return YES;
    }
    return NO;
}

@end
