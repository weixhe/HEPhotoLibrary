//
//  HEPhotoTool.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/4/24.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface HEPhotoAblumList : NSObject

@property (nonatomic, copy) NSString *title;                        // 相册名字
@property (nonatomic, assign) NSInteger count;                      // 该相册内相片数量
@property (nonatomic, strong) PHAsset *headImageAsset;              // 相册第一张图片缩略图
@property (nonatomic, strong) PHAssetCollection *assetCollection;   // 相册集，通过该属性获取该相册集下所有照片

@end

@interface HEPhotoTool : NSObject

+ (instancetype)sharePhotoTool;

/*!
 *  @brief 获取用户所有相册列表
 */
- (NSArray <HEPhotoAblumList *> *)getPhotoAblumList;

@end
