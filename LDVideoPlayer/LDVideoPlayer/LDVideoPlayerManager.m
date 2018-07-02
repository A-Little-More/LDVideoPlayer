//
//  LDVideoPlayerManager.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/26.
//  Copyright © 2018年 macbook. All rights reserved.

#define RotationWidth ([UIScreen mainScreen].bounds.size.height)
#define RotationHeight ([UIScreen mainScreen].bounds.size.width)

#import "LDVideoPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LDVideoTopControlView.h"
#import "LDVideoBottomControlView.h"
#import "LDVideoPresentView.h"
#import "LDBrightnessView.h"

@interface LDVideoPlayerManager ()<LDBottomControlViewDelegate, LDVideoTopControlViewDelegate>

/**
 *  播放器视图
 */
@property (nonatomic, strong, readwrite)LDVideoPlayerView *playerView;

/**
 *  播放控制器
 */
@property (nonatomic, strong, readwrite)AVPlayer *avPlayer;

/**
 *  播放layer
 */
@property (nonatomic, strong, readwrite)AVPlayerLayer *avPlayerLayer;

/**
 *  视频资源
 */
@property (nonatomic, strong, readwrite)AVAsset *avAsset;

/**
 *  视频Item
 */
@property (nonatomic, strong, readwrite)AVPlayerItem *avPlayerItem;

/**
 *  视频的URL
 */
@property (nonatomic, strong, readwrite)NSURL *videoURL;

/**
 *  播放状态
 */
@property (nonatomic, assign, readwrite)LDPlayerStatus status;

/**
 *  播放速率
 */
@property (nonatomic, assign, readwrite)float rate;

/**
 *  可旋转视图
 */
@property (nonatomic, strong, readwrite)UIView *rotationView;

/**
 *  topControlView
 */
@property (nonatomic, strong)LDVideoTopControlView *topControlView;

/**
 *  bottomControlView
 */
@property (nonatomic, strong)LDVideoBottomControlView *bottomControlView;

/**
 *  video更改进度的手势
 */
@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;

/**
 *  点击手势 控制栏的显示隐藏
 */
@property (nonatomic, strong)UITapGestureRecognizer *tapGestureRecognizer;

/**
 *  双击手势 控制播放/暂停
 */
@property (nonatomic, strong)UITapGestureRecognizer *doubleTapGestureRecognizer;

/**
 *  控制栏显示隐藏的timer
 */
@property (nonatomic, strong)NSTimer *controlViewTimer;

/**
 *  video的遮盖层
 */
@property (nonatomic, strong)LDVideoPresentView *presentView;

/**
 *  视频最下方的进度条
 */
@property (nonatomic, strong)UISlider *bottomSlider;

/**
 *  当前window
 */
@property (nonatomic, strong, readonly)UIWindow *currentWindow;

/**
 *  当前视频的方向 默认是 UIInterfaceOrientationPortrait
 */
@property (nonatomic, assign, readwrite)UIInterfaceOrientation currentInterfaceOrientation;

/**
 *  系统的音量slider
 */
@property (nonatomic, strong, readwrite)UISlider *systemVolumeSlider;

@end

@implementation LDVideoPlayerManager{
    
    FBKVOController *_kvoCtr;
    id _timeObserve;
    BOOL _isHandleProgress;//是否手动操作进度条 YES: 停止timeObserve更新进度
    float _gestureBeginPointX;//开始出发手势的pointX值，用来判断更新brightness还是volume
    LDPanGestureDirection _progressGestureDirection;//playView上水平方向控制进度的方向
    int _progressLastSecond;//用于记录水平方向上次的时间
    int _volumeLastValue;//用于记录调节音量的上次value
    int _brightnessLastValue;//用于记录调节亮度的上次value
    NSInteger _controlViewCount;//控制层的倒计时计数  默认五秒
    BOOL _enterBackStatus;//进入后台之前的状态 0 暂停 1 播放
    
}


+ (instancetype)playerVideoUrl:(NSString *)url{
    
    return [[self alloc]initWithUrl:url];
    
}

- (instancetype)initWithUrl:(NSString *)url{
    
    self = [super init];
    
    if(self){
    
        [LDBrightnessView sharedLDBrightnessView];
        
        [self bindData];
        
        [self initControlView];
        
        self.url = url;
        
    }
    
    return self;
}

- (void)bindData{
    
    _kvoCtr = [FBKVOController controllerWithObserver:self];
    
    [self addNotificationForPlayer];
    
    self.interfaceOrientation = UIInterfaceOrientationPortrait;
    
}

- (void)initControlView{
    
    [self.view addSubview:self.rotationView];
    [self.rotationView addSubview:self.playerView];
    [self.rotationView addSubview:self.topControlView];
    [self.rotationView addSubview:self.bottomControlView];
    [self.rotationView addSubview:self.presentView];
    [self.rotationView addSubview:self.bottomSlider];
    
    [self.rotationView mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.edges.mas_equalTo(self.view);
        
    }];
    
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.edges.mas_equalTo(self.rotationView);
        
    }];
    
    [self.topControlView mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.left.right.top.mas_equalTo(self.rotationView);
        make.height.mas_equalTo(40);
        
    }];
    
    [self.bottomControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.bottom.mas_equalTo(self.rotationView);
        make.height.mas_equalTo(45);
        
    }];
    
    [self.presentView mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.edges.mas_equalTo(self.rotationView);
        
    }];
    
    [self.bottomSlider mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.left.right.bottom.mas_equalTo(self.rotationView);
        make.height.mas_equalTo(2);
        
    }];
    
    [self addControlViewTimer];
}

- (void)setUrl:(NSString *)url{
    
    _url = url;
    
    [self setVieoUrl];
    
    [self setAsset];
    
    [self setPlayerItem];

    [self setAvPlayer];
    
    [self setAvPlayerLayer];
    
}

- (void)setVieoUrl{
    
    self.videoURL = [NSURL URLWithString:self.url];
    
}

- (void)setAsset{
    
    self.avAsset = [AVAsset assetWithURL:self.videoURL];
 
    [self observeAvAsset];
}

- (void)setPlayerItem{
    
    self.avPlayerItem = [AVPlayerItem playerItemWithAsset:self.avAsset];
    
    [self observeAvPlayerItem];
    
}

- (void)setAvPlayer{
    
    self.avPlayer = [AVPlayer playerWithPlayerItem:self.avPlayerItem];
    
    [self observeAvPlayer];
    
}

- (void)setAvPlayerLayer{
    
    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    
    [self.playerView.layer addSublayer:self.avPlayerLayer];
    
    self.playerView.avPlayerLayer = self.avPlayerLayer;
    
}

#pragma mark - observeAvAsset -- 给avAsset添加观察者

- (void)observeAvAsset{
    
    NSArray *keys = @[@"duration"];
    
    @weakify(self);
    
    [self.avAsset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        
        @strongify(self);
        
        NSError *error = nil;
        
        AVKeyValueStatus tracksStatus = [self.avAsset statusOfValueForKey:@"duration" error:&error];
        
        switch (tracksStatus) {
            case AVKeyValueStatusLoaded:
            {
                @weakify(self);
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    if(!CMTIME_IS_INDEFINITE(self.avAsset.duration)){
                        //总时间
                        long totalSecond = self.avAsset.duration.value / self.avAsset.duration.timescale;
                        
                        self.bottomControlView.totalSecond = totalSecond;
                        
                        self.presentView.totalSecond = totalSecond;
                        
                        self.bottomSlider.maximumValue = totalSecond;
                    }
                });
            }
                break;
            case AVKeyValueStatusFailed:
            {
                NSLog(@"AVKeyValueStatusFailed失败,请检查网络,或查看plist中是否添加App Transport Security Settings");
            }
                break;
            case AVKeyValueStatusCancelled:
            {
                NSLog(@"AVKeyValueStatusCancelled取消");
            }
                break;
            case AVKeyValueStatusUnknown:
            {
                NSLog(@"AVKeyValueStatusUnknown未知");
            }
                break;
            case AVKeyValueStatusLoading:
            {
                NSLog(@"AVKeyValueStatusLoading正在加载");
            }
                break;
            default:
                break;
        }
        
    }];
    
}

#pragma mark - addTimeObserve -- 给player添加时间监听

- (void)addTimeObserve{
    
    @weakify(self);
    
    _timeObserve = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        
        @strongify(self);
        
        //如果并没有手动操作进度 && video时间有效
        if(!_isHandleProgress && !CMTIME_IS_INDEFINITE(self.avAsset.duration)){
            
            //播放的当前时间
            self.bottomControlView.currentSecond = [self currentPlayerItem].currentTime.value / [self currentPlayerItem].currentTime.timescale;
            
            self.presentView.currentSecond = self.bottomControlView.currentSecond;
            
            self.bottomSlider.value = self.bottomControlView.currentSecond;
            
        }
        
    }];
    
}

#pragma mark - removeTimeObserve -- 移除player的时间监听

- (void)removeTimeObserve{
    
    if(_timeObserve){
        
        [self.avPlayer removeTimeObserver:_timeObserve];
        
        _timeObserve = nil;
        
    }
    
}

#pragma mark - observeAvPlayer -- 给player添加观察者

- (void)observeAvPlayer{
    
    @weakify(self);
    
    [_kvoCtr observe:self.avPlayer keyPath:@"rate" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
      
        @strongify(self);
        
        self.rate = [change[NSKeyValueChangeNewKey] floatValue];
        
        if(self.rate == 0){
            
            self.status = LDPlayerStatusStopped;
            
            self.bottomControlView.isPlaying = NO;
            
        }else{
            
            self.status = LDPlayerStatusPlaying;
            
            self.bottomControlView.isPlaying = YES;
            
        }
        
    }];
    
}

#pragma mark - observeAvPlayerItem -- 给playerItem添加观察者

- (void)observeAvPlayerItem{
    
    @weakify(self);
    
    [_kvoCtr observe:self.avPlayerItem keyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
      
        @strongify(self);
        
        NSInteger playerItemStatus = [change[NSKeyValueChangeNewKey] integerValue];
        
        switch (playerItemStatus) {
            case AVPlayerStatusUnknown:
                self.status = LDPlayerStatusUnknown;
                break;
            case AVPlayerStatusReadyToPlay:
                self.status = LDPlayerStatusReadyToPlay;
                break;
            case AVPlayerItemStatusFailed:
                self.status = LDPlayerStatusFailed;
                break;
            default:
                break;
        }
        
    }];
    
    [_kvoCtr observe:self.avPlayerItem keyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        
        @strongify(self);
        //缓冲进度
        NSTimeInterval bufferSecond = [self getAvailableBufferDuration];
        
        self.bottomControlView.bufferSecond = bufferSecond;
        
    }];
    
    [_kvoCtr observe:self.avPlayerItem keyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
      
        @strongify(self);
        
        self.status = LDPlayerStatusBuffering;
        
//        NSLog(@"开始缓冲视频进度");
        
    }];
    
    [_kvoCtr observe:self.avPlayerItem keyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        
//        @strongify(self);
        
//        NSLog(@"缓冲完成可以播放");
        
    }];

}

#pragma mark - videoPlayEnd -- 播放完成

- (void)videoPlayEnd:(NSNotification *)notify{
    
    @weakify(self);
    
    [self.avPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        
        @strongify(self);
        
        self.bottomControlView.currentSecond = 0;
        
        self.presentView.currentSecond = 0;
        
        self.bottomSlider.value = 0;
        
    }];
    
}

#pragma mark - videoPlayError -- 播放出错

- (void)videoPlayError:(NSNotification *)notify{
    
    
}

#pragma mark - videoPlayEnterBack -- 切换成后台

- (void)videoPlayEnterBack:(NSNotification *)notify{
    
    _enterBackStatus = self.isPlaying;
    
    [self pause];
    
}

#pragma mark - videoPlayBecomeActive -- 切换成前台

- (void)videoPlayBecomeActive:(NSNotification *)notify{
    
    if(_enterBackStatus){
        
        [self play];
        
    }
    
}

#pragma mark - DeviceOrientationDidChange -- 设备方向发生变化

- (BOOL)DeviceOrientationDidChange{
    
    UIDevice *device = [UIDevice currentDevice];
    
    //识别当前设备的旋转方向
    switch (device.orientation) {
        case UIDeviceOrientationLandscapeLeft:
            [self setInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
            NSLog(@"屏幕向左橫置");
            break;
            
        case UIDeviceOrientationLandscapeRight:
            [self setInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
            NSLog(@"屏幕向右橫置");
            break;
            
        case UIDeviceOrientationPortrait:
            [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
            NSLog(@"屏幕直立");
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
            
        default:
            NSLog(@"無法识别");
            break;
    }
    
    return YES;
}

#pragma mark - setInterfaceOrientation -- 设置旋转方向

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation{
    
    [self.rotationView removeFromSuperview];
    
//    NSLog(@"%f  %f", RotationWidth, RotationHeight);
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:{
            
            [self.view addSubview:self.rotationView];
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [UIApplication sharedApplication].statusBarHidden = NO;
            @weakify(self);
            [UIView animateWithDuration:0.25 animations:^{
                @strongify(self);
                
                self.rotationView.transform = CGAffineTransformMakeRotation(0);
                [self.rotationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.view);
                }];
                if(self.topControlView.superview){
                    [self.topControlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.top.mas_equalTo(self.rotationView);
                        make.height.mas_equalTo(40);
                    }];
                }
                
            }];
            self.currentInterfaceOrientation = UIInterfaceOrientationPortrait;
            [self.view layoutIfNeeded];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            
            [self.currentWindow addSubview:self.rotationView];
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            if(self.isControlAppear){
                [UIApplication sharedApplication].statusBarHidden = NO;
            }else{
                [UIApplication sharedApplication].statusBarHidden = YES;
            }
            
            @weakify(self);
            [UIView animateWithDuration:0.25 animations:^{
                @strongify(self);
                
                self.rotationView.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
                [self.rotationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.center.mas_equalTo(self.currentWindow);
                    make.width.mas_equalTo(RotationHeight);
                    make.height.mas_equalTo(RotationWidth);
                }];
                if(self.topControlView.superview){
                    [self.topControlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.top.mas_equalTo(self.rotationView);
                        make.height.mas_equalTo(60);
                    }];
                }
            
            }];
            self.currentInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
            [self.currentWindow layoutIfNeeded];
            
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{

            [self.currentWindow addSubview:self.rotationView];
            [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            if(self.isControlAppear){
                [UIApplication sharedApplication].statusBarHidden = NO;
            }else{
                [UIApplication sharedApplication].statusBarHidden = YES;
            }
            @weakify(self);
            [UIView animateWithDuration:0.25 animations:^{
                @strongify(self);
                
                self.rotationView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                [self.rotationView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.center.mas_equalTo(self.currentWindow);
                    make.width.mas_equalTo(RotationHeight);
                    make.height.mas_equalTo(RotationWidth);
                }];
                if(self.topControlView.superview){
                    [self.topControlView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.left.right.top.mas_equalTo(self.rotationView);
                        make.height.mas_equalTo(60);
                    }];
                }

            }];
            self.currentInterfaceOrientation = UIInterfaceOrientationLandscapeRight;
            [self.currentWindow layoutIfNeeded];
            
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - controlViewAppearMethod -- 控制层显示

- (void)controlViewAppearMethod{
    
    self.bottomSlider.hidden = YES;
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    @weakify(self);
    
    [UIView animateWithDuration:0.3 animations:^{
        
        @strongify(self);
        
        self.topControlView.alpha = 1;
        
        self.bottomControlView.alpha = 1;
        
    } completion:^(BOOL finished) {
      
        [self addControlViewTimer];
        
    }];
    
    
}


#pragma mark - controlViewAppearMethod -- 控制层隐藏

- (void)controlViewDisappearMethod{
    
    @weakify(self);
    
    if(self.currentInterfaceOrientation == UIInterfaceOrientationPortrait){
        [UIApplication sharedApplication].statusBarHidden = NO;
    }else{
        [UIApplication sharedApplication].statusBarHidden = YES;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        @strongify(self);
        
        self.topControlView.alpha = 0;
        
        self.bottomControlView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self removeControlViewTimer];
        
        self.bottomSlider.hidden = NO;
        
    }];
    
}

#pragma mark - presentViewAppearMethod -- presentView显示

- (void)presentViewAppearMethod{
    
    self.presentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.presentView.alpha = 1;
}

#pragma mark - presentViewAppearMethod -- presentView隐藏

- (void)presentViewDissappearMethod{
    
    self.presentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    self.presentView.alpha = 0;
}


#pragma mark - LDTopControlViewDelegate

- (void)controlView:(LDVideoTopControlView *)controlView didSelectBackBtn:(UIButton *)button{
    
    if(kScreenHeight < kScreenWidth){
        
        [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
        
    }else{
        
        if(self.backBtnDidSelectBlock){
            
            self.backBtnDidSelectBlock();
            
        }
        
    }
    
}

#pragma mark - LDBottomControlViewDelegate
//
//- (void)controlView:(LDVideoBottomControlView *)controlView positionSliderLocationWithCurrentValue:(CGFloat)value{
//
//    _isHandleProgress = YES;
//
//    CMTime pointTime = CMTimeMake(value * [self currentPlayerItem].currentTime.timescale, [self currentPlayerItem].currentTime.timescale);
//
//    @weakify(self);
//
//    [[self currentPlayerItem] seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
//
//        @strongify(self);
//
//        _isHandleProgress = NO;
//
//    }];
//
//}

- (void)controlView:(LDVideoBottomControlView *)controlView draggedPositionWithSliderValue:(CGFloat)value{
    
    _isHandleProgress = YES;
    
    [self presentViewAppearMethod];
    
    [self removeControlViewTimer];
    
    self.presentView.currentSecond = value;
    
    self.bottomSlider.value = value;
    
}

- (void)controlView:(LDVideoBottomControlView *)controlView touchUpInsideWithSliderValue:(CGFloat)value{
    
    [self presentViewDissappearMethod];
    
    self.presentView.currentSecond = value;
    
    self.bottomSlider.value = value;
    
    @weakify(self);
    
    CMTime pointTime = CMTimeMake(value * [self currentPlayerItem].currentTime.timescale, [self currentPlayerItem].currentTime.timescale);
    
    [[self currentPlayerItem] seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
        @strongify(self);
        
        [self play];
        
        @weakify(self);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            @strongify(self);
            
            _isHandleProgress = NO;
            
            [self addControlViewTimer];
            
        });
        
    }];
    
    
    
}

- (void)controlView:(LDVideoBottomControlView *)controlView withPlayOrPauseButton:(UIButton *)button{
    
    _controlViewCount = 0;
    
    if(self.isPlaying){
        
        [self pause];
        
    }else {
        
        [self play];
        
    }
    
}

- (void)controlView:(LDVideoBottomControlView *)controlView withLargeButton:(UIButton *)button{
    
    if(self.currentInterfaceOrientation == UIInterfaceOrientationPortrait){
        
        [self setInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
        
    }else{
     
        [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
        
    }
    
}


#pragma mark - playViewPanGesture -- 水平方向更新video进度的手势/垂直方向更新亮度和音量

- (void)playViewPanGesture:(UIPanGestureRecognizer *)gesture{
    
    if(gesture.state == UIGestureRecognizerStateBegan){
        
        //获取开始手势时的坐标
        CGPoint gesturePoint = [gesture locationInView:self.playerView];
        
        _gestureBeginPointX = gesturePoint.x;
        
    }else if(gesture.state == UIGestureRecognizerStateChanged){
        
        //获得当前手势在playView的坐标
        CGPoint translation = [gesture translationInView:self.playerView];
        
        CGFloat absX = fabs(translation.x);
        CGFloat absY = fabs(translation.y);
        
        //取坐标的最大值 设置为滑动无效距离 在此距离内并不会更新进度 在此距离内判断出此次滑动的固定方向
        if (_progressGestureDirection == 0 && MAX(absX, absY) < 15){
            
            if (absX > absY ) {
                if (translation.x < 0) {
                    _progressGestureDirection = LDPanGestureDirectionLeft;
                }else{
                    _progressGestureDirection = LDPanGestureDirectionRight;
                }
            } else if (absY > absX) {
                if (translation.y < 0) {
                    _progressGestureDirection = LDPanGestureDirectionTop;
                }else{
                    _progressGestureDirection = LDPanGestureDirectionBottom;
                }
                
            }
            
            return;
        }

        //如果是横向滑动，更新video的progress
        if(_progressGestureDirection == LDPanGestureDirectionLeft || _progressGestureDirection == LDPanGestureDirectionRight){
            
            if(self.controlAppear){
                
                [self controlViewDisappearMethod];
                
            }
            
            [self presentViewAppearMethod];
            
            _isHandleProgress = YES;
            
            long currentSecond = self.bottomControlView.currentSecond;
            
            //以三个像素为改变一秒的视频进度
            int changeSecond = (int)(translation.x/3.0) - _progressLastSecond;
            
            _progressLastSecond = (int)(translation.x/3.0);
            
            if(changeSecond != 0){
                
                //所更改的进度在视频的时间内
                if(currentSecond + changeSecond >= 0 && currentSecond + changeSecond <= self.bottomControlView.totalSecond){
                    
                    self.bottomControlView.currentSecond = currentSecond + changeSecond;
                    
                    self.presentView.currentSecond = self.bottomControlView.currentSecond;
                    
                    self.bottomSlider.value = self.bottomControlView.currentSecond;
                    
                }
            }
            
        }
        //如果是纵向滑动，更新音量/亮度
        else{
            
            float halfWidth = self.currentInterfaceOrientation == UIInterfaceOrientationPortrait ? self.rotationView.frame.size.width/2.0 : self.rotationView.frame.size.height/2.0;
            
            if(_gestureBeginPointX > halfWidth){
                
                float changeValue = (int)(-translation.y/3) - _volumeLastValue;
                
                _volumeLastValue = (int)(-translation.y/3);
                
                //更新系统音量
                if(changeValue != 0){
                    
                    [self setSystemVolumeValue:changeValue * 0.02];
                    
                }
                
            }else{
                
                float changeValue = (int)(-translation.y/3) - _brightnessLastValue;
                
                _brightnessLastValue = (int)(-translation.y/3);
                
                //更新系统音量
                if(changeValue != 0){
                    
                    [self setSystemBrightnessValue:changeValue * 0.02];
                    
                }
                
            }
            
            
        }
        
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        
        if(_progressGestureDirection == 2 || _progressGestureDirection == 4){
            
            [self presentViewDissappearMethod];
            
            //手势结束后 seekTime
            CMTime pointTime = CMTimeMake(self.bottomControlView.currentSecond * [self currentPlayerItem].currentTime.timescale, [self currentPlayerItem].currentTime.timescale);
            
            @weakify(self);
            
            [[self currentPlayerItem] seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                
                @strongify(self);
                
                [self play];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    _isHandleProgress = NO;
                    
                });
                
            }];
            
        }
        
        _progressLastSecond = 0;
        
        _volumeLastValue = 0;
        
        _brightnessLastValue = 0;
        
        //手势结束
        _progressGestureDirection = LDPanGestureDirectionNone;
        
        _gestureBeginPointX = 0;
    }
    
}



#pragma mark - setSystemVolumeValue -- 设置系统音量

- (void)setSystemVolumeValue:(float)value{
    
    float newVolumeValue = self.volumeValue + value;
    
    newVolumeValue = newVolumeValue > 1 ? 1 : newVolumeValue;
    
    newVolumeValue = newVolumeValue < 0 ? 0 : newVolumeValue;
    
    if(LDSystemVersion >= 7.0){
        
        [self.systemVolumeSlider setValue:newVolumeValue animated:YES];
        
//        [[UIScreen mainScreen] setBrightness:newVolumeValue];
        
    }else{
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // 过期api写在这里不会有警告
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:newVolumeValue];
#pragma clang diagnostic pop
        
    }
    
}

#pragma mark - setSystemBrightnessValue -- 设置系统亮度

- (void)setSystemBrightnessValue:(float)value{
    
    float newBrightnessValue = self.brightnessValue + value;
    
    newBrightnessValue = newBrightnessValue > 1 ? 1 : newBrightnessValue;
    
    newBrightnessValue = newBrightnessValue < 0 ? 0 : newBrightnessValue;
    
    [[UIScreen mainScreen] setBrightness:newBrightnessValue];
    
}

#pragma mark - playOrPauseGesture -- 双击屏幕控制视频的暂停/播放

- (void)playOrPauseGesture:(UIGestureRecognizer *)gesture{
    
    _controlViewCount = 0;
    
    if(self.isPlaying){
        
        [self pause];
        
    }else{
    
        [self play];
        
    }
    
}

#pragma mark - playControlViewAppearOrDissappearGesture -- 点击屏幕管理controlView显示/隐藏

- (void)playControlViewAppearOrDissappearGesture:(UIGestureRecognizer *)gesture{
    
    if(self.isControlAppear){
        
        [self controlViewDisappearMethod];
        
    }else{
        
        [self controlViewAppearMethod];
        
    }
    
}

#pragma mark - controlViewTimeAction -- 控制视图的显示隐藏的倒计时

- (void)controlViewTimeAction{
    
    _controlViewCount += 1;
    
    if(_controlViewCount == 5){
        
        if(self.isControlAppear && self.isPlaying){
            
            [self controlViewDisappearMethod];
            
        }else{
            
            [self removeControlViewTimer];
            
        }
        
    }
    
}

#pragma mark - addNotificationForPlayer -- 添加通知

- (void)addNotificationForPlayer{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayError:) name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayEnterBack:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)removeNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
}

- (void)addControlViewTimer{
    
    [self removeControlViewTimer];
    
    [[NSRunLoop mainRunLoop] addTimer:self.controlViewTimer forMode:NSRunLoopCommonModes];
    
}

- (void)removeControlViewTimer{
    
    _controlViewCount = 0;
    [self.controlViewTimer invalidate];
    self.controlViewTimer = nil;
    
}

- (void)dealloc{
    
    [self stop];
    
}

#pragma mark - muted

- (void)setMuted:(BOOL)muted{
    
    if(self.isMuted != muted){
        
        self.avPlayer.muted = muted;
        
    }
    
}

- (void)setShouldAutorotate:(BOOL)shouldAutorotate{
    
    _shouldAutorotate = shouldAutorotate;
    
    if(_shouldAutorotate){
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DeviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
    }else{
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        
    }
    
}

- (BOOL)isMuted{
    
    return self.avPlayer.isMuted;
    
}

- (void)setAlwaysShowBackBtn:(BOOL)alwaysShowBackBtn{
    
    _alwaysShowBackBtn = alwaysShowBackBtn;
    
    self.topControlView.alwaysShowBackBtn = _alwaysShowBackBtn;
    
}

- (BOOL)isPlaying{
    
    return self.rate > 0 && self.bottomControlView.isPlaying;
    
}

- (UIWindow *)currentWindow{
    
    return [UIApplication sharedApplication].keyWindow;
    
}

- (BOOL)isControlAppear{
    
    if(self.bottomControlView.alpha == 0){
        
        return NO;
        
    }
    
    return YES;
}

- (float)volumeValue{
    
    float volumeValue = 0;
    
    if(LDSystemVersion >= 7.0){
        
        volumeValue = self.systemVolumeSlider.value;
        
    }else{
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // 过期api写在这里不会有警告
        volumeValue = [[MPMusicPlayerController applicationMusicPlayer] volume];
#pragma clang diagnostic pop
        
    }
    
    return volumeValue;
}

- (float)brightnessValue{
    
    return [UIScreen mainScreen].brightness;
    
}

#pragma mark - getAvailableBufferDuration -- 获得缓冲区的长度

- (NSTimeInterval)getAvailableBufferDuration{
    
    NSArray *loadedTimeRanges = [[self currentPlayerItem] loadedTimeRanges];
    
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    
    NSTimeInterval result = startSeconds + durationSeconds;
    
    return result;
    
}

- (AVPlayerItem *)currentPlayerItem{
    
    return self.avPlayer.currentItem;
    
}

- (LDVideoPlayerView *)playerView{
    
    if(!_playerView){
        
        _playerView = [[LDVideoPlayerView alloc]init];
        
        _playerView.backgroundColor = [UIColor blackColor];
    
        [_playerView addGestureRecognizer:self.panGestureRecognizer];
        
        [_playerView addGestureRecognizer:self.tapGestureRecognizer];
        
        [_playerView addGestureRecognizer:self.doubleTapGestureRecognizer];
        
    }
    
    return _playerView;
}

- (LDVideoTopControlView *)topControlView{
    
    if(!_topControlView){
        
        _topControlView = [[LDVideoTopControlView alloc]init];
        
        _topControlView.delegate = self;
        
    }
    
    return _topControlView;
}

- (LDVideoBottomControlView *)bottomControlView{
    
    if(!_bottomControlView){
        
        _bottomControlView = [[LDVideoBottomControlView alloc]init];
        
        _bottomControlView.delegate = self;
        
    }
    
    return _bottomControlView;
}

- (UIView *)view{
    
    if(!_view){
        
        _view = [[UIView alloc]init];
        
    }
    
    return _view;
}

- (UIView *)rotationView{
    
    if(!_rotationView){
        
        _rotationView = [[UIView alloc]init];
        
    }
    
    return _rotationView;
}

- (UIPanGestureRecognizer *)panGestureRecognizer{
    
    if(!_panGestureRecognizer){
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(playViewPanGesture:)];
        
    }
    
    return _panGestureRecognizer;
}

- (UITapGestureRecognizer *)tapGestureRecognizer{
 
    if(!_tapGestureRecognizer){
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playControlViewAppearOrDissappearGesture:)];
        
        [_tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
        
    }
    
    return _tapGestureRecognizer;
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer{
    
    if(!_doubleTapGestureRecognizer){
        
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playOrPauseGesture:)];
        
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        
    }
    
    return _doubleTapGestureRecognizer;
}

- (NSTimer *)controlViewTimer{
    
    if(!_controlViewTimer){
        
        _controlViewTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(controlViewTimeAction) userInfo:nil repeats:YES];
        
    }
    
    return _controlViewTimer;
}

- (LDVideoPresentView *)presentView{
    
    if(!_presentView){
        
        _presentView = [[LDVideoPresentView alloc]init];
        
        _presentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        
        self.presentView.alpha = 0;
        
    }
    
    return _presentView;
}

- (UISlider *)bottomSlider{
    
    if(!_bottomSlider){
        
        _bottomSlider = [[UISlider alloc]init];
        
        [_bottomSlider setThumbImage:[UIImage new] forState:UIControlStateNormal];
        
        _bottomSlider.continuous = YES;
        
        _bottomSlider.minimumTrackTintColor = [UIColor redColor];
        
        _bottomSlider.maximumTrackTintColor = [UIColor whiteColor];
        
        _bottomSlider.minimumValue = 0;
        
        _bottomSlider.maximumValue = 1;
        
        _bottomSlider.value = 0.4;
        
        _bottomSlider.userInteractionEnabled = NO;
        
        _bottomSlider.hidden = YES;
        
    }
    
    return _bottomSlider;
}

- (UISlider *)systemVolumeSlider{
    
    if(!_systemVolumeSlider){
        
        _systemVolumeSlider = [self getSystemVolumeSlider];
        
    }
    
    return _systemVolumeSlider;
}

- (UISlider *)getSystemVolumeSlider{
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    
    for (UIView *view in [volumeView subviews]){
        
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            
            return (UISlider*)view;
            
            break;
        }
        
    }
    
    return nil;
}

- (void)play{
    
    [self addControlViewTimer];

    [self addTimeObserve];
    
    [self.avPlayer play];
    
}

- (void)pause{
    
    [self removeControlViewTimer];
    
    [self removeTimeObserve];
    
    [self.avPlayer pause];
    
}

- (void)stop{
    
    [self removeNotification];
    [self removeTimeObserve];
    [self removeControlViewTimer];
//    [self.avPlayerItem removeObserver:self forKeyPath:@"status"];
//    [self.avPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
//    [self.avPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
//    [self.avPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
//    [self.avPlayer removeObserver:self forKeyPath:@"rate"];
    if(self.avPlayer){
        [self pause];
        self.avAsset = nil;
        self.avPlayerItem = nil;
        self.avPlayer = nil;
        self.bottomControlView.totalSecond = 0;
        self.bottomControlView.currentSecond = 0;
        self.presentView.totalSecond = 0;
        self.presentView.currentSecond = 0;
        self.bottomSlider.maximumValue = 0;
        self.bottomSlider.value = 0;
        [self.rotationView removeFromSuperview];
        [self.view removeFromSuperview];
    }
    
}

- (void)setMode:(LDPlayerLayerGravity)mode{
    
    switch (mode) {
        case LDLayerVideoGravityResizeAspect:
            self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            break;
            
        case LDLayerVideoGravityResizeAspectFill:
            self.avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            break;
            
        case LDLayerVideoGravityResize:
            self.avPlayerLayer.videoGravity = AVLayerVideoGravityResize;
            break;
            
        default:
            break;
    }
    
}

@end
