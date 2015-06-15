//
//  ChatRoomListViewCell.m
//  Welian
//
//  Created by weLian on 15/6/13.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ChatRoomListViewCell.h"

#define kLogoWidth 40.f
#define kMarginLeft 15.f
#define kMarginTop 10.f

@interface ChatRoomListViewCell ()

@property (assign, nonatomic) UIImageView *logoImageView;
@property (assign, nonatomic) UILabel *nameLabel;
@property (assign, nonatomic) UILabel *messageLabel;

@end

@implementation ChatRoomListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setChatRoomInfo:(IChatRoomInfo *)chatRoomInfo
{
    [super willChangeValueForKey:@"chatRoomInfo"];
    _chatRoomInfo = chatRoomInfo;
    [super didChangeValueForKey:@"chatRoomInfo"];
    _nameLabel.text = _chatRoomInfo.title;
    _messageLabel.text = [NSString stringWithFormat:@"%d人在线",0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _logoImageView.size = CGSizeMake(kLogoWidth, kLogoWidth);
    _logoImageView.top = kMarginTop;
    _logoImageView.left = kMarginLeft;
    
    [_nameLabel sizeToFit];
    CGFloat nameMaxWidth = self.width - _logoImageView.right - kMarginLeft * 2.f;
    if (_nameLabel.width > nameMaxWidth) {
        _nameLabel.width = nameMaxWidth;
    }
    _nameLabel.left = _logoImageView.right + kMarginLeft;
    _nameLabel.top = _logoImageView.top;
    
    [_messageLabel sizeToFit];
    _messageLabel.top = _nameLabel.bottom + 5.f;
    _messageLabel.left = _nameLabel.left;
}

#pragma mark - Private
- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //头像
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.backgroundColor = KBgLightGrayColor;
    logoImageView.layer.cornerRadius = kLogoWidth / 2.f;
    logoImageView.layer.masksToBounds = YES;
    [self addSubview:logoImageView];
    self.logoImageView = logoImageView;
    
    //名称
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = kTitleNormalTextColor;
    nameLabel.font = kNormal16Font;
    nameLabel.text = @"迭代资本聊天室";
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    //内容
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = kTitleTextColor;
    messageLabel.font = kNormal14Font;
    messageLabel.text = @"20 人在线";
    [self addSubview:messageLabel];
    self.messageLabel = messageLabel;
}

@end
