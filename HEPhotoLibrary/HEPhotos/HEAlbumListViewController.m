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

@interface HEAlbumListViewController ()

@end

@implementation HEAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusAuthorized: {         // 用户已授权，允许访问
            NSArray *arr = [[HEPhotoTool sharePhotoTool] getPhotoAblumList];
            NSLog(@"%@", arr);
            break;
        }
        case PHAuthorizationStatusDenied: {             // 用户拒绝访问
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"您已拒绝app访问相簿，若想访问，请到设置中赋予权限" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil] show];
            break;
        }
        case PHAuthorizationStatusNotDetermined: {      // 用户从未进行过授权等处理，首次访问相应内容会提示用户进行授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    NSArray *arr = [[HEPhotoTool sharePhotoTool] getPhotoAblumList];
                    NSLog(@"%@", arr);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
