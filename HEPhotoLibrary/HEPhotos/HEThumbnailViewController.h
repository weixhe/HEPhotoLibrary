//
//  HEThumbnailViewController.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/4.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
/*!
 *  @brief 缩略图的控制器，显示小的缩略图，可以进行选择
 */
@interface HEThumbnailViewController : UIViewController

@property (nonatomic, strong) NSArray <PHAsset *> *assets;       // 所有的图片资源数据源

@property (nonatomic, strong) NSMutableArray <PHAsset *> *selectedAsset;        // 已经选中的资源

@property (nonatomic, assign) NSUInteger maxSelectCount;   // 最多选择几张图片

@property (nonatomic, copy) void (^BlockOnFinishToSelectImage)(NSArray <PHAsset *> *assets);  // 完成选择回调

@property (nonatomic, assign) BOOL clickToShowBigImage; // 是否点击看大图，如果是，则查看大图，否则，选中该图片

@property (nonatomic, assign) BOOL isSingle;        // 是否为单选，如果为单选，可以进行截屏
@property (nonatomic, assign) BOOL canEdit;         // 是否能够编辑（移动，放缩）, 默认是YES
@property (nonatomic, assign) CGFloat clipWidth;    // 自定义剪切的宽高值
@property (nonatomic, assign) CGFloat clipHeight;
@property (nonatomic, assign) CGPoint clipCenter;
@property (nonatomic, copy) void (^BlockOnFinishClipImage)(UIImage *clipImage);

@end
