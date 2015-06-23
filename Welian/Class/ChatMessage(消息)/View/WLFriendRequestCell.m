//
//  WLFriendRequestCell.m
//  Welian
//
//  Created by dong on 15/6/19.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "WLFriendRequestCell.h"

#define kLogoImageWidth 45.f
#define kMarginLeft 15.f
#define kBadgeHeight 17.f
#define kBadge2Width 24.f
#define K10MarginLeft 10.f

@interface WLFriendRequestCell ()

@property (assign,nonatomic) UIImageView *logoImageView;
@property (assign,nonatomic) UIButton *numBtn;
@property (assign,nonatomic) UILabel *nickNameLabel;
@property (assign,nonatomic) UILabel *timeLabel;
//@property (assign,nonatomic) UILabel *messageLabel;

@end

@implementation WLFriendRequestCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
        self.selectedBackgroundView = [UIView new];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //设置下边边线
    self.layer.borderColor = RGB(230, 230, 230).CGColor;
    self.layer.borderWidths = @"{0,0,0.5,0}";
    
    //设置头像
    _logoImageView.size = CGSizeMake(kLogoImageWidth, kLogoImageWidth);
    _logoImageView.left = kMarginLeft;
    _logoImageView.centerY = self.height / 2.f;
    
#warning fsafdsafadsfdas
    //消息数量
    _numBtn.size = CGSizeMake(1 < 100 ? kBadgeHeight : kBadge2Width, kBadgeHeight);
    _numBtn.top = _logoImageView.top -3;
    _numBtn.right = _logoImageView.right + 8;
    
    //时间
    [_timeLabel sizeToFit];
    _timeLabel.top = _logoImageView.top;
    _timeLabel.right = self.width - kMarginLeft;
    
    //昵称
    [_nickNameLabel sizeToFit];
    _nickNameLabel.width = _timeLabel.left - _logoImageView.right - kMarginLeft * 2;
    _nickNameLabel.left = _logoImageView.right + K10MarginLeft;
    _nickNameLabel.top = _logoImageView.top;
    _nickNameLabel.height = kLogoImageWidth;
    
    //消息
//    [_messageLabel sizeToFit];
//    _messageLabel.width = self.width - K10MarginLeft * 2.f;
//    _messageLabel.left = _nickNameLabel.left;
//    _messageLabel.top = _nickNameLabel.bottom + 5.f;
    
}


#pragma mark - Private
- (void)setup
{
    //头像
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.backgroundColor = [UIColor clearColor];
    logoImageView.layer.cornerRadius = 20;
    logoImageView.layer.masksToBounds = YES;
    [self addSubview:logoImageView];
    self.logoImageView = logoImageView;
    [_logoImageView setImage:[UIImage imageNamed:@"chat_newfriend"]];
//    [_logoImageView sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:@"chat_newfriend"] options:SDWebImageRetryFailed|SDWebImageLowPriority];
    
    
    //消息数量
    UIButton *numBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    numBtn.backgroundColor = [UIColor clearColor];
    numBtn.titleLabel.font = kNormal12Font;
    //    numBtn.titleEdgeInsets = UIEdgeInsetsMake(.0, 2, .0, .0);
    //    [numBtn setTitle:@"99" forState:UIControlStateNormal];
    [numBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [numBtn setBackgroundImage:[UIImage imageNamed:@"notification_badge1"] forState:UIControlStateNormal];
    [self addSubview:numBtn];
    self.numBtn = numBtn;
    
    //昵称
    UILabel *nickNameLabel = [[UILabel alloc] init];
    nickNameLabel.backgroundColor = [UIColor clearColor];
//    nickNameLabel.textColor = RGB(51.f, 51.f, 51.f);
    nickNameLabel.font = WLFONT(16);
    nickNameLabel.text = @"新的好友";
    [self addSubview:nickNameLabel];
    self.nickNameLabel = nickNameLabel;
    
    //时间
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = RGB(173.f, 173.f, 173.f);
    timeLabel.font = kNormal12Font;
    timeLabel.text = @"";
    [self addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    //消息
//    UILabel *messageLabel = [[UILabel alloc] init];
//    messageLabel.backgroundColor = [UIColor clearColor];
//    messageLabel.textColor = RGB(173.f, 173.f, 173.f);
//    messageLabel.font = kNormal14Font;
//    messageLabel.text = @"";
//    [self addSubview:messageLabel];
//    self.messageLabel = messageLabel;
}

@end
