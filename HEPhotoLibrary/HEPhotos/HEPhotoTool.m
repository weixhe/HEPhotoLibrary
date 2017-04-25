//
//  HEPhotoTool.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/4/24.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEPhotoTool.h"

#define kViewWidth      [[UIScreen mainScreen] bounds].size.width
#define kViewHeight     [[UIScreen mainScreen] bounds].size.height


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
    
    // 1.获取所有的系统智能相册
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
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
    
    // 2.获取用户自定义的相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
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


#pragma mark - 获取相册内所有照片资源
/*!
 *  @brief 直接从相簿中获取所有的图片，部分单个相册
 */
- (NSArray <PHAsset *> *)getAllAssetInPhotoAlumbWithAscending:(BOOL)ascending {
    
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];

    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    // ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];

    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        [assets addObject:asset];
    }];
    
    return assets;
}


#pragma mark - 获取asset对应的图片

/*!
 *  @brief resizeMode：对请求的图像怎样缩放::None-默认加载方式；  Fast-尽快地提供接近或稍微大于要求的尺寸； Exact-精准提供要求的尺寸。
 */

- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode
                    complete:(void(^)(UIImage *, NSDictionary *))complete {
    // 请求大图界面，当切换图片时，取消上一张图片的请求，对于iCloud端的图片，可以节省流量
    static PHImageRequestID requestID = -1;
    CGFloat scale = [UIScreen mainScreen].scale;        // @1x, @2x, @3x
    CGFloat width = MIN(kViewWidth, kViewHeight);
    
    if (requestID >= 1 && size.width / width == scale) {
        // 取消请求
        [[PHCachingImageManager defaultManager] cancelImageRequest:requestID];
    }
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];

    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：
     None，默认加载方式；
     Fast，尽快地提供接近或稍微大于要求的尺寸；
     Exact，精准提供要求的尺寸。
     
     deliveryMode：图像质量。有三种值：
     Opportunistic，在速度与质量中均衡；
     HighQualityFormat，不管花费多长时间，提供高质量图像；
     FastFormat，以最快速度提供好的质量。
     
     这个属性只有在 synchronous 为 true 时有效。
     */
    option.resizeMode = resizeMode;
    option.networkAccessAllowed = YES;   // YES-接受从iCloud下载，NO-不接受iCloud
    option.synchronous = YES;
    
    /*
     info字典提供请求状态信息:
     PHImageResultIsInCloudKey：图像是否必须从iCloud请求
     PHImageResultIsDegradedKey：当前UIImage是否是低质量的，这个可以实现给用户先显示一个预览图
     PHImageResultRequestIDKey和PHImageCancelledKey：请求ID以及请求是否已经被取消
     PHImageErrorKey：如果没有图像，字典内的错误信息
     */
    requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        //不要该判断，即如果该图片在iCloud上时候，会先显示一张模糊的预览图，待加载完毕后会显示高清图
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && complete) {
            complete(image, info);
        }
    }];
}
















@end
