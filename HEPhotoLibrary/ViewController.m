//
//  ViewController.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/4/17.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "ViewController.h"
#import "HEPhotoTool.h"
#import <Photos/Photos.h>
#import "ToastUtils.h"

#import "HEAlbumListViewController.h"
#import "HEPhotoConstant.h"
#import "HEThumbnailCell.h"

#define Cell_Item_Space 2
#define Cell_Line_Space 2
#define Cell_Item_Num   4       // 一行显示4个item

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    CGFloat cellWidth;
}

@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;

- (IBAction)onChoosePhotos:(id)sender;
- (IBAction)onShowAlbumList:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ShowToast(@"asdfafasfsfsf");
    
    self.dataSource = [NSMutableArray array];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    
//    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//        if (status == PHAuthorizationStatusAuthorized) {
//            PhotoLog(@"Authorized");
//            NSArray *arr = [[HEPhotoTool sharePhotoTool] getAllAssetInPhotoAlumbWithAscending:YES];
//            PhotoLog(@"%@", arr);
//        }else{
//            PhotoLog(@"Denied or Restricted");
//        }
//    }];
    
//        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//
//            if (status == PHAuthorizationStatusAuthorized) {
//                NSArray *arr = [[HEPhotoTool sharePhotoTool] getAllAssetInPhotoAlumbWithAscending:YES];
//                PhotoLog(@"%@", arr);
//
//            } else if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusNotDetermined) {
//                PhotoLog(@"PHAuthorizationStatusDenied");
//            }
//    });
    
    
    [self setupCollectionView];
    cellWidth = (self.collectionView.width - (Cell_Item_Num - 1) * Cell_Item_Space) / Cell_Item_Num;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCollectionView {
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 140, kViewWidth, self.view.height - 140) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[HEThumbnailCell class] forCellWithReuseIdentifier:@"HEThumbnailCell"];
    [self.view addSubview:self.collectionView];
}

- (IBAction)onChoosePhotos:(id)sender {
    
    HEAlbumListViewController *albumListVC = [[HEAlbumListViewController alloc] init];
    albumListVC.maxSelectCount = 10;
    albumListVC.selectedAsset = self.dataSource;
    WS(weakSelf)
    albumListVC.FinishToSelectImage = ^(NSArray<PHAsset *> *assets) {
        
        weakSelf.dataSource = [NSMutableArray arrayWithArray:assets];
        [weakSelf.collectionView reloadData];
    };
    
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:albumListVC];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)onShowAlbumList:(id)sender {
    
}

#pragma mark - 显示结果集
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
    cell.hidenCheckBtn = YES;
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
