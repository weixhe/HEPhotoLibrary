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

@interface HEAlbumListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation HEAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 背景图片
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.image = HEPhotoImageFromBundleWithName(@"background_1.jpeg");
    [self.view addSubview:bgImageView];
    
    self.dataSource = [NSArray array];
    
    [self setupTableView];
    [self authorizationPhotoLibrary];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
            [self setAlbumList];
            break;
        }
        case PHAuthorizationStatusDenied: {             // 用户拒绝访问
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"您已拒绝app访问相簿，若想访问，请到设置中赋予权限" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil] show];
            break;
        }
        case PHAuthorizationStatusNotDetermined: {      // 用户从未进行过授权等处理，首次访问相应内容会提示用户进行授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self setAlbumList];
                } else {
                    NSLog(@"Denied or Restricted");
                }
            }];
            break;
        }
        case PHAuthorizationStatusRestricted: {         // 应用没有相关权限，且当前用户无法改变这个权限，比如:家长控制
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"应用没有相关权限，且当前用户无法改变这个权限" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil] show];
            break;
        }
        default:
            break;
    }
}

- (void)setAlbumList {
    self.dataSource = [[HEPhotoTool sharePhotoTool] getPhotoAlbumList];
    [self.tableView reloadData];

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


@end
