//
//  HEClipImageViewController.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/27.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEClipImageViewController.h"
#import "HEPhotoConstant.h"
#import "HEPhotoTool.h"

@interface HEClipImageViewController () <UIScrollViewDelegate> {
    
    
}

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *photoView;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) UIView *maskView;       // 遮罩

@end

@implementation HEClipImageViewController

- (void)dealloc
{
    self.scrollView = nil;
    self.photoView = nil;
    self.indicator = nil;
    self.asset = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.canEdit = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.photoView];
    [self.view addSubview:self.indicator];
    
    if (self.canEdit) {
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleTap];
        [self.view addSubview:self.maskView];
    }


    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kViewHeight - 60, kViewWidth, 60)];
    bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [self.view addSubview:bottomView];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 60, 60);
    [backBtn setTitle:LocalizedStringForKey(kTextForCancel) forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:backBtn];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(kViewWidth - 60, 0, 60, 60);
    [doneBtn setTitle:LocalizedStringForKey(kTextForSure) forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(onFinishAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:doneBtn];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = self.view.bounds;
        
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;

    }
    return _scrollView;
}

- (UIImageView *)photoView {
    if (!_photoView) {
        _photoView = [[UIImageView alloc] init];
        _photoView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _photoView;
}

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.hidesWhenStopped = YES;
        _indicator.center = self.view.center;
    }
    return _indicator;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        _maskView.userInteractionEnabled = NO;
        
        CGFloat x = self.clipCenter.x - self.clipWidth / 2;
        CGFloat y = self.clipCenter.y - self.clipHeight / 2;
        UIBezierPath *bezier = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, kViewWidth, kViewHeight)];
        bezier.usesEvenOddFillRule = YES;
        
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, self.clipWidth, self.clipHeight)];
        [bezier appendPath:rectPath];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = bezier.CGPath;
        shapeLayer.fillRule = kCAFillRuleEvenOdd;
        shapeLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
        shapeLayer.opaque = 0.1;
        [_maskView.layer addSublayer:shapeLayer];
    }
    return _maskView;
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    if (_asset) {
        
        [self.indicator startAnimating];
        WS(weakSelf)
        // 同步
        [[HEPhotoTool sharePhotoTool] requestImageForAsset:asset size:PHImageManagerMaximumSize resizeMode:PHImageRequestOptionsResizeModeExact complete:^(UIImage *image, NSDictionary *info) {
            weakSelf.photoView.image = image;
            [weakSelf resetSubviewSize];
            if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                [weakSelf.indicator stopAnimating];
            }
        }];
    }
}

- (CGPoint)clipCenter {
    
    if (CGPointEqualToPoint(_clipCenter, CGPointZero)) {
        _clipCenter = CGPointMake(kViewWidth / 2, kViewHeight / 2);
    }
    return _clipCenter;
}

- (void)resetSubviewSize {
    CGRect frame;
    frame.origin = CGPointZero;
    
    UIImage *image = self.photoView.image;
    CGFloat imageScale = image.size.height / image.size.width;
    CGFloat clipScale = self.clipHeight / self.clipWidth;
    CGFloat screenScale = CGRectGetHeight(self.view.frame) / CGRectGetWidth(self.view.frame);

    if (image.size.width < self.clipWidth && image.size.height < self.clipHeight) {
        // 1. 相对clip： 宽，高 都 < clip, 按照clipRect，对image进行缩放
        if (imageScale > clipScale) {
            
            frame.size.width = self.clipWidth;
            frame.size.height = self.clipWidth * imageScale;
        } else {
            frame.size.height = self.clipHeight;
            frame.size.width = self.clipHeight / imageScale;
        }
    } else if (image.size.width > self.clipWidth && image.size.height < self.clipHeight) {
        // 2. 相对clip：宽 > clip, 按照'高'进行放缩
        frame.size.height = self.clipHeight;
        frame.size.width = self.clipHeight / imageScale;

    } else if (image.size.height > self.clipHeight && image.size.width < self.clipWidth) {
        // 3. 相对clip：宽 > clip, 按照'宽'进行放缩
        frame.size.width = self.clipWidth;
        frame.size.height = self.clipWidth * imageScale;
        
    } else if (image.size.width < CGRectGetWidth(self.view.frame) && image.size.width < CGRectGetHeight(self.view.frame)) {
        // 4. 相对Screen：宽，高 都 < screen
        frame.size.width = image.size.width;
        frame.size.height = image.size.height;
    } else {
        // 5. 相对screen：宽，高 至少有一个超出了screen
        if (imageScale > screenScale) {
            frame.size.height = CGRectGetHeight(self.view.frame);
            frame.size.width = CGRectGetHeight(self.view.frame) / imageScale;
        } else {
            frame.size.width = CGRectGetWidth(self.view.frame);
            frame.size.height = CGRectGetWidth(self.view.frame) * imageScale;
        }
    }

    self.scrollView.zoomScale = 1;
    self.scrollView.contentSize = frame.size;
    self.photoView.frame = frame;
    self.photoView.center = CGPointEqualToPoint(self.clipCenter, CGPointZero) ? CGPointMake(kViewWidth / 2, kViewHeight / 2) : self.clipCenter;

    // 设置contentInsert，保证imageView的top，bottom，left，right能滑动到clip区域
    CGFloat offset_top = (_scrollView.frame.size.height - self.clipHeight) / 2;
    CGFloat offset_left = (_scrollView.frame.size.width - self.clipWidth) / 2;
    _scrollView.contentInset = UIEdgeInsetsMake(offset_top, offset_left, offset_top, offset_left);
    
    // 因为设置了contentInsert，所以需要手动设置offset，保证imageView在clipCenter
//    _scrollView.contentOffset = CGPointMake(-offset_left, -offset_top);
}

#pragma mark - 事件
- (void)onCancelAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onFinishAction {
    
}

- (void)doubleTapAction:(UIGestureRecognizer *)gesture {
    UIScrollView *scrollView = (UIScrollView *)gesture.view;
    
    CGFloat scale = 1;
    if (scrollView.zoomScale != 3.0) {
        scale = 3;
    } else {
        scale = 1;
    }
    // 根据点击的位置放大
    CGRect zoomRect = [self zoomRectForScale:scale withCenter:[gesture locationInView:gesture.view]];
    [scrollView zoomToRect:zoomRect animated:YES];
    
    // 直接放大scale倍
    //    [scrollView setZoomScale:scale animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (CGRectGetWidth(scrollView.frame) > scrollView.contentSize.width) ? (CGRectGetWidth(scrollView.frame) - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (CGRectGetHeight(scrollView.frame) > scrollView.contentSize.height) ? (CGRectGetHeight(scrollView.frame) - scrollView.contentSize.height) * 0.5 : 0.0;
    self.photoView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end
