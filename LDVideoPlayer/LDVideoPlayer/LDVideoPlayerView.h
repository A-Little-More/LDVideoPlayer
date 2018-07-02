//
//  LDVideoPlayerView.h
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/26.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface LDVideoPlayerView : UIView

@property (nonatomic, strong, readwrite)AVPlayerLayer *avPlayerLayer;

@end
