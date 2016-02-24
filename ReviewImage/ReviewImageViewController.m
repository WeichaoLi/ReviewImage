//
//  ReviewImageViewController.m
//  ReviewImage
//
//  Created by 李伟超 on 14-10-27.
//  Copyright (c) 2014年 LWC. All rights reserved.
//

#import "ReviewImageViewController.h"
#import "SVProgressHUD.h"

#define __IPHONE_SYSTEM_VERSION [[UIDevice currentDevice] systemVersion].floatValue
#define IOS7 __IPHONE_SYSTEM_VERSION > 7.0

@interface ReviewImageViewController ()

@property (nonatomic, readwrite, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIToolbar *toolBar;

@end

@implementation ReviewImageViewController {
    UILabel *promptLable;  //提示
    NSString *ImageTracePath;
}

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
    
    self.view.backgroundColor = [UIColor blackColor];
    ImageTracePath = [[NSArray arrayWithObjects:NSHomeDirectory(), @"Documents", @"ImageTrace", nil]
                                       componentsJoinedByString:@"/"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:ImageTracePath]) {
        [fileManager createDirectoryAtPath:ImageTracePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    ImageTracePath = [ImageTracePath stringByAppendingString:@"/trace.plist"];
    
    NSLog(@"%@",[fileManager URLForUbiquityContainerIdentifier:nil]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    [super loadView];
    
    self.view.clipsToBounds = YES;
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    
    /****************************scrollview***************************/
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.decelerationRate = 0.1f;
    _scrollView.delegate = self;
    
    _containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    _containerView.backgroundColor = [UIColor yellowColor];
    [_scrollView addSubview:_containerView];
    
    [self.view addSubview:_scrollView];
    
    //******************* toolbar *******************************/
    
    if (_toolBar == nil) {
        _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
        _toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [_toolBar setBackgroundImage:[UIImage imageNamed:@"clearBG.png"] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
        [_toolBar setShadowImage:[UIImage imageNamed:@"clearBG.png"] forToolbarPosition:UIBarPositionBottom];
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *zoomOut = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zoomOut.png"] style:UIBarButtonItemStylePlain target:self action:@selector(zoomOut)];
        UIBarButtonItem *zoomIn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"zoomIn.png"] style:UIBarButtonItemStylePlain target:self action:@selector(zoomIn)];
        UIBarButtonItem *Save = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save.png"] style:UIBarButtonItemStylePlain target:self action:@selector(savePhoto)];
        UIBarButtonItem *leftRotate = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"leftRotation.png"] style:UIBarButtonItemStylePlain target:self action:@selector(leftRotation)];
        UIBarButtonItem *rightRotate = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rightRotation.png"] style:UIBarButtonItemStylePlain target:self action:@selector(rightRotation)];
        
        NSArray *Items = @[leftRotate,flexibleSpace,zoomOut,flexibleSpace,zoomIn,flexibleSpace,rightRotate,flexibleSpace,Save];
        [_toolBar setItems:Items animated:YES];
        
        _toolBar.tintColor = [UIColor whiteColor];
    }
    [_toolBar setUserInteractionEnabled:NO];
    [self.view insertSubview:_toolBar aboveSubview:_containerView];
    
    /****************************手势***************************/
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [_scrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [_scrollView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    /****************************初始化***************************/
    
    _imageOrientation = ImageOrientationPortrait;
    
    [self imageDidChange];
    
    [SVProgressHUD showWithStatus:@"加载图片中..." maskType:SVProgressHUDMaskTypeClear];
    [NSThread detachNewThreadSelector:@selector(loadImage) toTarget:self withObject:nil];
}

- (void)loadImage {
    UIImage *image = [[UIImage alloc] init];
    NSData *data = [NSData data];
    if (!_ImageURL) {
        _ImageURL = @"http://app.jingan.gov.cn/content/xinwzx/jingan/detail/t_ca3fc91614e67ddb4e84f7f0e1372321.jpg";
    }
    NSURL *_url = [[NSURL alloc] initWithString:_ImageURL];
    data = [[NSData alloc] initWithContentsOfURL:_url];
    image = [UIImage imageWithData:data];
    self.imageView = [[UIImageView alloc] initWithImage:image];
    [SVProgressHUD dismiss];
    [self imageDidChange];
    [_toolBar setUserInteractionEnabled:YES];
}

#pragma mark- Properties

- (void)setImageView:(UIImageView *)imageView {
    if(imageView != _imageView){
        [_imageView removeObserver:self forKeyPath:@"image"];
        [_imageView removeFromSuperview];
        
        _imageView = imageView;
        _imageView.frame = _imageView.bounds;
        
        [_imageView addObserver:self forKeyPath:@"image" options:0 context:nil];
        
        [_containerView addSubview:_imageView];
        
        _scrollView.zoomScale = 1;
        _scrollView.contentOffset = CGPointZero;
        _containerView.bounds = _imageView.bounds;
        
        [self resetZoomScale];
        _scrollView.zoomScale  = _scrollView.minimumZoomScale;
        [self scrollViewDidZoom:_scrollView];
    }
}

#pragma mark - 当图片改变:例如旋转

- (void)imageDidChange {
        
    CGSize size = (self.imageView.image) ? self.imageView.image.size : self.view.bounds.size;
    CGFloat ratio;
    
    if (_imageOrientation == ImageOrientationPortrait || _imageOrientation == ImageOrientationPortraitUpsideDown) { //判断图片是不是正的
        ratio = MIN(_scrollView.frame.size.width / size.width, _scrollView.frame.size.height / size.height);
    }else {
        ratio = MIN(_scrollView.frame.size.width / size.height, _scrollView.frame.size.height / size.width);
    }    
    
    CGFloat W = ratio * size.width;
    CGFloat H = ratio * size.height;
    self.imageView.frame = CGRectMake(0, 0, W, H);

    _scrollView.zoomScale = 1;
    _scrollView.contentOffset = CGPointZero;
    _containerView.bounds = _imageView.bounds;

    [self resetZoomScale];
    _scrollView.zoomScale  = _scrollView.minimumZoomScale;
    [self scrollViewDidZoom:_scrollView];
    
    _imageView.frame = _containerView.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    _scrollView.bounds = self.view.bounds;
}

#pragma mark- Scrollview delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _containerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat Ws = _scrollView.frame.size.width - _scrollView.contentInset.left - _scrollView.contentInset.right;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _containerView.frame.size.width;
    CGFloat H = _containerView.frame.size.height;
    
    CGRect rct = _containerView.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    _containerView.frame = rct;
    
    if (scrollView.zoomScale >= scrollView.maximumZoomScale) {
        [self showPrompt:@"已放大到最大比例"];
    }
}

- (void)resetZoomScale {
    CGFloat Rw = _scrollView.frame.size.width / self.imageView.frame.size.width;
    CGFloat Rh = _scrollView.frame.size.height / self.imageView.frame.size.height;
    
    CGFloat scale = 1;
    
    if (_imageOrientation == ImageOrientationPortrait || _imageOrientation == ImageOrientationPortraitUpsideDown) {
        Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.width));
        Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.height));
    }else {
        Rw = MAX(Rw, _imageView.image.size.width / (scale * _scrollView.frame.size.height));
        Rh = MAX(Rh, _imageView.image.size.height / (scale * _scrollView.frame.size.width));
    }
    
    _scrollView.contentSize = _imageView.frame.size;
    _scrollView.minimumZoomScale = 1;
    _scrollView.maximumZoomScale = MAX(MAX(Rw, Rh), 1);
}

#pragma mark - Tap gesture

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
        _toolBar.hidden = NO;
    }else {
        self.navigationController.navigationBarHidden = YES;
        _toolBar.hidden = YES;
    }
    [self imageDidChange];
    if (_scrollView.bounds.origin.x == 0) {
        _scrollView.bounds = self.view.bounds;
    }
}

- (void)didDoubleTap:(UITapGestureRecognizer*)gesture {
    if (_scrollView.zoomScale != _scrollView.minimumZoomScale) {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    }else {
        [_scrollView setZoomScale:_scrollView.maximumZoomScale animated:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:_toolBar];
    if (touchPoint.y >= 0 && touchPoint.y <= _toolBar.frame.size.height) {
        return NO;
    }
    return YES;
}

#pragma mark - toolBar Action

- (void)leftRotation {
    
    _imageView.transform = CGAffineTransformRotate(_imageView.transform, - M_PI_2);
    
    switch (_imageOrientation) {
        case ImageOrientationPortrait:
            _imageOrientation = ImageOrientationLandScapeLeft;
            break;
        case ImageOrientationLandScapeLeft:
            _imageOrientation = ImageOrientationPortraitUpsideDown;
            break;
        case ImageOrientationLandScapeRight:
            _imageOrientation = ImageOrientationPortrait;
            break;
        case ImageOrientationPortraitUpsideDown:
            _imageOrientation = ImageOrientationLandScapeRight;
            break;
            
        default:
            break;
    }
    
    [self imageDidChange];
//    _imageView.frame = _containerView.bounds;
}

- (void)rightRotation {
    
    _imageView.transform = CGAffineTransformRotate(_imageView.transform, M_PI_2);
    
    switch (_imageOrientation) {
        case ImageOrientationPortrait:
            _imageOrientation = ImageOrientationLandScapeRight;
            break;
        case ImageOrientationLandScapeLeft:
            _imageOrientation = ImageOrientationPortrait;
            break;
        case ImageOrientationLandScapeRight:
            _imageOrientation = ImageOrientationPortraitUpsideDown;
            break;
        case ImageOrientationPortraitUpsideDown:
            _imageOrientation = ImageOrientationLandScapeLeft;
            break;
            
        default:
            break;
    }
    
    [self imageDidChange];
//    _imageView.frame = _containerView.bounds;
}

- (void)zoomOut {
    
    if (_scrollView.zoomScale == _scrollView.minimumZoomScale) {
        [self showPrompt:@"已缩小到最小比例"];
        return;
    }
    
    if (_scrollView.zoomScale - 0.5 >= _scrollView.minimumZoomScale) {
        [_scrollView setZoomScale:(_scrollView.zoomScale - 0.5) animated:YES];
    }else {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    }
}

- (void)zoomIn {
    
    if (_scrollView.zoomScale == _scrollView.maximumZoomScale) {
        [self showPrompt:@"已放大到最大比例"];
        return;
    }
    
    if (_scrollView.zoomScale + 0.5 <= _scrollView.maximumZoomScale) {
        [_scrollView setZoomScale:(_scrollView.zoomScale + 0.5) animated:YES];
    }else {
        [_scrollView setZoomScale:_scrollView.maximumZoomScale animated:YES];
    }
}

- (void)savePhoto {
    NSLog(@"%@",[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:UBIQUITY_CONTAINER_URL]);
    
    dispatch_queue_t someQueue;
    someQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(someQueue, ^{
        
        if (![[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil]) {
            NSLog(@"iCloud container not available.");
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
        });
        
    });
    
    [SVProgressHUD showWithStatus:@"正在保存..."];
    
    NSMutableArray *array = [self getDataFromPath:ImageTracePath];
    
    if ([array containsObject:_ImageURL]) {
        [SVProgressHUD showSuccessWithStatus:@"已保存到相册"];
        return;
    }
    UIImageWriteToSavedPhotosAlbum(_imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != NULL){
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
    }
    else{
        NSMutableArray *array = [self getDataFromPath:ImageTracePath];
        [array addObject:_ImageURL];
        [array writeToFile:ImageTracePath atomically:YES];
        
        [SVProgressHUD showSuccessWithStatus:@"已保存到相册"];
    }
}

- (NSMutableArray *)getDataFromPath:(NSString *)path {
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:ImageTracePath];
    if (array == nil) {
        array = [NSMutableArray array];
    }
    return array;
}

#pragma mark prompt

- (void)showPrompt:(NSString *)message {
    if (promptLable == nil) {
        promptLable = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 180)/2, self.view.frame.size.height - 100, 180, 40)];
        promptLable.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        promptLable.backgroundColor = [UIColor blackColor];
        promptLable.textAlignment = NSTextAlignmentCenter;
        promptLable.textColor = [UIColor whiteColor];
        
        promptLable.layer.shadowColor = [UIColor blackColor].CGColor;
        promptLable.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        promptLable.layer.shadowOpacity = 3;
        promptLable.layer.shadowRadius = 10.0;
        promptLable.layer.cornerRadius = 20.0;
        
        [self.view insertSubview:promptLable aboveSubview:_scrollView];
    }
    promptLable.hidden = NO;
    promptLable.text = message;
    [self performSelector:@selector(hiddenPrompt) withObject:nil afterDelay:1.5f];
}

- (void)hiddenPrompt {
    promptLable.hidden = YES;
}

#pragma mark - Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self imageDidChange];
    
}


@end
