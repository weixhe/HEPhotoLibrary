//
//  HEBigImageView.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/13.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface HEBigImageView : UIView

@property (nonatomic, copy) void (^BlockOnClickBigImage)();

@property (nonatomic, copy) void (^BlockOnCurrentImage)(NSUInteger index);

- (instancetype)initWithAssets:(NSArray <PHAsset *> *)assets currentIndex:(NSUInteger)index;

@end

