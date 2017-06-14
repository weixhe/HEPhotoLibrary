//
//  HEBigImageCell.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/13.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface HEBigImageCell : UICollectionViewCell

@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, copy) void(^BlockOnSingalTap)();
@end