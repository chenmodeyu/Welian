//
//  MessageCell.m
//  weLian
//
//  Created by dong on 14/11/13.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "MessageCell.h"
#import "MLEmojiLabel.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ImageEffects.h"

@interface MessageCell ()<MLEmojiLabelDelegate>
{
    // 头像
    UIImageView *_iconImage;
    // 姓名
    UILabel *_nameLabel;
    // 对我的评论
    MLEmojiLabel *_commentLabel;
    // 时间
    UILabel *_timeLabel;
    // 动态图片
    UIImageView *_photImage;
    // 动态说说
    MLEmojiLabel *_trendsLabel;
    // 赞转发图片
    UIImageView *_zanfeedImage;
}

@end

@implementation MessageCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *messageCellid = @"messageCellid";
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCellid];
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageCellid];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 设置背景
//        [self setupBg];
        
        // 加载ui
        [self loadUIview];
    }
    return self;
}

/**
 *  设置背景
 */
- (void)setupBg
{
    // 1.默认
    UIImageView *bg = [[UIImageView alloc] init];
    bg.image = [UIImage resizedImage:@"tabbar_b"];
    self.backgroundView = bg;
    // 2.选中
    UIImageView *selectedBg = [[UIImageView alloc] init];
    selectedBg.image = [UIImage resizedImage:@"tabbar_b"];
    self.selectedBackgroundView = selectedBg;
}


- (void)loadUIview
{
    _iconImage = [[UIImageView alloc] init];
    [self.contentView addSubview:_iconImage];
    
    _nameLabel = [[UILabel alloc] init];
    [_nameLabel setFont:IWContentFont];
    [self.contentView addSubview:_nameLabel];
    
    _commentLabel = [[MLEmojiLabel alloc]init];
    _commentLabel.numberOfLines = 0;
    _commentLabel.emojiDelegate = self;
    _commentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _commentLabel.isNeedAtAndPoundSign = YES;
    _commentLabel.font = IWContentFont;
    _commentLabel.textColor = IWContentColor;
    _commentLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_commentLabel];
    
    
    _timeLabel = [[UILabel alloc] init];
    [_timeLabel setTextColor:IWSourceColor];
    [_timeLabel setFont:IWTimeFont];
    [self.contentView addSubview:_timeLabel];
    
    _photImage = [[UIImageView alloc] init];
    _photImage.contentMode = UIViewContentModeScaleAspectFill;
    // 超出边界范围的内容都裁剪
    _photImage.clipsToBounds = YES;
    [self.contentView addSubview:_photImage];
    
    _trendsLabel = [[MLEmojiLabel alloc]init];
    _trendsLabel.numberOfLines = 0;
    _trendsLabel.emojiDelegate = self;
    _trendsLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _trendsLabel.isNeedAtAndPoundSign = YES;
    _trendsLabel.font = [UIFont systemFontOfSize:15];
    _trendsLabel.textColor = IWContentColor;
    _trendsLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_trendsLabel];
    
    _zanfeedImage = [[UIImageView alloc] init];
    [self.contentView addSubview:_zanfeedImage];
    
}


- (void)setMessageFrameModel:(MessageFrameModel *)messageFrameModel
{
    _messageFrameModel = messageFrameModel;
    MessageHomeModel *messageDataM = messageFrameModel.messageDataM;
    
    [_iconImage setFrame:messageFrameModel.iconImageF];
    [_iconImage sd_setImageWithURL:[NSURL URLWithString:messageDataM.avatar] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRetryFailed|SDWebImageLowPriority];
    
    [_nameLabel setFrame:messageFrameModel.nameLabelF];
    [_nameLabel setText:messageDataM.name];
    if ([messageDataM.type isEqualToString:@"feedComment"]) {
        [_zanfeedImage setHidden:YES];
        [_commentLabel setHidden:NO];
        _commentLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        _commentLabel.customEmojiPlistName = @"expressionImage_custom";
        [_commentLabel setFrame:messageFrameModel.commentLabelF];
        [_commentLabel setText:messageDataM.msg];

    }else{
        [_commentLabel setHidden:YES];
        [_zanfeedImage setHidden:NO];
        
        [_zanfeedImage setFrame:messageFrameModel.zanfeedImageF];
        
        if ([messageDataM.type isEqualToString:@"feedZan"]){
            [_zanfeedImage setImage:[UIImage imageNamed:@"good_small"]];
            
        }else if ([messageDataM.type isEqualToString:@"feedForward"]){
            [_zanfeedImage setImage:[UIImage imageNamed:@"repost_small"]];
        }
        [_zanfeedImage sizeToFit];
    }
    [_timeLabel setText:messageDataM.tiem];
    [_timeLabel setFrame:messageFrameModel.timeLabelF];

    
    [_photImage setFrame:messageFrameModel.photImageF];
    if (![messageDataM.feedpic isEqualToString:@"null"]) {
        [_trendsLabel setHidden:YES];
        [_photImage sd_setImageWithURL:[NSURL URLWithString:messageDataM.feedpic] placeholderImage:[UIImage imageNamed:@"picture_loading"] options:SDWebImageRetryFailed|SDWebImageLowPriority];
    }else{
        [_trendsLabel setHidden:NO];
        [_photImage setImage:[UIImage resizedImage:@"login_input"]];
        _trendsLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        _trendsLabel.customEmojiPlistName = @"expressionImage_custom";
        [_trendsLabel setFrame:messageFrameModel.trendsLabelF];
        [_trendsLabel setText:messageDataM.feedcontent];
        [_trendsLabel sizeToFit];
        if (_trendsLabel.frame.size.height>messageFrameModel.trendsLabelF.size.height) {
            [_trendsLabel setFrame:messageFrameModel.trendsLabelF];
        }
    }
   
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
