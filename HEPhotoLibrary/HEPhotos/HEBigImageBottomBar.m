//
//  HEBigImageBottomBar.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/14.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEBigImageBottomBar.h"
#import "HEPhotoConstant.h"

@interface HEBigImageBottomBar ()

@property (nonatomic, strong) UIButton *doneBtn;

@end

@implementation HEBigImageBottomBar

- (void)dealloc
{
    self.doneBtn = nil;
    self.BlockOnClickSureButton = NULL;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setup {
    self.doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneBtn.frame = CGRectMake(kViewWidth - 82, 0, 70, 30);
    self.doneBtn.center = CGPointMake(self.doneBtn.center.x, self.frame.size.height / 2);
    self.doneBtn.layer.masksToBounds = YES;
    self.doneBtn.layer.cornerRadius = 3.0f;
    self.doneBtn.backgroundColor = [UIColor colorWithRed:30/255.0 green:180/255.0 blue:234/255.0 alpha:1];
    self.doneBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.doneBtn addTarget:self action:@selector(onSureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.doneBtn];
    
    [self changeDoneBtnTitleWithSelectedImageCount:0];
}

- (void)onSureAction:(UIButton *)button {
    if (self.BlockOnClickSureButton) {
        self.BlockOnClickSureButton();
    }
}

- (void)changeDoneBtnTitleWithSelectedImageCount:(NSInteger)count {
    if (count > 0) {
        [self.doneBtn setTitle:[NSString stringWithFormat:@"%@(%ld)", LocalizedStringForKey(kTextForSure), count] forState:UIControlStateNormal];
    } else {
        [self.doneBtn setTitle:LocalizedStringForKey(kTextForSure) forState:UIControlStateNormal];
    }
}

@end
