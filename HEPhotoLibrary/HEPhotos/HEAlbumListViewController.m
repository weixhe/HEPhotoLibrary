//
//  HEAlbumListViewController.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/4/27.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "HEAlbumListViewController.h"
#import "HEPhotoTool.h"
#import <Photos/Photos.h>
#import "HEAlbumListCellCell.h"
#import "HEPhotoConstant.h"
#import "HEThumbnailViewController.h"
#import "HEThumbnailViewController.h"

@interface HEAlbumListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation HEAlbumListViewController
- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.tableView = nil;
    self.dataSource = nil;
    self.FinishToSelectImage = NULL;
    PhotoLog(@"HEAlbumListViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = LocalizedStringForKey(kTextForPhotoList);
    
    // 背景图片
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image = UIImageFromPhotoBundle(@"background_1.jpeg");
    [self.view addSubview:bgImageView];
    
    [self layoutNavigation];
    [self setupTableView];
    [self authorizationPhotoLibrary];
    
    // 直接跳转到thumb的控制器中
    [self jumpToThumbnailController];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// 直接跳转到thumb的控制器中
- (void)jumpToThumbnailController {
    
    if (self.dataSource.count == 0) {
        return;
    }
    NSInteger i = 0;
    for (HEPhotoAlbumModel *model in self.dataSource) {
        if (model.assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            i = [self.dataSource indexOfObject:model];
            break;
        }
    }
    
    HEPhotoAlbumModel *model = [self.dataSource objectAtIndex:i];
    HEThumbnailViewController *thumbVC = [[HEThumbnailViewController alloc] init];
    thumbVC.title = model.title;
    thumbVC.assets = [[HEPhotoTool sharePhotoTool] getAssetsInAssetCollection:model.assetCollection ascending:NO];
    thumbVC.maxSelectCount = self.maxSelectCount;
    thumbVC.selectedAsset = self.selectedAsset;
    thumbVC.FinishToSelectImage = self.FinishToSelectImage;
    thumbVC.clickToShowBigImage = YES;
    [self.navigationController pushViewController:thumbVC animated:NO];
}

#pragma mark - UINavigationBar

- (void)layoutNavigation {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:LocalizedStringForKey(kTextForCancel) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
    [btn addTarget:self action:@selector(onCancelAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.hidesBackButton = YES;
}

- (void)onCancelAction:(UIButton *)button {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SetupUI

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[HEAlbumListCellCell class] forCellReuseIdentifier:NSStringFromClass([HEAlbumListCellCell class])];
}

- (void)authorizationPhotoLibrary {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusAuthorized: {         // 用户已授权，允许访问
            [self getAlbumList];
            break;
        }
        case PHAuthorizationStatusDenied: {             // 用户拒绝访问
            [[[UIAlertView alloc] initWithTitle:LocalizedStringForKey(kTextForTip) message:kAccessAuthorityStatusDenied delegate:nil cancelButtonTitle:LocalizedStringForKey(kTextForIKnow) otherButtonTitles:nil, nil] show];
            break;
        }
        case PHAuthorizationStatusNotDetermined: {      // 用户从未进行过授权等处理，首次访问相应内容会提示用户进行授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self getAlbumList];
                    });
                } else {
                    PhotoLog(@"Denied or Restricted");
                }
            }];
            break;
        }
        case PHAuthorizationStatusRestricted: {         // 应用没有相关权限，且当前用户无法改变这个权限，比如:家长控制
            [[[UIAlertView alloc] initWithTitle:LocalizedStringForKey(kTextForTip) message:kAccessAuthorityStatusRestricted delegate:nil cancelButtonTitle:LocalizedStringForKey(kTextForIKnow) otherButtonTitles:nil, nil] show];
            break;
        }
        default:
            break;
    }
}

- (void)getAlbumList {
    self.dataSource = [NSMutableArray arrayWithArray:[[HEPhotoTool sharePhotoTool] getAllPhotoAblumList]];
    [self.tableView reloadData];
}

- (void)setSelectedAsset:(NSMutableArray<PHAsset *> *)selectedAsset {
    _selectedAsset = selectedAsset.mutableCopy;
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HEAlbumListCellCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HEAlbumListCellCell class]) forIndexPath:indexPath];
    cell.model = [self.dataSource objectAtIndex:(NSUInteger)indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    HEPhotoAlbumModel *model = [self.dataSource objectAtIndex:(NSUInteger)indexPath.row];
    
    HEThumbnailViewController *thumbVC = [[HEThumbnailViewController alloc] init];
    thumbVC.title = model.title;
    thumbVC.assets = [[HEPhotoTool sharePhotoTool] getAssetsInAssetCollection:model.assetCollection ascending:NO];
    thumbVC.maxSelectCount = self.maxSelectCount;
    thumbVC.selectedAsset = self.selectedAsset;
    thumbVC.FinishToSelectImage = self.FinishToSelectImage;
    thumbVC.clickToShowBigImage = YES;
    [self.navigationController pushViewController:thumbVC animated:YES];
}

@end
