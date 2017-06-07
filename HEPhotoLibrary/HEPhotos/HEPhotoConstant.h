//
//  HEPhotoConstant.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/3.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#ifndef HEPhotoConstant_h
#define HEPhotoConstant_h

/*========================================输出打印============================================*/
#ifdef DEBUG
#define PhotoLog(xx, ...)  NSLog(@"%s(%d行):\t\t" xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define PhotoLog(xx, ...)
#endif


#define WS(weakSelf)        __weak __typeof(&*self)weakSelf = self;
#define weakify(var)        __weak typeof(var) weakSelf = var;
#define strongify(var)      __strong typeof(var) weakSelf = var;
#define kViewWidth      [[UIScreen mainScreen] bounds].size.width
// 如果项目中设置了导航条为不透明，即[UINavigationBar appearance].translucent=NO，那么这里的kViewHeight需要-64
#define kViewHeight     [[UIScreen mainScreen] bounds].size.height

#define CollectionName [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]


static inline NSBundle * PhotosBundle();

/// 应用没有权限
static NSString * const kAccessAuthorityStatusRestricted        = @"应用没有相关权限，且当前用户无法改变这个权限";
/// 用户拒绝访问相簿
static NSString * const kAccessAuthorityStatusDenied            = @"您已拒绝app访问相簿，若想访问，请到设置中赋予权限";

static NSString * const kTextForPhotoList                       = @"photo list";
static NSString * const kTextForCancel                          = @"cancel";
static NSString * const kTextForCameraRoll                      = @"Camera Roll";
static NSString * const kTextForRecentlyAdd                     = @"Recently Added";
static NSString * const kTextForTip                             = @"tip";
static NSString * const kTextForIKnow                           = @"i know";
static NSString * const kTextForSure                            = @"sure";

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

static inline UIImage *UIImageFromPhotoBundle(NSString *imageName) {
    NSString *path = nil;
    
    NSString *extension = imageName.pathExtension;
    NSString *compent = imageName.stringByDeletingPathExtension;
    
    if ([extension isEqualToString:@"jpg"]) {
        path = [PhotosBundle() pathForResource:compent ofType:@"jpg"];
    } else if ([extension isEqualToString:@"jpeg"]) {
        path = [PhotosBundle() pathForResource:compent ofType:@"jpeg"];
    } else if ([extension isEqualToString:@"png"]) {
        path = [PhotosBundle() pathForResource:compent ofType:@"png"];
    } else {
        if (extension.length == 0) {
            UIImage *image = nil;
            path = [PhotosBundle().resourcePath stringByAppendingFormat:@"/%@.png", imageName];         // 优先尝试png
            image = [UIImage imageWithContentsOfFile:path];
            if (image) {
                return image;
            } else {
                path = [PhotosBundle().resourcePath stringByAppendingFormat:@"/%@.jpg", imageName];     // 再次尝试jpg
                image = [UIImage imageWithContentsOfFile:path];
            }
            
            if (image) {
                return image;
            } else {
                path = [PhotosBundle().resourcePath stringByAppendingFormat:@"/%@.jpeg", imageName];     // 再次尝试jpeg
                image = [UIImage imageWithContentsOfFile:path];
            }
            
            if (image) {
                return image;
            } else {
                PhotoLog(@"特殊图片文件后缀，请添加处理方式");
            }
            
        } else {
            PhotoLog(@"特殊图片文件后缀，请添加处理方式");
        }
    }
    return [UIImage imageWithContentsOfFile:path];
}

static inline NSBundle * PhotosBundle() {
    
    /* 如果需要适配pod 1.x和0.x，则使用如下方法获取路径
        NSString *path = [[NSBundle bundleForClass:[HEPhotoTool class]] pathForResource:@"HEPhotos" ofType:@"bundle"];
     */
    NSString *path = [[NSBundle mainBundle] pathForResource:@"HEPhotos" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    return bundle;
}

static inline NSString * LocalizedStringForKey(NSString *key) {
    static NSBundle *bundle = nil;
    if (bundle == nil) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language hasPrefix:@"en"]) {
            language = @"en";
        } else if ([language hasPrefix:@"zh"]) {
            if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                language = @"zh-Hans"; // 简体中文
            } else { // zh-Hant\zh-HK\zh-TW
                language = @"zh-Hant"; // 繁體中文
            }
        } else if ([language hasPrefix:@"ja"]) {
            language = @"ja-US";
        } else {
            language = @"en";
        }
        
        // 从HEPhotos.bundle中查找资源
        bundle = [NSBundle bundleWithPath:[PhotosBundle() pathForResource:language ofType:@"lproj"]];
    }
    
    
    NSString *value = [bundle localizedStringForKey:key value:nil table:nil];
    return value;
}







#endif /* HEPhoto_h */
