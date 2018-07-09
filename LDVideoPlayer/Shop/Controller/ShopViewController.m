//
//  ShopViewController.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/26.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import "ShopViewController.h"
#import "VideoListTableViewCell.h"
#import "LDVideoPlayerManager.h"

@interface ShopViewController ()<UITableViewDelegate, UITableViewDataSource, LDVideoListTableViewCellDelegate>

@property (nonatomic, strong)NSMutableArray *dataSource;

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)LDVideoPlayerManager *playerManager;

@end

@implementation ShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationItem.title = @"腾讯小视频";
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.edges.mas_equalTo(self.view);
        
    }];
    
    [self.tableView reloadData];
    

    
}

#pragma mark - UITableViewDelegate And DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 10;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseIde = @"videoListCell";
    
    VideoListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIde];
    
    cell.delegate = self;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 250;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

#pragma mark - LDVideoListDelegate

- (void)clickedPlayOnTabCell:(VideoListTableViewCell *)cell playerParentView:(UIView *)playerParentView{
    
    [self.playerManager playWithTitle:@"videoTitle" avAssetUrl:[NSURL URLWithString:videoUrl] scrollView:self.tableView indexPath:[self.tableView indexPathForCell:cell] playerParentView:playerParentView];
    
    [self.playerManager play];
    
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

- (UITableView *)tableView{
    
    if(!_tableView){
        
        _tableView = [[UITableView alloc]init];
        
        _tableView.backgroundColor = [UIColor whiteColor];
        
        _tableView.delegate = self;
        
        _tableView.dataSource = self;
        
        [_tableView registerClass:[VideoListTableViewCell class] forCellReuseIdentifier:@"videoListCell"];
        
    }
    
    return _tableView;
}

- (NSMutableArray *)dataSource{
    
    if(!_dataSource){
        
        _dataSource = [NSMutableArray array];
        
    }
    
    return _dataSource;
}

- (LDVideoPlayerManager *)playerManager{
    
    if(!_playerManager){
        
        _playerManager = [LDVideoPlayerManager playerManager];
        
        _playerManager.mode = LDLayerVideoGravityResizeAspect;
        
        _playerManager.muted = YES;
        
        _playerManager.shouldAutorotate = YES;
        
        _playerManager.alwaysShowBackBtn = NO;
        
    }
    
    return _playerManager;
}

@end
