//
//  HEPhotoConstant.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/3.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#ifndef HEPhotoConstant_h
#define HEPhotoConstant_h

#define WS(weakSelf)        __weak __typeof(&*self)weakSelf = self;
#define weakify(var)        __weak typeof(var) weakSelf = var;
#define strongify(var)      __strong typeof(var) weakSelf = var;
#define ScreenWidth      [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight     [[UIScreen mainScreen] bounds].size.height

#define CollectionName [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]

#define HEPhotoImageFromBundleWithName(imageName) [UIImage imageNamed:[@"HEPhotos.bundle" stringByAppendingPathComponent:imageName]]


/// 应用没有权限
static NSString * const kAccessAuthorityStatusRestricted        = @"应用没有相关权限，且当前用户无法改变这个权限";
/// 用户拒绝访问相簿
static NSString * const kAccessAuthorityStatusDenied            = @"您已拒绝app访问相簿，若想访问，请到设置中赋予权限";
#endif /* HEPhoto_h */
