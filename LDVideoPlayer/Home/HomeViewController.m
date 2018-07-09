//
//  HomeViewController.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/26.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import "HomeViewController.h"
#import "VideoPlayViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *jumpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    jumpBtn.backgroundColor = [UIColor redColor];
    
    [jumpBtn setTitle:@"jumpVideoPlay" forState:UIControlStateNormal];
    
    [jumpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.view addSubview:jumpBtn];
    
    [jumpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.center.mas_equalTo(self.view);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(60);
        
    }];
    
    @weakify(self);
    
    [[jumpBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
      
        @strongify(self);
        
        VideoPlayViewController *videoPlay = [[VideoPlayViewController alloc]init];
        
        [self.navigationController pushViewController:videoPlay animated:YES];
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
