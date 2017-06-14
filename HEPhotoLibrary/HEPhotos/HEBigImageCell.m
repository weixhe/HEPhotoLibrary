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

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *bigImageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation HEBigImageCell

- (void)dealloc
{
    self.scrollView = nil;
    self.bigImageView = nil;
    self.indicator = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.bigImageView];
        [self.contentView addSubview:self.indicator];
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

- (UIImageView *)bigImageView
{
    if (!_bigImageView) {
        _bigImageView = [[UIImageView alloc] init];
        _bigImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _bigImageView;
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
    
    UIImage *image = self.bigImageView.image;
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
    self.bigImageView.frame = frame;
    self.bigImageView.center = self.scrollView.center;

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

#pragma mark - Setter

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
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


@end
