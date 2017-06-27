//
//  HEClipImageViewController.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/27.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface HEClipImageViewController : UIViewController

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, assign) CGFloat clipRatio;    // 宽高比，宽/高，取值范围0~1
@property (nonatomic, assign) CGFloat clipWidth;    // 自定义剪切的宽高值
@property (nonatomic, assign) CGFloat clipHeight;

@end
