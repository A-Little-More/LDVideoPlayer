//
//  AppDelegate.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/26.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[BaseTabBarController alloc]init];
    
    [self.window makeKeyAndVisible];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
//    
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    return YES;
}

//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
//    
//    return UIInterfaceOrientationMaskAll;
//    
//}

//- (BOOL)DeviceOrientationDidChange{
//
//    UIDevice *device = [UIDevice currentDevice];
//
//    //识别当前设备的旋转方向
//    switch (device.orientation) {
//        case UIDeviceOrientationFaceUp:
//            NSLog(@"屏幕幕朝上平躺");
//            break;
//
//        case UIDeviceOrientationFaceDown:
//            NSLog(@"屏幕朝下平躺");
//            break;
//        case UIDeviceOrientationUnknown:
//            //系统当前无法识别设备朝向，可能是倾斜
//            NSLog(@"未知方向");
//            break;
//
//        case UIDeviceOrientationLandscapeLeft:
//            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
//            NSLog(@"屏幕向左橫置");
//            break;
//
//        case UIDeviceOrientationLandscapeRight:
//            NSLog(@"屏幕向右橫置");
//            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
//            break;
//
//        case UIDeviceOrientationPortrait:
//            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
//            NSLog(@"屏幕直立");
//            break;
//
//        case UIDeviceOrientationPortraitUpsideDown:
//            NSLog(@"屏幕直立，上下顛倒");
//            break;
//
//        default:
//            NSLog(@"無法识别");
//            break;
//    }
//
//    return YES;
//}

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
