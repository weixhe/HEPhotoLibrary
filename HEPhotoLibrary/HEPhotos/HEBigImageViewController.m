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
#import "HEBigImageBottomBar.h"
#import "HEBigImageView.h"

#define kItemMargin 30

/////// BigImageCell 不建议设置太大，太大的话会导致图片加载过慢
#define kMaxImageWidth 500

@interface HEBigImageViewController ()

@property (nonatomic, strong) HEBigImageBottomBar *bottomBar;

@property (nonatomic, strong) UIButton *selectBtn;
@end

@implementation HEBigImageViewController
- (void)dealloc
{
    self.assets = nil;
    self.selectedAsset = nil;
    self.bottomBar = nil;
    self.selectBtn = nil;
    self.BlockOnRefrashData = NULL;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self layoutNavigation];
    [self setupCollectionView];
    
    [self changeNavTitleAndBtnStatus:self.selectIndex];
    // [self setupBottomBar];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 判断是否已选中
    BOOL result = [self.selectedAsset containsObject:[self.assets objectAtIndex:self.selectIndex - 1]];
    [self changeNavRightBtnStatus:result ? YES : NO];
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

    
    self.selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectBtn.frame = CGRectMake(0, 0, 25, 25);
    self.selectBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 25, 0, -25);
    [self.selectBtn setBackgroundImage:UIImageFromPhotoBundle(@"btn_unselected") forState:UIControlStateNormal];
    [self.selectBtn setBackgroundImage:UIImageFromPhotoBundle(@"btn_unselected") forState:UIControlStateHighlighted];
    [self.selectBtn setBackgroundImage:UIImageFromPhotoBundle(@"btn_selected") forState:UIControlStateSelected];
    [self.selectBtn addTarget:self action:@selector(onSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.selectBtn];
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
    
    bigView.BlockOnCurrentImage = ^(NSUInteger index) {
      
        self.selectIndex = index;
        // 更新title
        [weakSelf changeNavTitleAndBtnStatus:index];
        
        // 判断是否已选中
        BOOL result = [weakSelf.selectedAsset containsObject:[weakSelf.assets objectAtIndex:index - 1]];
        [weakSelf changeNavRightBtnStatus:result ? YES : NO];
    };
}

- (void)setupBottomBar {
    self.bottomBar = [[HEBigImageBottomBar alloc] initWithFrame:CGRectMake(0, kViewHeight - 44, kViewWidth, 44)];
    [self.view addSubview:self.bottomBar];
    
    WS(weakSelf)
    self.bottomBar.BlockOnClickSureButton = ^{
      
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
}

- (void)hidenNavigationBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    CGRect frame = self.bottomBar.frame;
    frame.origin.y += frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomBar.frame = frame;
    }];
}

- (void)showNavigationBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    CGRect frame = self.bottomBar.frame;
    frame.origin.y -= frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomBar.frame = frame;
    }];
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
            ShowToast(@"%@", LocalizedStringForKey(kTextForReachedMax));
            return;
        }
    }
    
    [self changeNavRightBtnStatus:!button.selected];
    
    // 更新数据源
    PHAsset *asset = [self.assets objectAtIndex:self.selectIndex - 1];
    if (button.selected) {
        if (![self.selectedAsset containsObject:asset]) {
            [self.selectedAsset addObject:asset];
        }
    } else {
        if ([self.selectedAsset containsObject:asset]) {
            [self.selectedAsset removeObject:asset];
        }
    }
    
    if (self.BlockOnRefrashData) {
        self.BlockOnRefrashData(asset, button.selected);
    }
}

#pragma mark - 更新title和按钮状态
- (void)changeNavTitleAndBtnStatus:(NSUInteger)index {
    
    self.title = [NSString stringWithFormat:@"%ld/%ld", index, self.assets.count];
}

- (void)changeNavRightBtnStatus:(BOOL)isSelect {
    self.selectBtn.selected = isSelect;
    if (self.selectBtn.selected) {
        [self.selectBtn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
    }
}
@end
