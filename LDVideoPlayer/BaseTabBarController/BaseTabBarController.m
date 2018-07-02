//
//  BaseTabBarController.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/26.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import "BaseTabBarController.h"
#import "BaseNavigationController.h"
#import "HomeViewController.h"
#import "ShopViewController.h"
#import "CarViewController.h"
#import "MineViewController.h"

@interface BaseTabBarController ()

@property (nonatomic, strong)NSArray *viewControllerArray;

@property (nonatomic, strong)NSArray *tabBarTitleArray;

@property (nonatomic, strong)NSArray *tabBarImageArray;

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewControllerArray = @[@"HomeViewController",@"ShopViewController",@"CarViewController",@"MineViewController"];
    
    self.tabBarTitleArray = @[@"首页",@"商城",@"购物车",@"我的"];
    
    self.tabBarImageArray = @[@"home",@"message",@"mycity",@"account"];
    
    [self initTabBar];
    
}

- (void)initTabBar{
    
    NSMutableArray *tabBars = [NSMutableArray array];
    
    for(int i = 0; i < self.viewControllerArray.count; i ++){
        
        Class vcClass = NSClassFromString(self.viewControllerArray[i]);
        
        BaseNavigationController *nav = [[BaseNavigationController alloc]initWithRootViewController:[[vcClass alloc]init]];
        
        nav.sj_gestureType = SJFullscreenPopGestureType_Full;
        
        nav.tabBarItem.title = self.tabBarTitleArray[i];
        
        
        
        [nav.tabBarItem setImage:[[UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", self.tabBarImageArray[i]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        [nav.tabBarItem setSelectedImage:[[UIImage imageNamed:[NSString stringWithFormat:@"%@_highlight", self.tabBarImageArray[i]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
        
        [nav.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName] forState:UIControlStateSelected];
        
        [tabBars addObject:nav];
        
    }
    
    self.viewControllers = tabBars;
    
}

#pragma mark - 关于旋转的设置
//是否自动旋转
-(BOOL)shouldAutorotate{
    return self.selectedViewController.shouldAutorotate;
}

//支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}

//默认方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.selectedViewController preferredInterfaceOrientationForPresentation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
