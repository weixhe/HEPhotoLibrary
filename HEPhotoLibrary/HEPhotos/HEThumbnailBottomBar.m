//
//  HEThumbnailBottomBar.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/4.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEThumbnailBottomBar.h"

@interface HEThumbnailBottomBar ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation HEThumbnailBottomBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 5, self.width - self.height, self.height - 10)];
    [self addSubview:self.scrollView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.right, 5, self.height - 10, self.height - 10)];
    view.backgroundColor = [UIColor redColor];
    view.layer.cornerRadius = (self.height - 10) / 2;
    view.layer.masksToBounds = YES;
    [self addSubview:view];
    
    self.countLabel = [[UILabel alloc] initWithFrame:view.bounds];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.text = @"5/10";
    [view addSubview:self.countLabel];
}

@end
