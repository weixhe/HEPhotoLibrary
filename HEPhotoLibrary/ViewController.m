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

@interface ViewController ()

- (IBAction)showAlbumList:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ShowToast(@"asdfafasfsfsf");
    
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
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showAlbumList:(id)sender {
    
    HEAlbumListViewController *albumListVC = [[HEAlbumListViewController alloc] init];
    albumListVC.maxSelectCount = 10;
    albumListVC.FinishToSelectImage = ^(NSArray<PHAsset *> *assets) {
      
        PhotoLog(@"%@", assets);
    };
    
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:albumListVC];
    
    [self presentViewController:nav animated:YES completion:nil];
}
@end
