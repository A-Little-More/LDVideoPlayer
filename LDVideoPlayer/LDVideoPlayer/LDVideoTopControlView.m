//
//  LDVideoTopControlView.m
//  LDVideoPlayer
//
//  Created by lidong on 2018/7/2.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import "LDVideoTopControlView.h"

@interface LDVideoTopControlView ();

@property (nonatomic, strong, readwrite)UIButton *backBtn;

@property (nonatomic, strong, readwrite)UILabel *titleLabel;

@end

@implementation LDVideoTopControlView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        
        [self initFrame];
        
    }
    
    return self;
}

- (void)initFrame{
    
    [self addSubview:self.backBtn];
    [self addSubview:self.titleLabel];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10);
        make.centerY.mas_equalTo(self).offset(10);
        make.width.height.mas_equalTo(32);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backBtn.mas_right).offset(10);
        make.right.mas_equalTo(self).offset(-10);
        make.centerY.mas_equalTo(self.backBtn);
    }];
    
}

- (void)layoutSubviews{
    
    if(kScreenWidth < kScreenHeight){
        
        if(self.alwaysShowBackBtn){
            
            [self.backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(10);
                make.centerY.mas_equalTo(self).offset(10);
                make.width.height.mas_equalTo(32);
            }];
            
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.backBtn.mas_right).offset(10);
                make.right.mas_equalTo(self).offset(-10);
                make.centerY.mas_equalTo(self.backBtn);
            }];
            
        }else{
         
            [self.backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(0);
                make.centerY.mas_equalTo(self).offset(10);
                make.width.height.mas_equalTo(0);
            }];
            
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.backBtn.mas_right).offset(20);
                make.right.mas_equalTo(self).offset(-20);
                make.centerY.mas_equalTo(self.backBtn);
            }];
            
        }
        
    }else{
        
        [self.backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(10);
            make.centerY.mas_equalTo(self).offset(10);
            make.width.height.mas_equalTo(40);
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.backBtn.mas_right).offset(10);
            make.right.mas_equalTo(self).offset(-10);
            make.centerY.mas_equalTo(self.backBtn);
        }];
        
    }
    
}

- (void)setTitle:(NSString *)title{
    
    _title = title;
    
    self.titleLabel.text = _title == nil ? @"" : _title;
    
}

- (void)setAlwaysShowBackBtn:(BOOL)alwaysShowBackBtn{
    
    _alwaysShowBackBtn = alwaysShowBackBtn;
    
    [self setNeedsLayout];
    
}

- (void)backBtnPress:(UIButton *)btn{
    
    if([self.delegate respondsToSelector:@selector(controlView:didSelectBackBtn:)]){
        
        [self.delegate controlView:self didSelectBackBtn:btn];
        
    }
    
}

- (UIButton *)backBtn{
    
    if(!_backBtn){
        
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_backBtn setImage:[UIImage imageNamed:@"backBtn"] forState:UIControlStateNormal];
        
        [_backBtn addTarget:self action:@selector(backBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _backBtn;
}

- (UILabel *)titleLabel{
    
    if(!_titleLabel){
        
        _titleLabel = [[UILabel alloc]init];
        
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        _titleLabel.textColor = [UIColor whiteColor];
        
        _titleLabel.font = [UIFont systemFontOfSize:17];
        
        _titleLabel.text = @"text文字";
    }
    
    return _titleLabel;
}

@end
