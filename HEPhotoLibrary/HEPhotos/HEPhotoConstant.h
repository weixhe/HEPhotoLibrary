//
//  HEPhotoConstant.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/3.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#ifndef HEPhotoConstant_h
#define HEPhotoConstant_h

#define kPhotoWidth      [[UIScreen mainScreen] bounds].size.width
#define kPhotoHeight     [[UIScreen mainScreen] bounds].size.height

#define CollectionName [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]

#define HEPhotoImageFromBundleWithName(imageName) [UIImage imageNamed:[@"HEPhotos.bundle" stringByAppendingPathComponent:imageName]]

#endif /* HEPhoto_h */
