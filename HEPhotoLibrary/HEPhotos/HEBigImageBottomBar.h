//
//  HEBigImageBottomBar.h
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/14.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HEBigImageBottomBar : UIView

@property (nonatomic, copy) void(^BlockOnClickSureButton)();

- (void)changeDoneBtnTitleWithSelectedImageCount:(NSInteger)count;
@end
