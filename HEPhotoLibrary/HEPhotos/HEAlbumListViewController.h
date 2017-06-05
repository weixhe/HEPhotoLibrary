//
//  HEAlbumListViewController.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/4/27.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

/*!
 *  @brief 相簿列表（分相机胶卷和用户自定义的相册）
 */
@interface HEAlbumListViewController : UIViewController

@property (nonatomic, strong) NSMutableArray <PHAsset *> *selectedAsset;        // 已经选中的资源

@property (nonatomic, assign) NSInteger maxSelectCount;   // 最多选择几张图片

@end
