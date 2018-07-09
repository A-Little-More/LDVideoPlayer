//
//  LDPlayerScrollManager.h
//  LDVideoPlayer
//
//  Created by lidong on 2018/7/5.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoDataModel.h"

@interface LDPlayerScrollManager : NSObject

//父视图
@property (nonatomic, strong)UIView *superView;

//数据源
@property (nonatomic, strong)NSArray *dataSource;

//初始化方法
+ (instancetype)playerWithSuperView:(UIView *)view;

@end
