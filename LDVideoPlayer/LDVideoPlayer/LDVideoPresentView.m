//
//  LDVideoPresentView.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/29.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import "LDVideoPresentView.h"

@interface LDVideoPresentView ()

@property (nonatomic, strong)UILabel *currentTime;

@property (nonatomic, strong)UISlider *progressSlider;

//视频的当前时间 格式00:10
@property (nonatomic, copy, readwrite)NSString *currentSecondTime;

@end

@implementation LDVideoPresentView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        
        [self initFrame];
        
    }
    
    return self;
}

- (void)initFrame{
    
    [self addSubview:self.currentTime];
    [self addSubview:self.progressSlider];
    
    [self.currentTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self).offset(-30);
    }];
    
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.currentTime.mas_bottom).offset(0);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(150);
    }];
    
}

#pragma mark - setTotalSecond

- (void)setTotalSecond:(long)totalSecond{
    
    _totalSecond = totalSecond;
    
    //设置progressSilder的最大值
    self.progressSlider.maximumValue = totalSecond;
    
}

#pragma mark - setCurrentSecond

- (void)setCurrentSecond:(long)currentSecond{
    
    _currentSecond = currentSecond;
    
    self.progressSlider.value = currentSecond;
    
    self.currentSecondTime = [self convertTime:currentSecond];
    
    self.currentTime.text = self.currentSecondTime;
}

//将数值转换成时间
- (NSString *)convertTime:(long)second{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:date];
    return showtimeNew;
}

- (UISlider *)progressSlider{
    
    if(!_progressSlider){
        
        _progressSlider = [[UISlider alloc]init];
        
        [_progressSlider setThumbImage:[UIImage new] forState:UIControlStateNormal];
        
        _progressSlider.continuous = YES;
        
        _progressSlider.minimumTrackTintColor = [UIColor redColor];
        
        _progressSlider.userInteractionEnabled = NO;
        
    }
    
    return _progressSlider;
}

- (UILabel *)currentTime{
    
    if(!_currentTime){
        
        _currentTime = [[UILabel alloc]init];
        
        _currentTime.backgroundColor = [UIColor clearColor];
        
        _currentTime.textColor = [UIColor whiteColor];
        
        _currentTime.font = [UIFont fontWithName:@"STHeitiSC-Light" size:40];
        
        _currentTime.text = @"00:00";
    }
    
    return _currentTime;
}

@end
