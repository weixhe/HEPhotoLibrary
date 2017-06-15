//
//  HEBigImageViewController.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/13.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface HEBigImageViewController : UIViewController

@property (nonatomic, strong) NSArray <PHAsset *> *assets;       // 所有的图片资源数据源

@property (nonatomic, assign) NSUInteger selectIndex; // 选中的图片下标

@property (nonatomic, strong) NSMutableArray <PHAsset *> *selectedAsset;        // 已经选中的资源

@property (nonatomic, assign) NSUInteger maxSelectCount;   // 最多选择几张图片

@property (nonatomic, assign) BOOL isPresent; // 该界面显示方式，预览界面查看大图进来是present，从相册小图进来是push

// 回调刷新
@property (nonatomic, copy) void (^BlockOnRefrashData)(PHAsset *asset, BOOL isAdd);

@end
