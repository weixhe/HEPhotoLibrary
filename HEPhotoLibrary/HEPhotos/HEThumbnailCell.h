//
//  HEThumbnailCell.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/4.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface HEThumbnailCell : UICollectionViewCell

@property (nonatomic, copy) void (^CheckImage)(UIImage *image, PHAsset *asset, BOOL check);

@property (nonatomic, strong) PHAsset *asset;   // 资源，可以转换成图片

@property (nonatomic, assign) BOOL checked;

@end
