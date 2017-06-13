//
//  HEBigImageViewController.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/13.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEBigImageViewController.h"
#import "ToastUtils.h"
#import "HEPhotoConstant.h"

#import "HEBigImageView.h"

#define kItemMargin 30

/////// BigImageCell 不建议设置太大，太大的话会导致图片加载过慢
#define kMaxImageWidth 500

@interface HEBigImageViewController ()


@end

@implementation HEBigImageViewController
- (void)dealloc
{
    self.assets = nil;
    self.selectedAsset = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self layoutNavigation];
    [self setupCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutNavigation {

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -25, 0, 25);
    [backBtn setImage:UIImageFromPhotoBundle(@"nav_back_black") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBackToPrivous:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];

    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(0, 0, 25, 25);
    selectBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 25, 0, -25);
    [selectBtn setBackgroundImage:UIImageFromPhotoBundle(@"btn_unselected") forState:UIControlStateNormal];
    [selectBtn setBackgroundImage:UIImageFromPhotoBundle(@"btn_unselected") forState:UIControlStateHighlighted];
    [selectBtn setBackgroundImage:UIImageFromPhotoBundle(@"btn_selected") forState:UIControlStateSelected];
    [selectBtn addTarget:self action:@selector(onSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:selectBtn];
}

- (void)setupCollectionView {
    HEBigImageView *bigView = [[HEBigImageView alloc] initWithAssets:self.assets currentIndex:self.selectIndex];
    [self.view addSubview:bigView];
    
    WS(weakSelf)
    bigView.BlockOnClickBigImage = ^{
        
        if (weakSelf.navigationController.navigationBar.isHidden) {
            [weakSelf showNavigationBar];
        } else {
            [weakSelf hidenNavigationBar];
        }
    };
}

- (void)hidenNavigationBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)showNavigationBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - UIButton Action
- (void)onBackToPrivous:(UIButton *)button {
    
    if (self.isPresent) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onSelectAction:(UIButton *)button {
    
    if (!button.selected) {
        // 判断是否达到了最大量
        if (self.selectedAsset.count == self.maxSelectCount) {
            ShowToast(@"已经达到了最大量了");
            return;
        }
    }
    
    button.selected = !button.selected;

}

@end
