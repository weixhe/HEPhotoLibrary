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

@property (nonatomic, assign) NSUInteger maxSelectCount;   // 最多选择几张图片
@property (nonatomic, strong) NSMutableArray <PHAsset *> *selectedAsset;        // 已经选中的资源
@property (nonatomic, assign) CGSize size;  // 用户请求图片

@property (nonatomic, copy) void (^DeleteOneImage)(UIImage *image, PHAsset *asset);
@property (nonatomic, copy) void (^FinishToSelectImage)();  // 完成选择

// 以下两个方法的image属性没有使用，可传nil
- (void)addImage:(UIImage *)image asset:(PHAsset *)asset;
- (void)deleteImage:(UIImage *)image asset:(PHAsset *)asset;

@end
