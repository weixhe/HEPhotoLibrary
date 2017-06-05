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

@interface HEPhotoAlbumModel : NSObject

@property (nonatomic, copy) NSString *title;                        // 相册名字
@property (nonatomic, assign) NSInteger count;                      // 该相册内相片数量
@property (nonatomic, strong) PHAsset *headImageAsset;              // 相册第一张图片缩略图
@property (nonatomic, strong) PHAssetCollection *assetCollection;   // 相册集，通过该属性获取该相册集下所有照片

@end

@interface HEPhotoTool : NSObject

+ (instancetype)sharePhotoTool;

/*!
 * @brief 保存图片到系统相册
 */
- (void)saveImageToAlbum:(UIImage *)image completion:(void (^)(BOOL suc, PHAsset *asset))completion;

#pragma mark - 获取所有相册列表
/*!
 *  @brief 获取相机胶卷
 */
- (NSArray <HEPhotoAlbumModel *> *)getPhotoAlbumForCameraRoll;

/*!
 *  @brief 获取用户自定义的相册
 */
- (NSArray <HEPhotoAlbumModel *> *)getPhotosAlbumForUsers;

/*!
 *   @brief 获取所有相册列表
 */
- (NSArray<HEPhotoAlbumModel *> *)getAllPhotoAblumList;

#pragma mark - 获取指定相册内的所有图片

/*!
 *  @brief 获取指定相册内的所有图片
 */
- (NSArray<PHAsset *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;

#pragma mark - 获取相册内所有照片资源
/*!
 *  @brief 直接从相簿中获取所有的图片，不分单个相册
 */
- (NSArray <PHAsset *> *)getAllAssetInPhotoAlumbWithAscending:(BOOL)ascending;

#pragma mark - 获取asset对应的图片

/*!
 *  @brief resizeMode：对请求的图像怎样缩放::None-默认加载方式；  Fast-尽快地提供接近或稍微大于要求的尺寸； Exact-精准提供要求的尺寸。
 */
- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode
                    complete:(void(^)(UIImage *, NSDictionary *))complete;

/*!
 * @brief 点击确定时，获取每个Asset对应的图片（imageData）
 */
- (void)requestImageForAsset:(PHAsset *)asset scale:(CGFloat)scale resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *image))completion;

/*!
 * @brief 获取数组内图片的字节大小
 */
- (void)getPhotosBytesWithArray:(NSArray *)photos completion:(void (^)(NSString *photosBytes))completion;


/*!
 * @brief 判断图片是否存储在本地/或者已经从iCloud上下载到本地
 */
- (BOOL)judgeAssetisInLocalAlbum:(PHAsset *)asset;

@end
