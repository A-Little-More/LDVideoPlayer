//
//  DouYinViewController.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/7/4.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import "DouYinViewController.h"
#import "LDPlayerScrollManager.h"
#import "VideoDataModel.h"

@interface DouYinViewController ()

@property (nonatomic, strong)LDPlayerScrollManager *playerScrollManager;

@property (nonatomic, strong)NSMutableArray *dataSource;

@end

@implementation DouYinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([[UIDevice currentDevice] systemVersion].floatValue>=7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    @weakify(self);
    
    [VideoDataModel getHomePageVideoDataWithBlock:^(NSArray *dateAry, NSError *error) {
        
        @strongify(self);
        
        self.dataSource = [NSMutableArray arrayWithArray:dateAry];
      
        self.playerScrollManager.dataSource = self.dataSource;
        
    }];
    
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)dataSource{
    
    if(!_dataSource){
        
        _dataSource = [NSMutableArray array];
        
    }
    
    return _dataSource;
}

- (LDPlayerScrollManager *)playerScrollManager{
    
    if(!_playerScrollManager){
        
        _playerScrollManager = [LDPlayerScrollManager playerWithSuperView:self.view];
        
    }
    
    return _playerScrollManager;
}

@end
