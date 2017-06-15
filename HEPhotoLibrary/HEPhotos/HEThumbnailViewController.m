//
//  HEThumbnailViewController.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/6/4.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEThumbnailViewController.h"
#import "HEPhotoConstant.h"
#import "HEThumbnailCell.h"
#import "HEPhotoTool.h"
#import "HEThumbnailBottomBar.h"
#import "HEBigImageViewController.h"
#import "ToastUtils.h"

#define Cell_Item_Space 2
#define Cell_Line_Space 2
#define Cell_Item_Num   4       // 一行显示4个item

#define Height_BottomView   70

@interface HEThumbnailViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    CGFloat cellWidth;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray <PHAsset *> *dataSource;

@property (nonatomic, strong) HEThumbnailBottomBar *bottomBar;

@end

@implementation HEThumbnailViewController
- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    self.collectionView = nil;
    self.dataSource = nil;
    self.bottomBar = nil;
    self.selectedAsset = nil;
    self.assets = nil;
    self.FinishToSelectImage = NULL;
    PhotoLog(@"HEThumbnailViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 背景图片
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image = UIImageFromPhotoBundle(@"background_1.jpeg");
    [self.view addSubview:bgImageView];

    // 处理数据源, 从相册中取出所有的资源asset
    self.dataSource = self.assets;
    
    [self layoutNavigation];
    [self setupCollectionView];
    [self setupBottomBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)layoutNavigation {
    
    self.navigationItem.hidesBackButton = YES;
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0, 60, 44);
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    cancelBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, -15);
    [cancelBtn setTitle:LocalizedStringForKey(kTextForCancel) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(onCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -25, 0, 25);
    [backBtn setImage:UIImageFromPhotoBundle(@"nav_back_black") forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBackToPrivous:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}


- (void)setupCollectionView {
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, kViewWidth, self.view.height - Height_BottomView - 64) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[HEThumbnailCell class] forCellWithReuseIdentifier:@"HEThumbnailCell"];
    [self.view addSubview:self.collectionView];
    
    cellWidth = (self.collectionView.width - (Cell_Item_Num - 1) * Cell_Item_Space) / Cell_Item_Num;
}

- (void)setupBottomBar {
    self.bottomBar = [[HEThumbnailBottomBar alloc] initWithFrame:CGRectMake(0, self.view.bottom - Height_BottomView, kViewWidth, Height_BottomView)];
    self.bottomBar.maxSelectCount = self.maxSelectCount;
    self.bottomBar.size = CGSizeMake(cellWidth * 2.5, cellWidth * 2.5);
    self.bottomBar.selectedAsset = self.selectedAsset;
    
    [self.view addSubview:self.bottomBar];
    WS(weakSelf)
    self.bottomBar.DeleteOneImage = ^(UIImage *image, PHAsset *asset) {
        if ([weakSelf.selectedAsset containsObject:asset]) {
            [weakSelf.selectedAsset removeObject:asset];
            [weakSelf.collectionView reloadData];
        }
    };
    
    self.bottomBar.FinishToSelectImage = ^{
        
        if (weakSelf.selectedAsset.count == 0) {
            ShowToast(@"您还没有选择图片");
            return ;
        }
        
        if (weakSelf.FinishToSelectImage) {
            weakSelf.FinishToSelectImage(weakSelf.selectedAsset.copy);
        }
        [weakSelf onCancelAction:nil];
    };
}

#pragma mark - UIButton Action

- (void)onBackToPrivous:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onCancelAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HEThumbnailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HEThumbnailCell" forIndexPath:indexPath];
    
    PHAsset *asset = [self.dataSource objectAtIndex:indexPath.item];
    cell.asset = asset;
    if ([self.selectedAsset containsObject:asset]) {
        cell.checked = YES;
    } else {
        cell.checked = NO;
    }
    
    WS(weakSelf);
    cell.CheckImage = ^(UIImage *image, PHAsset *asset1, BOOL check) {
        if (check) {
            [weakSelf.bottomBar addImage:image asset:asset1];
            if (!weakSelf.selectedAsset) {
                weakSelf.selectedAsset = [NSMutableArray array];
            }
            [weakSelf.selectedAsset addObject:asset1];
        } else {
            [weakSelf.bottomBar deleteImage:image asset:asset1];
            if ([weakSelf.selectedAsset containsObject:asset1]) {
                [weakSelf.selectedAsset removeObject:asset1];
            }
        }
    };
    
    // 判断是否达到了最大量
    cell.JudgeWhetherMaximize = ^BOOL {
        if (weakSelf.selectedAsset.count == weakSelf.maxSelectCount) {
            ShowToast(@"已经达到了最大量了");
            return YES;
        }
        return NO;
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.clickToShowBigImage) {
        HEBigImageViewController *bigImageVC = [[HEBigImageViewController alloc] init];
        bigImageVC.assets = self.assets;
        bigImageVC.selectIndex = indexPath.item + 1;
        bigImageVC.selectedAsset = self.selectedAsset;
        bigImageVC.maxSelectCount = self.maxSelectCount;
        bigImageVC.isPresent = NO;
        WS(weakSelf)
        bigImageVC.BlockOnRefrashData = ^(PHAsset *asset, BOOL isAdd) {
            [weakSelf.collectionView reloadData];
            
            if (isAdd) {
                [weakSelf.bottomBar addImage:nil asset:asset];
                
            } else {
                [weakSelf.bottomBar deleteImage:nil asset:asset];
            }
        };
        [self.navigationController pushViewController:bigImageVC animated:YES];
    } else {
        HEThumbnailCell *cell = (HEThumbnailCell *)[collectionView cellForItemAtIndexPath:indexPath];
        PHAsset *asset = [self.dataSource objectAtIndex:indexPath.item];
        if ([self.selectedAsset containsObject:asset]) {
            cell.checked = NO;
            [self.bottomBar deleteImage:[cell getImage] asset:asset];
            if ([self.selectedAsset containsObject:asset]) {
                [self.selectedAsset removeObject:asset];
            }
        } else {
            
            if (self.selectedAsset.count == self.maxSelectCount) {
                ShowToast(@"已经达到了最大量了");
                return;
            }
            
            cell.checked = YES;
            [self.bottomBar addImage:[cell getImage] asset:asset];
            if (!self.selectedAsset) {
                self.selectedAsset = [NSMutableArray array];
            }
            [self.selectedAsset addObject:asset];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
/// 设置每个item的宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(cellWidth, cellWidth);
}

/// 行距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return Cell_Line_Space;
}

/// 间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return Cell_Item_Space;
}

@end
