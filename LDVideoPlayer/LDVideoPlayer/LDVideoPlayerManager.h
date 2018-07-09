//
//  LDVideoPlayerManager.h
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/26.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDVideoPlayerView.h"

typedef NS_ENUM(NSInteger, LDPlayerLayerGravity) {
    LDLayerVideoGravityResizeAspect,//等比例缩放，以最短的边为准，可能会有留白
    LDLayerVideoGravityResizeAspectFill,//等比例缩放，以最长的边为准，可能会有裁剪
    LDLayerVideoGravityResize,//不按照等比例缩放，填充整个布局，可能会变形
};

typedef NS_ENUM(NSInteger, LDPlayerStatus) {
    LDPlayerStatusFailed,
    LDPlayerStatusReadyToPlay,
    LDPlayerStatusUnknown,
    LDPlayerStatusBuffering,
    LDPlayerStatusPlaying,
    LDPlayerStatusStopped,
};

typedef NS_ENUM(NSInteger, LDPanGestureDirection) {
    LDPanGestureDirectionNone,
    LDPanGestureDirectionTop,
    LDPanGestureDirectionLeft,
    LDPanGestureDirectionBottom,
    LDPanGestureDirectionRight,
};

typedef NS_ENUM(NSInteger, LDVideoPlayerStyle) {
    LDVideoPlayerNormalStyle, //正常视频
    LDVideoPlayerTableViewStyle, //tableView上视频
    LDVideoPlayerShortVideoStyle, //短视频
};

@interface LDVideoPlayerManager : NSObject

/**
 *  播放器的视图
 */
@property (nonatomic, strong, readwrite)UIView *view;

/**
 *  当前的播放对象
 */
@property (nonatomic, strong, readonly)AVPlayerItem *currentPlayerItem;

#pragma mark - videoConfig -- 视频配置信息

@property (nonatomic, copy, readonly)NSString *url;

/**
 *  videoLayer的填充方式
 */
@property (nonatomic, assign, readwrite)LDPlayerLayerGravity mode;

/**
 *  是否静音
 */
@property (nonatomic, assign, readwrite)BOOL muted;

/**
 *  是否自动旋转 默认是NO
 */
@property (nonatomic, assign, readwrite)BOOL shouldAutorotate;

/**
 *  是否一直显示返回键 0 只有在全屏的时候显示 1 小屏和全屏都显示
 */
@property (nonatomic, assign, readwrite)BOOL alwaysShowBackBtn;

/**
 *  播放状态
 */
@property (nonatomic, assign, readonly)LDPlayerStatus status;

/**
 *  是否正在播放
 */
@property (nonatomic, assign, readonly, getter=isPlaying)BOOL playing;

/**
 *  control层是否正在显示
 */
@property (nonatomic, assign, readonly, getter=isControlAppear)BOOL controlAppear;

/**
 *  当前视频的方向 默认是 UIInterfaceOrientationPortrait
 */
@property (nonatomic, assign, readonly)UIInterfaceOrientation currentInterfaceOrientation;

/**
 *  当前系统音量
 */
@property (nonatomic, assign, readonly)float volumeValue;

/**
 *  当前系统亮度
 */
@property (nonatomic, assign, readonly)float brightnessValue;

/**
 *  播放器管理器的初始化方法
 */
+ (instancetype)playerManager;

/**
 设置video的title和url
 
 @param title 标题
 @param assetUrl 地址URL
 */
- (void)playWithTile:(NSString *)title avAssetUrl:(NSURL *)assetUrl;

/**
 设置tableView上的视频播放参数
 
 @param title 标题
 @param assetUrl 地址URL
 @param tableView 播放器所在的tableView
 @param indexPath 播放器所在tableView的indexPath
 @param parentView 播放器的父视图
 */
- (void)playWithTitle:(NSString *)title avAssetUrl:(NSURL *)assetUrl scrollView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath playerParentView:(UIView *)parentView;

/**
 设置短视频类型的视频播放参数
 
 @param assetUrl 地址URL
 @param parentView 播放器的父视图
 */
- (void)playShortVideoStyleWithAvAssetUrl:(NSURL *)assetUrl playerParentView:(UIView *)parentView;

/**
 *  开始播放
 */
- (void)play;

/**
 *  暂停播放
 */
- (void)pause;

/**
 *  销毁
 */
- (void)stop;

/**
 *  重置
 */
- (void)reset;

/**
 *  点击返回按钮
 */
@property (nonatomic, copy) void (^backBtnDidSelectBlock)(void);

@end
