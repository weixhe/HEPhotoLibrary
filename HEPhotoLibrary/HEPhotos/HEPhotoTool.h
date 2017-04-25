//
//  HEPhotoTool.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/4/24.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface HEPhotoAblumList : NSObject

@property (nonatomic, copy) NSString *title;                        // 相册名字
@property (nonatomic, assign) NSInteger count;                      // 该相册内相片数量
@property (nonatomic, strong) PHAsset *headImageAsset;              // 相册第一张图片缩略图
@property (nonatomic, strong) PHAssetCollection *assetCollection;   // 相册集，通过该属性获取该相册集下所有照片

@end

@interface HEPhotoTool : NSObject

+ (instancetype)sharePhotoTool;

#pragma mark - 获取所有相册列表
/*!
 *  @brief 获取用户所有相册列表
 */
- (NSArray <HEPhotoAblumList *> *)getPhotoAblumList;

#pragma mark - 获取指定相册内的所有图片

/*!
 *  @brief 获取指定相册内的所有图片
 */
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;

#pragma mark - 获取相册内所有照片资源
/*!
 *  @brief 直接从相簿中获取所有的图片，部分单个相册
 */
- (NSArray <PHAsset *> *)getAllAssetInPhotoAlumbWithAscending:(BOOL)ascending;

@end
