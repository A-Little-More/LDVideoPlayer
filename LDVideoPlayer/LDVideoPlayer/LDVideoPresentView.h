//
//  LDVideoPresentView.h
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/29.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDVideoPresentView : UIView

//总时间 单位s
@property (nonatomic, assign)long totalSecond;

//当前时间 单位s
@property (nonatomic, assign)long currentSecond;

//视频的当前时间 格式00:10
@property (nonatomic, copy, readonly)NSString *currentSecondTime;

@end
