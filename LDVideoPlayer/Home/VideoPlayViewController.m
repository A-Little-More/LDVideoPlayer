//
//  VideoPlayViewController.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/30.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import "VideoPlayViewController.h"
#import "LDVideoBottomControlView.h"

@interface VideoPlayViewController ()

@property (nonatomic, strong)LDVideoPlayerManager *playerManager;

@end

@implementation VideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    self.navigationItem.title = @"视频播放";
    
    self.playerManager = [LDVideoPlayerManager playerManager];
    
    [self.playerManager playWithTile:@"titletitle/titletitle" avAssetUrl:[NSURL URLWithString:videoUrl]];
    
    [self.view addSubview:self.playerManager.view];
    
    [self.playerManager.view mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(200);
        
    }];
    
    self.playerManager.mode = LDLayerVideoGravityResizeAspect;
    
    self.playerManager.muted = YES;
    
    self.playerManager.shouldAutorotate = YES;
    
    self.playerManager.alwaysShowBackBtn = YES;
    
    [self.playerManager play];
    
    @weakify(self);
    
    self.playerManager.backBtnDidSelectBlock = ^{
     
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    [self.playerManager pause];
    
    [self.playerManager stop];
    
}

- (void)dealloc{
    
    
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    //横向
    if(size.width > size.height){
        
        self.navigationController.navigationBar.hidden = YES;
        
        [self.playerManager.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.center.mas_equalTo(self.view);
            make.width.mas_equalTo(size.width);
            make.height.mas_equalTo(size.height);
            
        }];
        
        [self.view layoutIfNeeded];
        
    }else{
        
        self.navigationController.navigationBar.hidden = NO;
        
        [self.playerManager.view mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.center.mas_equalTo(self.view);
            make.width.mas_equalTo(kScreenWidth);
            make.height.mas_equalTo(170);
            
        }];
        
        [self.view layoutIfNeeded];
        
    }
    
}

#pragma mark - 关于旋转的设置
//是否自动旋转:所有控制器默认不自动旋转，需要横屏的视图控制器中覆写此方法，返回YES
-(BOOL)shouldAutorotate{
    return NO;
}

//支持哪些屏幕方向:只支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

//默认方向:只支持正常竖屏
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
