//
//  LDPlayerScrollManager.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/7/5.
//  Copyright © 2018年 macbook. All rights reserved.
#define scrollViewWidth (self.superView.bounds.size.width)
#define scrollViewHeight (self.superView.bounds.size.height)

#import "LDPlayerScrollManager.h"
#import "LDPlayerTableView.h"
#import "LDPlayerTableViewCell.h"
#import "LDVideoPlayerManager.h"

@interface LDPlayerScrollManager ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>;

@property (nonatomic, strong)LDPlayerTableView *playerTableView;

//当前的index
@property (nonatomic, assign)NSInteger playIndex;

@property (nonatomic, strong)LDVideoPlayerManager *playerManager;

@end

@implementation LDPlayerScrollManager

+ (instancetype)playerWithSuperView:(UIView *)view{
    
    return [[self alloc]initWithSuperView:view];
    
}

- (instancetype)initWithSuperView:(UIView *)superView{
    
    self = [super init];
    
    if(self){
        
        self.superView = superView;
        
//        self.playIndex = -1;
        
        [self initFrame];
        
    }
    
    return self;
}

- (void)initFrame{
    
    [self.superView addSubview:self.playerTableView];
    
    [self.playerTableView mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.edges.mas_equalTo(self.superView);
        
    }];
}

#pragma mark - UITableViewDelegate dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *reuseIde = @"PlayerCell";
    
    LDPlayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIde];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    VideoDataModel *model = self.dataSource[indexPath.row];
    
    [cell.LDImageV sd_setImageWithURL:[NSURL URLWithString:model.cover_url]];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return scrollViewHeight;
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSLog(@"%f", scrollView.contentOffset.y);
    
    if(((int)scrollView.contentOffset.y % (int)scrollViewHeight) == 0){
        
        NSInteger index = scrollView.contentOffset.y / scrollViewHeight;
        
        if(index != self.playIndex){
            
            self.playIndex = index;
            
        }
        
    }

}

- (void)playVideo{
    
    if(self.playIndex < 0){
        
        return;
        
    }
    
    VideoDataModel *model = self.dataSource[self.playIndex];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.playIndex inSection:0];
    
    LDPlayerTableViewCell *cell = [self.playerTableView cellForRowAtIndexPath:indexPath];
    
    UIView *parentView = (UIView *)cell.LDImageV;
    
    [self.playerManager playShortVideoStyleWithAvAssetUrl:[NSURL URLWithString:model.video_url] playerParentView:parentView];
    
    [self.playerManager play];
    
}

- (void)setPlayIndex:(NSInteger)playIndex{
    
    _playIndex = playIndex;
    
    [self playVideo];
    
}


- (LDPlayerTableView *)playerTableView{
    
    if(!_playerTableView){
        
        _playerTableView = [[LDPlayerTableView alloc]init];
        
        _playerTableView.backgroundColor = [UIColor whiteColor];
        
        _playerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _playerTableView.pagingEnabled = YES;
        
        _playerTableView.delegate = self;
        
        _playerTableView.dataSource = self;
        
        [_playerTableView registerClass:[LDPlayerTableViewCell class] forCellReuseIdentifier:@"PlayerCell"];
        
    }
    
    return _playerTableView;
}


- (void)setDataSource:(NSArray *)dataSource{
    
    _dataSource = dataSource;
    
    [self.playerTableView reloadData];
    
    [self playVideo];
    
}

- (LDVideoPlayerManager *)playerManager{
    
    if(!_playerManager){
        
        _playerManager = [LDVideoPlayerManager playerManager];
        
        _playerManager.mode = LDLayerVideoGravityResizeAspect;
        
        _playerManager.muted = YES;
        
        _playerManager.shouldAutorotate = NO;
        
        _playerManager.alwaysShowBackBtn = NO;
        
    }
    
    return _playerManager;
}

- (void)dealloc{
    
    [self.playerManager pause];
    
    [self.playerManager stop];
    
}

@end
