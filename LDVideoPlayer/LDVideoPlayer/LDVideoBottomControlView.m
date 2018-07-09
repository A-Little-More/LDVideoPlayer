//
//  LDVideoBottomControlView.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/27.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import "LDVideoBottomControlView.h"
#import "LDSlider.h"

@interface LDVideoBottomControlView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong)UIButton *playOrPauseBtn;

@property (nonatomic, strong)LDSlider *progressSlider;

@property (nonatomic, strong)UISlider *bufferSlider;

@property (nonatomic, strong)UITapGestureRecognizer *progressTapGesture;

@property (nonatomic, strong)UIButton *fullScreenBtn;

@property (nonatomic, strong)UILabel *playTimeLabel;

//视频的总时间 格式01:24
@property (nonatomic, copy, readwrite)NSString *totalSecondTime;

//视频的当前时间 格式00:10
@property (nonatomic, copy, readwrite)NSString *currentSecondTime;

//
@property (nonatomic, strong)UITapGestureRecognizer *tapGesture;

@end

@implementation LDVideoBottomControlView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        
        [self initFrame];
        
    }
    
    return self;
}

- (void)initFrame{
    
    [self addSubview:self.playTimeLabel];
    [self addSubview:self.bufferSlider];
    [self addSubview:self.progressSlider];
    [self addSubview:self.playOrPauseBtn];
    [self addSubview:self.fullScreenBtn];
    
//    self.playTimeLabel.hidden = YES;
//    self.bufferSlider.hidden = YES;
//    self.progressSlider.hidden = YES;
//    self.playOrPauseBtn.hidden = YES;
//    self.fullScreenBtn.hidden = YES;
    
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(10);
        make.width.height.mas_equalTo(35);
        
    }];
    
    [self.playTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.left.mas_equalTo(self.playOrPauseBtn.mas_right).offset(5);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(80);
        
    }];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-10);
        make.width.height.mas_equalTo(35);
        
    }];
    
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self.playTimeLabel.mas_right).offset(5);
        make.right.mas_equalTo(self.fullScreenBtn.mas_left).offset(-10);
        make.height.mas_equalTo(15);
        
    }];
    
    [self.bufferSlider mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.edges.mas_equalTo(self.progressSlider);
        
    }];
    
    [self addGestureRecognizer:self.tapGesture];
    
}

- (void)tapGestureAction:(UIGestureRecognizer *)gesture{
    
    
}

#pragma mark - progressSliderValueChanged -- progressSlider滑块滑动

- (void)progressSliderValueChanged:(UISlider *)slider{
    
    if([self.delegate respondsToSelector:@selector(controlView:draggedPositionWithSliderValue:)]){
        
        self.currentSecond = slider.value;
        
        [self.delegate controlView:self draggedPositionWithSliderValue:slider.value];
        
    }
    
}

#pragma mark - progressSliderTouchUpInside -- progressSlider滑动结束

- (void)progressSliderTouchUpInside:(UISlider *)slider{
    
    if([self.delegate respondsToSelector:@selector(controlView:touchUpInsideWithSliderValue:)]){
        
        self.currentSecond = slider.value;
        
        [self.delegate controlView:self touchUpInsideWithSliderValue:slider.value];
        
    }
    
}

#pragma mark - progressTapGesture -- progressSlider的点击事件

- (void)progressTapGesture:(UIGestureRecognizer *)gesture{
    
    CGPoint point = [gesture locationInView:self.progressSlider];
    CGFloat pointX = point.x;
    CGFloat sliderWith = self.progressSlider.frame.size.width;
    CGFloat currentValue = pointX / sliderWith * self.progressSlider.maximumValue;
    
    if([self.delegate respondsToSelector:@selector(controlView:positionSliderLocationWithCurrentValue:)]){
        
//        self.currentSecond = currentValue;
        
        [self.delegate controlView:self positionSliderLocationWithCurrentValue:currentValue];
        
    }
    
}

#pragma mark - fullScreenBtnPress-- 最大化/最小化

- (void)fullScreenBtnPress:(UIButton *)btn{
    
    if([self.delegate respondsToSelector:@selector(controlView:withLargeButton:)]){
        
        [self.delegate controlView:self withLargeButton:btn];
        
    }
    
}

- (void)playOrPauseBtnPress:(UIButton *)btn{
    
    if([self.delegate respondsToSelector:@selector(controlView:withPlayOrPauseButton:)]){
        
        [self.delegate controlView:self withPlayOrPauseButton:btn];
        
    }
    
}

#pragma mark - gestureRecogizerDelegate -- 避免event和gesture冲突

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//
//    if([touch.view isKindOfClass:[UISlider class]]){
//
//        return NO;
//
//    }
//
//    return YES;
//}

#pragma mark - setIsPlaying -- 是否正在播放

- (void)setIsPlaying:(BOOL)isPlaying{
    
    _isPlaying = isPlaying;
    
    if(isPlaying){
        
        self.playOrPauseBtn.selected = NO;
        
    }else{
        
        self.playOrPauseBtn.selected = YES;
        
    }
    
}

#pragma mark - setTotalSecond

- (void)setTotalSecond:(long)totalSecond{

    _totalSecond = totalSecond;
    
    //设置progressSilder的最大值
    self.progressSlider.maximumValue = totalSecond;
    
    //设置视频的总时间
    self.totalSecondTime = [self convertTime:totalSecond];
    
}

#pragma mark - setCurrentSecond

- (void)setCurrentSecond:(long)currentSecond{
    
    _currentSecond = currentSecond;
    
    self.progressSlider.value = currentSecond;
    
    self.currentSecondTime = [self convertTime:currentSecond];
    
    self.playTimeLabel.text = [NSString stringWithFormat:@"%@/%@",self.currentSecondTime, self.totalSecondTime];
    
}

#pragma mark - setBufferSecond

- (void)setBufferSecond:(float)bufferSecond{
    
    _bufferSecond = bufferSecond;
    
    [self.bufferSlider setValue:bufferSecond / self.totalSecond];
    
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

- (UIButton *)playOrPauseBtn{
    
    if(!_playOrPauseBtn){
        
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_playOrPauseBtn setImage:[UIImage imageNamed:@"ld_video_player_pause"] forState:UIControlStateNormal];
        
        [_playOrPauseBtn setImage:[UIImage imageNamed:@"ld_video_player_play"] forState:UIControlStateSelected];
        
        
        [_playOrPauseBtn addTarget:self action:@selector(playOrPauseBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        
        _playOrPauseBtn.userInteractionEnabled = YES;
        
        _playOrPauseBtn.selected = YES;
    }
    
    return _playOrPauseBtn;
}

- (LDSlider *)progressSlider{
    
    if(!_progressSlider){
        
        _progressSlider = [[LDSlider alloc]init];
        
        [_progressSlider setThumbImage:[UIImage imageNamed:@"fb"] forState:UIControlStateNormal];
        
        [_progressSlider setThumbImage:[UIImage imageNamed:@"bb"] forState:UIControlStateHighlighted];
        
        _progressSlider.maximumTrackTintColor = [UIColor clearColor];
        
        _progressSlider.minimumTrackTintColor = [UIColor whiteColor];
        
        [_progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        [_progressSlider addTarget:self action:@selector(progressSliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        [_progressSlider addTarget:self action:@selector(progressSliderTouchUpInside:) forControlEvents:UIControlEventTouchUpOutside];
        
        [_progressSlider addGestureRecognizer:self.progressTapGesture];
        
    }
    
    return _progressSlider;
}

- (UISlider *)bufferSlider{
    
    if(!_bufferSlider){
        
        _bufferSlider = [[UISlider alloc]init];
        
        [_bufferSlider setThumbImage:[UIImage new] forState:UIControlStateNormal];
        
        _bufferSlider.continuous = YES;
    
        _bufferSlider.minimumTrackTintColor = [UIColor redColor];
        
        _bufferSlider.minimumValue = 0.f;
        
        _bufferSlider.maximumValue = 1.f;
        
        _bufferSlider.userInteractionEnabled = NO;
        
    }
    
    return _bufferSlider;
}

- (UITapGestureRecognizer *)progressTapGesture{

    if(!_progressTapGesture){

        _progressTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(progressTapGesture:)];

        _progressTapGesture.delegate = self;

    }

    return _progressTapGesture;
}

- (UIButton *)fullScreenBtn{
    
    if(!_fullScreenBtn){
        
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_fullScreenBtn setImage:[UIImage imageNamed:@"ld_video_player_fullscreen"] forState:UIControlStateNormal];
        
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _fullScreenBtn;
}

- (UILabel *)playTimeLabel{
    
    if(!_playTimeLabel){
        
        _playTimeLabel = [[UILabel alloc]init];
        
        _playTimeLabel.backgroundColor = [UIColor clearColor];
        
        _playTimeLabel.textColor = [UIColor whiteColor];
        
        _playTimeLabel.font = [UIFont fontWithName:@"Courier" size:12];
        
        _playTimeLabel.text = @"00:00/00:00";
    }
    
    return _playTimeLabel;
}

- (UITapGestureRecognizer *)tapGesture{
    
    if(!_tapGesture){
        
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
        
        _tapGesture.delegate = self;
        
    }
    
    return _tapGesture;
}

@end
