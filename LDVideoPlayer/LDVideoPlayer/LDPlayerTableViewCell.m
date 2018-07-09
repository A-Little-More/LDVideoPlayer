//
//  LDPlayerTableViewCell.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/7/9.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import "LDPlayerTableViewCell.h"

@implementation LDPlayerTableViewCell

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
    
    [self.contentView addSubview:self.LDImageV];
    
    [self.LDImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (LDImageView *)LDImageV{
    
    if(!_LDImageV){
        
        _LDImageV = [[LDImageView alloc]init];
        
        _LDImageV.userInteractionEnabled = YES;
        
    }
    
    return _LDImageV;
}

@end
