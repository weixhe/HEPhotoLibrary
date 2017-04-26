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
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            NSLog(@"Authorized");
            NSArray *arr = [[HEPhotoTool sharePhotoTool] getAllAssetInPhotoAlumbWithAscending:YES];
            NSLog(@"%@", arr);
        }else{
            NSLog(@"Denied or Restricted");
        }
    }];
    
//        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//
//            if (status == PHAuthorizationStatusAuthorized) {
//                NSArray *arr = [[HEPhotoTool sharePhotoTool] getAllAssetInPhotoAlumbWithAscending:YES];
//                NSLog(@"%@", arr);
//
//            } else if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusNotDetermined) {
//                NSLog(@"PHAuthorizationStatusDenied");
//            }
//    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
