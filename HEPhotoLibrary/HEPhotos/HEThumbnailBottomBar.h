//
//  HEThumbnailBottomBar.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/4.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEThumbnailBottomBar : UIView

@property (nonatomic, assign) NSInteger maxCount;   // 最多几张图片

- (void)addImage:(UIImage *)image;
- (void)deleteImage:(UIImage *)image;

@end
