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

@interface HEClipImageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *bigImageView;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation HEClipImageViewController

- (void)dealloc
{
    self.scrollView = nil;
    self.bigImageView = nil;
    self.indicator = nil;
    self.asset = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.bigImageView];
    [self.view addSubview:self.indicator];


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
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleTap];

    }
    return _scrollView;
}

- (UIImageView *)bigImageView {
    if (!_bigImageView) {
        _bigImageView = [[UIImageView alloc] init];
        _bigImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _bigImageView;
}

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.hidesWhenStopped = YES;
        _indicator.center = self.view.center;
    }
    return _indicator;
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    if (_asset) {
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat width = MIN(kViewWidth, 500);       // 不建议设置太大，太大的话会导致图片加载过慢
        CGSize size = CGSizeMake(width * scale, width * scale * asset.pixelHeight / asset.pixelWidth);
        
        [self.indicator startAnimating];
        WS(weakSelf)
        [[HEPhotoTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast complete:^(UIImage *image, NSDictionary *info) {
            weakSelf.bigImageView.image = image;
            [weakSelf resetSubviewSize];
            if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                [weakSelf.indicator stopAnimating];
            }
        }];
    }
    
}

- (void)resetSubviewSize {
    CGRect frame;
    frame.origin = CGPointZero;
    
    UIImage *image = self.bigImageView.image;
    CGFloat imageScale = image.size.height / image.size.width;
    CGFloat screenScale = kViewHeight / kViewWidth;
    if (image.size.width <= CGRectGetWidth(self.view.frame) && image.size.height <= CGRectGetHeight(self.view.frame)) {
        frame.size.width = image.size.width;
        frame.size.height = image.size.height;
    } else {
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
    [self.scrollView scrollRectToVisible:self.view.bounds animated:NO];
    self.bigImageView.frame = frame;
    self.bigImageView.center = self.scrollView.center;
    
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
    return self.bigImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (CGRectGetWidth(scrollView.frame) > scrollView.contentSize.width) ? (CGRectGetWidth(scrollView.frame) - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (CGRectGetHeight(scrollView.frame) > scrollView.contentSize.height) ? (CGRectGetHeight(scrollView.frame) - scrollView.contentSize.height) * 0.5 : 0.0;
    self.bigImageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end
