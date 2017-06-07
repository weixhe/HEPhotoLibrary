//
//  HEThumbnailCell.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/4.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEThumbnailCell.h"
#import "HEPhotoConstant.h"
#import "HEPhotoTool.h"

@interface HEThumbnailCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIButton *checkBtn;

@end

@implementation HEThumbnailCell

- (void)dealloc
{
    self.imageView = nil;
    self.checkBtn = nil;
    self.asset = nil;
    self.CheckImage = NULL;
    self.JudgeWhetherMaximize = NULL;
    NSLog(@"HEThumbnailCell dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
    }
    return self;
}

- (void)setup {
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.image = UIImageFromPhotoBundle(@"defaultphoto");
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;

    [self.contentView addSubview:self.imageView];
    
    self.checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.checkBtn setBackgroundImage:UIImageFromPhotoBundle(@"btn_unselected") forState:UIControlStateNormal];
    [self.checkBtn setBackgroundImage:UIImageFromPhotoBundle(@"btn_unselected") forState:UIControlStateHighlighted];
    [self.checkBtn setBackgroundImage:UIImageFromPhotoBundle(@"btn_selected") forState:UIControlStateSelected];
    self.checkBtn.frame = CGRectMake(self.contentView.right - 23 - 2, 2, 23, 23);
    [self.checkBtn addTarget:self action:@selector(onCheckImageAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.checkBtn];
}

- (void)onCheckImageAction:(UIButton *)button {
    
    if (!button.selected) {
        // 判断是否达到了最大量
        if (self.JudgeWhetherMaximize) {
            BOOL result = self.JudgeWhetherMaximize();
            if (result) {       // 结果：已达到最大量，直接return
                return;
            }
        }
    }
    
    button.selected = !button.selected;
    
    if (button.selected) {
        [button.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
    }
    
    if (self.CheckImage) {
        self.CheckImage(self.imageView.image, self.asset, button.selected);
    }
}

- (void)setAsset:(PHAsset *)asset {
    if (asset) {
        _asset = asset;
        
        CGSize size = self.frame.size;
        size.width *= 2.5;
        size.height *= 2.5;
        
        WS(weakSelf)
        [[HEPhotoTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeExact complete:^(UIImage *image, NSDictionary *info) {
            weakSelf.imageView.image = image;
        }];
    }
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    self.checkBtn.selected = checked;
}

@end
