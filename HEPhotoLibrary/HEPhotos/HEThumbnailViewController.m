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
    [self.selectedAsset removeAllObjects];
    self.selectedAsset = nil;
    self.assetCollection = nil;
    NSLog(@"HEThumbnailViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 背景图片
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image = HEPhotoImageFromBundleWithName(@"background_1.jpeg");
    [self.view addSubview:bgImageView];

    // 处理数据源, 从相册中取出所有的资源asset
    self.dataSource = [[HEPhotoTool sharePhotoTool] getAssetsInAssetCollection:self.assetCollection ascending:NO];
    
    [self setupCollectionView];
    [self setupBottomBar];
    
    cellWidth = (self.collectionView.width - (Cell_Item_Num - 1) * Cell_Item_Space) / Cell_Item_Num;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCollectionView {
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, kViewWidth, self.view.height - Height_BottomView - 64) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[HEThumbnailCell class] forCellWithReuseIdentifier:@"HEThumbnailCell"];
    [self.view addSubview:self.collectionView];
}

- (void)setupBottomBar {
    self.bottomBar = [[HEThumbnailBottomBar alloc] initWithFrame:CGRectMake(0, self.view.bottom - Height_BottomView, kViewWidth, Height_BottomView)];
    [self.view addSubview:self.bottomBar];
    WS(weakSelf)
    self.bottomBar.DeleteOneImage = ^(UIImage *image, PHAsset *asset) {
        if ([weakSelf.selectedAsset containsObject:asset]) {
            [weakSelf.selectedAsset removeObject:asset];
            [weakSelf.collectionView reloadData];
        }
    };
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
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
/// 设置每个item的宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(cellWidth, cellWidth);
}


//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;

/// 行距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return Cell_Line_Space;
}

/// 间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return Cell_Item_Space;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
//    
//}

@end
