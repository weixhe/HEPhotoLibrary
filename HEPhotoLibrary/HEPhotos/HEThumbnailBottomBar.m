//
//  HEThumbnailBottomBar.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/4.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEThumbnailBottomBar.h"
#import "HEPhotoConstant.h"
#import "HEPhotoTool.h"

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

@property (nonatomic, strong) NSMutableArray <HEThumbailBottomBarModel *> *selectedImages;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation HEThumbnailBottomBar
- (void)dealloc
{
    [self.selectedImages removeAllObjects];
    self.selectedImages = nil;
    
    self.scrollView = nil;
    self.countLabel = nil;
    self.DeleteOneImage = NULL;
    self.FinishToSelectImage = NULL;
    PhotoLog(@"HEThumbnailBottomBar dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedImages = [NSMutableArray array];
        [self setup];
    }
    return self;
}

- (void)setup {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width - self.height, self.height)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.right + 5, 5, self.height - 10, self.height - 10)];
    view.backgroundColor = [UIColor redColor];
    view.layer.cornerRadius = (self.height - 10) / 2;
    view.layer.masksToBounds = YES;
    [self addSubview:view];
    
    self.countLabel = [[UILabel alloc] initWithFrame:view.bounds];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.font = [UIFont systemFontOfSize:15];
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.numberOfLines = 2;
    self.countLabel.text = [NSString stringWithFormat:@"%@\n0/%ld", LocalizedStringForKey(kTextForSure), self.maxSelectCount];
    [view addSubview:self.countLabel];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sureBtn.frame = view.bounds;
    [sureBtn addTarget:self action:@selector(onSureAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:sureBtn];
}

- (UIView *)generateImageViewWithImage:(UIImage *)image {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.height, self.scrollView.height)];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, view.height - 15, view.height - 15);
    imageView.center = CGPointMake(view.width / 2, view.height / 2);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [view addSubview:imageView];
    
    UIImageView *closeIcon = [[UIImageView alloc] initWithImage:UIImageFromPhotoBundle(@"icon_close")];
    closeIcon.frame = CGRectMake(0, 0, 15, 15);
    closeIcon.center = CGPointMake(imageView.right - 2, imageView.top + 2);
    [view addSubview:closeIcon];
    
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(view.right - 25, 0, 25, 25)];
    [deleteBtn addTarget:self action:@selector(onDeleteImageAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:deleteBtn];
    
    return view;
}

#pragma mark - UIButton Action

- (void)onSureAction:(UIButton *)button {
    if (self.FinishToSelectImage) {
        self.FinishToSelectImage();
    }
}
- (void)onDeleteImageAction:(UIButton *)button {
    
    NSInteger index = [self.scrollView.subviews indexOfObject:button.superview];

    if (self.selectedImages.count > index) {
        
        HEThumbailBottomBarModel *model = [self.selectedImages objectAtIndex:index];
        if (self.DeleteOneImage) {
            self.DeleteOneImage(model.image, model.asset);
        }
        [button.superview removeFromSuperview];
        [self.selectedImages removeObject:model];
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
    self.scrollView.contentSize = CGSizeMake(self.selectedImages.count * self.scrollView.height, self.scrollView.height);
    [self.scrollView scrollRectToVisible:CGRectMake((self.selectedImages.count - 1) * self.scrollView.height, 0, self.scrollView.height, self.scrollView.height) animated:YES];
    self.countLabel.text = [NSString stringWithFormat:@"%@\n%ld/%ld", LocalizedStringForKey(kTextForSure), self.selectedImages.count, self.maxSelectCount];
}

- (void)setMaxSelectCount:(NSUInteger)maxSelectCount {
    _maxSelectCount = maxSelectCount;
    self.countLabel.text = [NSString stringWithFormat:@"%@\n%ld/%ld", LocalizedStringForKey(kTextForSure), self.selectedImages.count, maxSelectCount];
}


- (void)setSelectedAsset:(NSMutableArray<PHAsset *> *)selectedAsset {
    _selectedAsset = selectedAsset;
    WS(weakSelf)
    for (int i = 0; i < selectedAsset.count; i ++) {
        PHAsset *asset = [selectedAsset objectAtIndex:i];
        [[HEPhotoTool sharePhotoTool] requestImageForAsset:asset size:weakSelf.size resizeMode:PHImageRequestOptionsResizeModeExact complete:^(UIImage *image, NSDictionary *info) {
            [weakSelf addImage:image asset:asset];
        }];
    }
}

- (void)addImage:(UIImage *)image asset:(PHAsset *)asset {

    if (!image) {
        WS(weakSelf)
        [[HEPhotoTool sharePhotoTool] requestImageForAsset:asset size:weakSelf.size resizeMode:PHImageRequestOptionsResizeModeExact complete:^(UIImage *image, NSDictionary *info) {
            [weakSelf addImage:image asset:asset];
        }];
        return;
    }
    
    UIView *view = [self generateImageViewWithImage:image];
    
    HEThumbailBottomBarModel *model = [[HEThumbailBottomBarModel alloc] init];
    model.view = view;
    model.image = image;
    model.asset = asset;
    
    [self.selectedImages addObject:model];
    [self.scrollView addSubview:view];
    
    [self resetFrame];

}

- (void)deleteImage:(UIImage *)image asset:(PHAsset *)asset {
    __weak typeof(asset) weakAsset = asset;
    WS(weakSelf);
    [self.selectedImages enumerateObjectsUsingBlock:^(HEThumbailBottomBarModel *model, NSUInteger idx, BOOL * _Nonnull stop) {

        if ([model.asset.localIdentifier isEqual:weakAsset.localIdentifier]) {
            
            NSArray *subViews = weakSelf.scrollView.subviews;
            if (subViews.count > idx) {
                [[subViews objectAtIndex:idx] removeFromSuperview];
            }
            [weakSelf.selectedImages removeObject:model];
            [weakSelf resetFrame];
            
            *stop = YES;
        }
    }];
}

@end


