//
//  AppDelegate.m
//  HEPhotoLibrary
//
//  Created by weixhe on 2017/4/17.
//  Copyright © 2017年 weixhe. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    return YES;
}



//写入默认值

-(void)registerDefaultsFromSettingsBundle{
    
    NSString * settingsBundle =[[NSBundle mainBundle]pathForResource:@"Settings"   ofType:@"bundle"];
    
    if (!settingsBundle) {
        
        NSLog(@"Could not find Settings.bundle");
        
        return;
        
    }
    
    NSDictionary * settings =[NSDictionary dictionaryWithContentsOfFile:                        [settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    
    NSArray * Preference =[settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister =[[NSMutableDictionary alloc]initWithCapacity:[Preference count]];
    
    for (NSDictionary * prefSpecification in Preference) {
        
        NSString * key =[prefSpecification objectForKey:@"Key"];
        
        if (key) {
            
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:@"key"];
            
        }
        
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
