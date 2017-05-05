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
#define CollectionName [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]


@implementation HEPhotoAlbumModel


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

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

/*!
 * @brief 保存图片到系统相册
 */
- (void)saveImageToAlbum:(UIImage *)image completion:(void (^)(BOOL suc, PHAsset *asset))completion  {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {
        if (completion) completion(NO, nil);
    } else if (status == PHAuthorizationStatusRestricted) {
        if (completion) completion(NO, nil);
    } else {
        __block PHObjectPlaceholder *placeholderAsset=nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *newAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            placeholderAsset = newAssetRequest.placeholderForCreatedAsset;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                if (completion) completion(NO, nil);
                return;
            }
            PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
            PHAssetCollection *desCollection = [self getDestinationCollection];
            if (!desCollection) completion(NO, nil);
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:desCollection] addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completion) completion(success, asset);
            }];
        }];
    }

}

- (PHAsset *)getAssetFromlocalIdentifier:(NSString *)localIdentifier {
    if(localIdentifier == nil){
        NSLog(@"Cannot get asset from localID because it is nil");
        return nil;
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
    if(result.count){
        return result[0];
    }
    return nil;
}

// 获取自定义相册
- (PHAssetCollection *)getDestinationCollection {
    // 找是否已经创建自定义相册
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:CollectionName]) {
            return collection;
        }
    }
    // 新建自定义相册
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:CollectionName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"创建相册：%@失败", CollectionName);
        return nil;
    }
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}

#pragma mark - 获取所有相册列表

/*!
 *  @brief 获取用户所有相册列表，并遍历相册，获取每个相册的相关信息（相册名，照片个数，第一种缩略图等）
 */
- (NSArray <HEPhotoAlbumModel *> *)getPhotoAlbumList {
    
    NSMutableArray *array = [NSMutableArray array];
    
    // 1.获取所有的系统智能相册
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [result enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        // 过滤掉视频和已删除
        if (collection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumVideos || collection.assetCollectionSubtype < PHAssetCollectionSubtypeSmartAlbumDepthEffect) {
            // 从相册中取资源
            NSArray <PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:NO];
            if (assets.count != 0) {
                HEPhotoAlbumModel *album = [[HEPhotoAlbumModel alloc] init];
                album.title = collection.localizedTitle;            // 相册名字
                album.count = assets.count;                         // 该相册内相片数量
                album.headImageAsset = assets.firstObject;          // 相册第一张图片缩略图
                album.assetCollection = collection;                 // 相册集，通过该属性获取该相册集下所有照片
                [array addObject:album];
            }
        }
    }];
    
    // 2.获取用户自定义的相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        // 从相册中取资源
        NSArray <PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:NO];
        if (assets.count != 0) {
            HEPhotoAlbumModel *album = [[HEPhotoAlbumModel alloc] init];
            album.title = collection.localizedTitle;            // 相册名字
            album.count = assets.count;                         // 该相册内相片数量
            album.headImageAsset = assets.firstObject;          // 相册第一张图片缩略图
            album.assetCollection = collection;                 // 相册集，通过该属性获取该相册集下所有照片
            [array addObject:album];
        }
    }];
    
    return array;
}

/// 获取用户自定义的相册
- (NSArray <HEPhotoAlbumModel *> *)getUsersPhotosAlbum {
    NSMutableArray *array = [NSMutableArray array];
    
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [result enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        // 从相册中取资源
        NSArray <PHAsset *> *assets = [self getAssetsInAssetCollection:collection ascending:NO];
        if (assets.count != 0) {
            HEPhotoAlbumModel *album = [[HEPhotoAlbumModel alloc] init];
            album.title = collection.localizedTitle;            // 相册名字
            album.count = assets.count;                         // 该相册内相片数量
            album.headImageAsset = assets.firstObject;          // 相册第一张图片缩略图
            album.assetCollection = collection;                 // 相册集，通过该属性获取该相册集下所有照片
            [array addObject:album];
        }
    }];
    return array;
}

/// 获取相机胶卷
- (HEPhotoAlbumModel *)getCameraRollAlbum {
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    
    NSArray <PHAsset *> *assets = [self getAssetsInAssetCollection:cameraRoll ascending:NO];
    if (assets.count != 0) {
        HEPhotoAlbumModel *album = [[HEPhotoAlbumModel alloc] init];
        album.title = cameraRoll.localizedTitle;            // 相册名字
        album.count = assets.count;                         // 该相册内相片数量
        album.headImageAsset = assets.firstObject;          // 相册第一张图片缩略图
        album.assetCollection = cameraRoll;                 // 相册集，通过该属性获取该相册集下所有照片
        return album;
    }
    return nil;
}

/**
 *  遍历相簿中的所有图片
 *  @param assetCollection 相簿
 *  @param original        是否要原图
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    NSLog(@"相簿名:%@", assetCollection.localizedTitle);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        // 是否要原图
        CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
        
        // 从asset中获得图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            NSLog(@"%@", result);
        }];
    }
}

/*!
 *  @brief 获取指定相册内的所有图片
 */
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending {
    
    NSMutableArray <PHAsset *> *array = [NSMutableArray array];
    
    PHFetchResult <PHAsset *> *result = [self fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull asset, NSUInteger idx, BOOL * _Nonnull stop) {
        if (asset.mediaType == PHAssetMediaTypeImage) {
            // 取出来图片
            [array addObject:asset];
        }
    }];
    return array;
}


- (PHFetchResult <PHAsset *>*)fetchAssetsInAssetCollection:(PHAssetCollection *)collection ascending:(BOOL)ascending {
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult <PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
    return result;
}


#pragma mark - 获取相册内所有照片资源
/*!
 *  @brief 直接从相簿中获取所有的图片，不分单个相册
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

/*!
 * @brief 点击确定时，获取每个Asset对应的图片（imageData）
 */
- (void)requestImageForAsset:(PHAsset *)asset scale:(CGFloat)scale resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *image))completion
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = resizeMode;//控制照片尺寸
    option.networkAccessAllowed = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downloadFinined && completion) {
            CGFloat sca = imageData.length/(CGFloat)UIImageJPEGRepresentation([UIImage imageWithData:imageData], 1).length;
            NSData *data = UIImageJPEGRepresentation([UIImage imageWithData:imageData], scale==1?sca:sca/2);
            completion([UIImage imageWithData:data]);
        }
    }];
}

/*!
 * @brief 获取数组内图片的字节大小
 */
- (void)getPhotosBytesWithArray:(NSArray <PHAsset *> *)photos completion:(void (^)(NSString *photosBytes))completion
{
    __block NSInteger dataLength = 0;
    
    __block NSInteger count = photos.count;
    
    __weak typeof(self) weakSelf = self;
    for (int i = 0; i < photos.count; i++) {

        [[PHCachingImageManager defaultManager] requestImageDataForAsset:photos[i] options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dataLength += imageData.length;
            count--;
            if (count <= 0) {
                if (completion) {
                    completion([strongSelf transformDataLength:dataLength]);
                }
            }
        }];
    }
}

- (NSString *)transformDataLength:(NSInteger)dataLength {
    NSString *bytes = @"";
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}

/*!
 * @brief 判断图片是否存储在本地/或者已经从iCloud上下载到本地
 */
- (BOOL)judgeAssetisInLocalAlbum:(PHAsset *)asset {
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    
    __block BOOL isInLocalAlbum = YES;
    
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isInLocalAlbum = imageData ? YES : NO;
    }];
    return isInLocalAlbum;
}

@end
