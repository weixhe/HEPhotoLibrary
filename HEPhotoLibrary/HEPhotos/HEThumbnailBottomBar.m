//
//  HEThumbnailBottomBar.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/4.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEThumbnailBottomBar.h"
#import "HEPhotoConstant.h"

static NSString * const kForView                = @"HEPhotos_Thumbnail_BottomView_View";
static NSString * const kForImage               = @"HEPhotos_Thumbnail_BottomView_Image";
static NSString * const kForIndexPath           = @"HEPhotos_Thumbnail_BottomView_IndexPath";

#pragma mark - 类
@interface HEThumbailBottomBarModel : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIView *view; // 容器，盛放imageView和closeBtn

@end

@implementation HEThumbailBottomBarModel

@end

#pragma mark - 类

@interface HEThumbnailBottomBar () {

}

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation HEThumbnailBottomBar
- (void)dealloc
{
    [self.dataSource removeAllObjects];
    self.dataSource = nil;
    
    self.scrollView = nil;
    self.countLabel = nil;
    self.DeleteOneImage = NULL;
    NSLog(@"HEThumbnailBottomBar dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataSource = [NSMutableArray array];
        [self setup];
    }
    return self;
}

- (void)setup {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width - self.height, self.height)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.right + 5, 5, self.height - 10, self.height - 10)];
    view.backgroundColor = [UIColor redColor];
    view.layer.cornerRadius = (self.height - 10) / 2;
    view.layer.masksToBounds = YES;
    [self addSubview:view];
    
    self.countLabel = [[UILabel alloc] initWithFrame:view.bounds];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.text = [NSString stringWithFormat:@"0/%ld", self.maxSelectCount];
    [view addSubview:self.countLabel];
}

- (UIView *)generateImageViewWithImage:(UIImage *)image {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.height, self.scrollView.height)];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, view.height - 15, view.height - 15);
    imageView.center = CGPointMake(view.width / 2, view.height / 2);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [view addSubview:imageView];
    
    UIImageView *closeIcon = [[UIImageView alloc] initWithImage:HEPhotoImageFromBundleWithName(@"icon_close")];
    closeIcon.frame = CGRectMake(0, 0, 15, 15);
    closeIcon.center = CGPointMake(imageView.right - 2, imageView.top + 2);
    [view addSubview:closeIcon];
    
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(view.right - 25, 0, 25, 25)];
    [deleteBtn addTarget:self action:@selector(onDeleteImageAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:deleteBtn];
    
    return view;
}

#pragma mark - UIButton Action
- (void)onDeleteImageAction:(UIButton *)button {
    
    NSInteger index = [self.scrollView.subviews indexOfObject:button.superview];

    if (self.dataSource.count > index) {
        
        HEThumbailBottomBarModel *model = [self.dataSource objectAtIndex:index];
        if (self.DeleteOneImage) {
            self.DeleteOneImage(model.image, model.asset);
        }
        [button.superview removeFromSuperview];
        [self resetFrame];
    }
}

- (void)resetFrame {
    CGFloat willSetX = 0;
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        UIView *view = [self.scrollView.subviews objectAtIndex:i];
        willSetX = i * view.width + 2;
        if (view.x != willSetX) {
            view.x = willSetX;
        }
    }
    self.scrollView.contentSize = CGSizeMake(self.dataSource.count * self.scrollView.height, self.scrollView.height);
    [self.scrollView scrollRectToVisible:CGRectMake((self.dataSource.count - 1) * self.scrollView.height, 0, self.scrollView.height, self.scrollView.height) animated:YES];
    self.countLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.dataSource.count, self.maxSelectCount];
}

- (void)addImage:(UIImage *)image asset:(PHAsset *)asset {
    if (self.dataSource.count == 0 && self.scrollView.subviews.count != 0) {
        [self.scrollView removeAllSubviews];
    }
    
    UIView *view = [self generateImageViewWithImage:image];
    
    HEThumbailBottomBarModel *model = [[HEThumbailBottomBarModel alloc] init];
    model.view = view;
    model.image = image;
    model.asset = asset;
    
    [self.dataSource addObject:model];
    [self.scrollView addSubview:view];
    
    [self resetFrame];

}

- (void)deleteImage:(UIImage *)image asset:(PHAsset *)asset {
    __weak typeof(asset) weakAsset = asset;
    WS(weakSelf);
    [self.dataSource enumerateObjectsUsingBlock:^(HEThumbailBottomBarModel *model, NSUInteger idx, BOOL * _Nonnull stop) {

        if ([model.asset.localIdentifier isEqual:weakAsset.localIdentifier]) {
            
            NSArray *subViews = weakSelf.scrollView.subviews;
            if (subViews.count > idx) {
                [[subViews objectAtIndex:idx] removeFromSuperview];
            }
            [weakSelf.dataSource removeObject:model];
            [weakSelf resetFrame];
            
            *stop = YES;
        }
    }];
    
//    if ([self.dataSource containsObject:image]) {
//        
//        NSInteger index = [self.dataSource indexOfObject:image];
//        
//        NSArray *subViews = self.scrollView.subviews;
//        if (subViews.count > index) {
//            [[subViews objectAtIndex:index] removeFromSuperview];
//        }
//        [self.dataSource removeObject:image];
//        [self resetFrame];
//    }
}

@end


