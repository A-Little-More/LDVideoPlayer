//
//  VideoListTableViewCell.h
//  LDVideoPlayer
//
//  Created by lidong on 2018/7/3.
//  Copyright © 2018年 macbook. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoListTableViewCell;

@protocol LDVideoListTableViewCellDelegate <NSObject>

@optional

/**
 *  点击播放的代理回调
 */
- (void)clickedPlayOnTabCell:(VideoListTableViewCell *)cell playerParentView:(UIView *)playerParentView;

@end

@interface VideoListTableViewCell : UITableViewCell

@property (nonatomic, weak) id<LDVideoListTableViewCellDelegate> delegate;

@end




