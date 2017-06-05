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
#define kViewWidth      [[UIScreen mainScreen] bounds].size.width
// 如果项目中设置了导航条为不透明，即[UINavigationBar appearance].translucent=NO，那么这里的kViewHeight需要-64
#define kViewHeight     [[UIScreen mainScreen] bounds].size.height

#define CollectionName [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]

#define HEPhotoImageFromBundleWithName(imageName) [UIImage imageNamed:[@"HEPhotos.bundle" stringByAppendingPathComponent:imageName]]


/// 应用没有权限
static NSString * const kAccessAuthorityStatusRestricted        = @"应用没有相关权限，且当前用户无法改变这个权限";
/// 用户拒绝访问相簿
static NSString * const kAccessAuthorityStatusDenied            = @"您已拒绝app访问相簿，若想访问，请到设置中赋予权限";






static inline CAKeyframeAnimation * GetBtnStatusChangedAnimation() {
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animate.duration = 0.3;
    animate.removedOnCompletion = YES;
    animate.fillMode = kCAFillModeForwards;
    
    animate.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    return animate;
}









#endif /* HEPhoto_h */
