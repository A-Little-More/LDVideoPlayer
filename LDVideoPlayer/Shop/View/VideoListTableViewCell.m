//
//  VideoListTableViewCell.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/7/3.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import "VideoListTableViewCell.h"

@interface VideoListTableViewCell ();

@property (nonatomic, strong)UILabel *videoTitleLabel;

@property (nonatomic, strong)UIImageView *videoCoverImg;

@property (nonatomic, strong)UIImageView *playImg;

@end

@implementation VideoListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self){
        
        [self initFrame];
        
    }
    
    return self;
}

- (void)initFrame{
    
    [self addSubview:self.videoTitleLabel];
    [self addSubview:self.videoCoverImg];
    [self.videoCoverImg addSubview:self.playImg];
    
    [self.videoTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self).offset(-10);
        make.top.mas_equalTo(self).offset(10);
    }];
    
    [self.videoCoverImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.top.mas_equalTo(self.videoTitleLabel.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self).offset(-10);
    }];
    
    [self.playImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.videoCoverImg);
        make.width.height.mas_equalTo(60);
    }];
    
}

- (void)tapVideoCoverImg:(UIGestureRecognizer *)gesture{
    
    if([self.delegate respondsToSelector:@selector(clickedPlayOnTabCell:playerParentView:)]){

        [self.delegate clickedPlayOnTabCell:self playerParentView:gesture.view];

    }
    
}

- (UILabel *)videoTitleLabel{
    
    if(!_videoTitleLabel){
        
        _videoTitleLabel = [[UILabel alloc]init];
        
        _videoTitleLabel.textColor = [UIColor blackColor];
        
        _videoTitleLabel.font = [UIFont systemFontOfSize:17];
     
        _videoTitleLabel.text = @"视频的标题，不知道起什么名字";
    }
    
    return _videoTitleLabel;
}

- (UIImageView *)videoCoverImg{
    
    if(!_videoCoverImg){
        
        _videoCoverImg = [[UIImageView alloc]init];
     
        _videoCoverImg.image = [UIImage imageNamed:@"coverImg"];
        
        _videoCoverImg.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapVideoCoverImg:)];
        
        [_videoCoverImg addGestureRecognizer:tap];
    }
    
    return _videoCoverImg;
}

- (UIImageView *)playImg{
    
    if(!_playImg){
        
        _playImg = [[UIImageView alloc]init];
        
        _playImg.image = [UIImage imageNamed:@"playImg"];
        
    }
    
    return _playImg;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
