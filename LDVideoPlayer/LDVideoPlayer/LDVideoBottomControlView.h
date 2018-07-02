//
//  LDVideoBottomControlView.h
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/27.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LDVideoBottomControlView;
@protocol LDBottomControlViewDelegate <NSObject>

@optional

/**
 点击UISlider获取点击点
 
 @param controlView 控制视图
 @param value 当前点击点
 */
- (void)controlView:(LDVideoBottomControlView *)controlView positionSliderLocationWithCurrentValue:(CGFloat)value;


/**
 拖拽UISlider的时间响应代理方法
 
 @param controlView 控制视图
 @param value UISlider
 */
-(void)controlView:(LDVideoBottomControlView *)controlView draggedPositionWithSliderValue:(CGFloat)value;

/**
 拖拽UISlider结束的时间响应代理方法
 
 @param controlView 控制视图
 @param value UISlider
 */
-(void)controlView:(LDVideoBottomControlView *)controlView touchUpInsideWithSliderValue:(CGFloat)value;


/**
 点击播放/停止按钮的响应事件
 
 @param controlView 控制视图
 @param button 播放/停止按钮
 */
-(void)controlView:(LDVideoBottomControlView *)controlView withPlayOrPauseButton:(UIButton *)button;

/**
 点击放大按钮的响应事件
 
 @param controlView 控制视图
 @param button 全屏按钮
 */
-(void)controlView:(LDVideoBottomControlView *)controlView withLargeButton:(UIButton *)button;

@end

@interface LDVideoBottomControlView : UIView

//总时间 单位s
@property (nonatomic, assign)long totalSecond;

//当前时间 单位s
@property (nonatomic, assign)long currentSecond;

//缓冲区时间 单位s
@property (nonatomic, assign)float bufferSecond;

//是否正在播放
@property (nonatomic, assign)BOOL isPlaying;

//视频的总时间 格式01:24
@property (nonatomic, copy, readonly)NSString *totalSecondTime;

//视频的当前时间 格式00:10
@property (nonatomic, copy, readonly)NSString *currentSecondTime;

//delegate of controlView
@property (nonatomic, weak)id <LDBottomControlViewDelegate> delegate;

@end
