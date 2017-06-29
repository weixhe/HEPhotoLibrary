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
@property (nonatomic, assign) BOOL canEdit;         // 是否能够编辑（移动，放缩）, 默认是YES
@property (nonatomic, assign) CGFloat clipWidth;    // 自定义剪切的宽高值
@property (nonatomic, assign) CGFloat clipHeight;
@property (nonatomic, assign) CGPoint clipCenter;   // 默认为屏幕中心

@end
