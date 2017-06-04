//
//  HEThumbnailBottomBar.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/4.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEThumbnailBottomBar.h"
#import "HEPhotoConstant.h"

@interface HEThumbnailBottomBar () {

}

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation HEThumbnailBottomBar
- (void)dealloc
{
    [self.dataSource removeAllObjects];
    self.dataSource = nil;
    
    self.scrollView = nil;
    self.countLabel = nil;
    NSLog(@"HEThumbnailBottomBar 释放");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataSource = [NSMutableArray array];
        [self setup];
    }
    return self;
}

- (void)setup {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width - self.height, self.height)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.right + 5, 5, self.height - 10, self.height - 10)];
    view.backgroundColor = [UIColor redColor];
    view.layer.cornerRadius = (self.height - 10) / 2;
    view.layer.masksToBounds = YES;
    [self addSubview:view];
    
    self.countLabel = [[UILabel alloc] initWithFrame:view.bounds];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.text = [NSString stringWithFormat:@"0/%ld", self.maxCount];
    [view addSubview:self.countLabel];
}

- (UIImageView *)generateImageViewWithImage:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 10, self.scrollView.height - 15, self.scrollView.height - 15);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    deleteBtn.backgroundColor = [UIColor redColor];
    deleteBtn.center = CGPointMake(imageView.right, 0);
    [imageView addSubview:deleteBtn];
    
    return imageView;
}

- (void)resetFrame {
    CGFloat willSetX = 0;
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        UIImageView *imageView = (UIImageView *)[self.scrollView.subviews objectAtIndex:i];
        willSetX = i * (imageView.width + 8) + 2;
        if (imageView.x != willSetX) {
            imageView.x = willSetX;
        }
    }
}

- (void)addImage:(UIImage *)image {
    if (self.dataSource.count == 0 && self.scrollView.subviews.count != 0) {
        [self.scrollView removeAllSubviews];
    }
    
    UIImageView *imageView = [self generateImageViewWithImage:image];
    imageView.x = self.dataSource.count * (imageView.width + 8) + 2;
    [self.dataSource addObject:image];
    [self.scrollView addSubview:imageView];
    self.scrollView.contentSize = CGSizeMake(self.dataSource.count * (imageView.width + 8), self.scrollView.height);
    
//    [self resetFrame];
    [self.scrollView scrollRectToVisible:CGRectMake(imageView.x, imageView.y, imageView.width + 8, self.scrollView.height) animated:YES];
    self.countLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.dataSource.count, self.maxCount];

}

- (void)deleteImage:(UIImage *)image {
    
}

@end
