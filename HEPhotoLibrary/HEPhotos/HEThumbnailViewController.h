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

@property (nonatomic, strong) PHAssetCollection *assetCollection;       // 相册

@property (nonatomic, strong) NSMutableArray <PHAsset *> *checkedAsset;        // 已经选中的资源

@end
