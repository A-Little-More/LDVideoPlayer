//
//  LDVideoPlayerView.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/6/26.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import "LDVideoPlayerView.h"

@interface LDVideoPlayerView ()


@end

@implementation LDVideoPlayerView

- (instancetype)init{
    
    self = [super init];
    
    if(self){
        
        [self initFrame];
        
    }
    
    return self;
}


- (void)initFrame{
    
    
}

- (void)setAvPlayerLayer:(AVPlayerLayer *)avPlayerLayer{
  
    _avPlayerLayer = avPlayerLayer;
    
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    self.avPlayerLayer.frame = self.bounds;
    
}

@end
