//
//  HEPhotoTool.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/4/24.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEPhotoTool.h"

@implementation HEPhotoAblumList


@end




#pragma mark -|

static HEPhotoTool *instance = nil;
@implementation HEPhotoTool

+ (instancetype)sharePhotoTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HEPhotoTool alloc] init];
    });
    return instance;
}

#pragma mark - 获取所有相册列表

/*!
 *  @brief 获取用户所有相册列表，并遍历相册，获取每个相册的相关信息（相册名，照片个数，第一种缩略图等）
 */
- (NSArray <HEPhotoAblumList *> *)getPhotoAblumList {
    
    NSMutableArray *array = [NSMutableArray array];
    
    // 获取所有的智能相册
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 遍历每个相册, 从相册中取asset
    [result enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 过滤掉视频和已删除
        if (collection.assetCollectionSubtype != 202 || collection.assetCollectionSubtype < 212) {
            
            // 从相册中取资源
            NSArray <PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:NO];
            if (assets.count != 0) {
                HEPhotoAblumList *ablum = [[HEPhotoAblumList alloc] init];
                ablum.title = collection.localizedTitle;            // 相册名字
                ablum.count = assets.count;                         // 该相册内相片数量
                ablum.headImageAsset = assets.firstObject;          // 相册第一张图片缩略图
                ablum.assetCollection = collection;                 // 相册集，通过该属性获取该相册集下所有照片
                
                [array addObject:ablum];
            }
        }
        
    }];
    return array;
}

/*!
 *  @brief 获取指定相册内的所有图片
 */
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending {
    
    NSMutableArray <PHAsset *> *array = [NSMutableArray array];
    
    PHFetchResult *result = [self fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        if (asset.mediaType == PHAssetMediaTypeImage) {
            // 取出来图片
            [array addObject:asset];
        }
    }];
    return array;
}


- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)collection ascending:(BOOL)ascending {
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
    return result;
}
























@end
