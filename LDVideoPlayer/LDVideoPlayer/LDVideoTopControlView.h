//
//  LDVideoTopControlView.h
//  LDVideoPlayer
//
//  Created by lidong on 2018/7/2.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LDVideoTopControlView;
@protocol LDVideoTopControlViewDelegate <NSObject>
@optional
/**
 点击返回按钮的响应事件
 
 @param controlView 控制视图
 @param button 播放/停止按钮
 */
- (void)controlView:(LDVideoTopControlView *)controlView didSelectBackBtn:(UIButton *)button;

@end

@interface LDVideoTopControlView : UIView

/**
 *  视频的标题
 */
@property (nonatomic, copy)NSString *title;

/**
 *  是否一直显示返回键 0 只有在全屏的时候显示 1 小屏和全屏都显示
 */
@property (nonatomic, assign)BOOL alwaysShowBackBtn;

@property (nonatomic, weak)id <LDVideoTopControlViewDelegate> delegate;

@end
