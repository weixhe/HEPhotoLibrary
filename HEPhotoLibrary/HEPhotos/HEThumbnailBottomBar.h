//
//  HEThumbnailBottomBar.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/4.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface HEThumbnailBottomBar : UIView

@property (nonatomic, assign) NSInteger maxSelectCount;   // 最多选择几张图片
@property (nonatomic, copy) void (^DeleteOneImage)(UIImage *image, PHAsset *asset);

- (void)addImage:(UIImage *)image asset:(PHAsset *)asset;
- (void)deleteImage:(UIImage *)image asset:(PHAsset *)asset;

@end
