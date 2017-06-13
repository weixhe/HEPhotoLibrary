//
//  HEBigImageCell.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/13.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEBigImageCell.h"
#import "HEPhotoConstant.h"
#import "HEPhotoTool.h"

@interface HEBigImageCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation HEBigImageCell

- (void)dealloc
{
    self.containerView = nil;
    self.scrollView = nil;
    self.imageView = nil;
    self.indicator = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.containerView];
        [self.containerView addSubview:self.imageView];
        [self addSubview:self.indicator];
    }
    return self;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = self.bounds;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        [_scrollView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return _scrollView;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UIActivityIndicatorView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.hidesWhenStopped = YES;
        _indicator.center = self.contentView.center;
    }
    return _indicator;
}

- (void)resetSubviewSize {
    CGRect frame;
    frame.origin = CGPointZero;
    
    UIImage *image = self.imageView.image;
    CGFloat imageScale = image.size.height / image.size.width;
    CGFloat screenScale = kViewHeight / kViewWidth;
    if (image.size.width <= CGRectGetWidth(self.frame) && image.size.height <= CGRectGetHeight(self.frame)) {
        frame.size.width = image.size.width;
        frame.size.height = image.size.height;
    } else {
        if (imageScale > screenScale) {
            frame.size.height = CGRectGetHeight(self.frame);
            frame.size.width = CGRectGetHeight(self.frame) / imageScale;
        } else {
            frame.size.width = CGRectGetWidth(self.frame);
            frame.size.height = CGRectGetWidth(self.frame) * imageScale;
        }
    }
    
    self.scrollView.zoomScale = 1;
    self.scrollView.contentSize = frame.size;
    [self.scrollView scrollRectToVisible:self.bounds animated:NO];
    self.containerView.frame = frame;
    self.containerView.center = self.scrollView.center;
    self.imageView.frame = self.containerView.bounds;
}

#pragma mark - Gesture Action
- (void)singleTapAction:(UIGestureRecognizer *)ges {
    if (self.BlockOnSingalTap) {
        self.BlockOnSingalTap();
    }
}

- (void)doubleTapAction:(UIGestureRecognizer *)gesture {
    UIScrollView *scrollView = (UIScrollView *)gesture.view;
    
    CGFloat scale = 1;
    if (scrollView.zoomScale != 3.0) {
        scale = 3;
    } else {
        scale = 1;
    }
    CGRect zoomRect = [self zoomRectForScale:scale withCenter:[gesture locationInView:gesture.view]];
    [scrollView zoomToRect:zoomRect animated:YES];

}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = self.scrollView.frame.size.height / scale;
    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return scrollView.subviews[0];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (CGRectGetWidth(scrollView.frame) > scrollView.contentSize.width) ? (CGRectGetWidth(scrollView.frame) - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (CGRectGetHeight(scrollView.frame) > scrollView.contentSize.height) ? (CGRectGetHeight(scrollView.frame) - scrollView.contentSize.height) * 0.5 : 0.0;
    self.containerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Setter

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN(kViewWidth, 500);       // 不建议设置太大，太大的话会导致图片加载过慢
    CGSize size = CGSizeMake(width * scale, width * scale * asset.pixelHeight / asset.pixelWidth);
    
    [self.indicator startAnimating];
    WS(weakSelf)
    [[HEPhotoTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast complete:^(UIImage *image, NSDictionary *info) {
        weakSelf.imageView.image = image;
        [weakSelf resetSubviewSize];
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            [weakSelf.indicator stopAnimating];
        }
    }];

}


@end
