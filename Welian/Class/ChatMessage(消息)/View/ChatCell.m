//
//  ChatCell.m
//  RongCloudDemo
//
//  Created by weLian on 15/6/3.
//  Copyright (c) 2015年 liuwu. All rights reserved.
//

#import "ChatCell.h"

@interface ChatCell ()

@property (assign,nonatomic) UIView *contentInfoView;

@end

@implementation ChatCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [self.messageContentView setDebug:YES];
        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [self setDebug:YES];
    
    /**
     *  消息方向
     */
//    @property(nonatomic) RCMessageDirection messageDirection
    
//    [self.portraitImageView ]
//    self.messageContentView.width = self.width;
//    self.messageContentView.width = self.messageContentViewWidth;
//    self.messageContentView.height = 200.f;
    self.baseContentView.size = CGSizeMake(self.width, self.height);
    
    _contentInfoView.size = CGSizeMake(200, 100);
    _contentInfoView.left = 50;
    _contentInfoView.bottom = self.height;
    
    
    
//    self.nicknameLabel.right =
//    /**
//     *  用户头像
//     */
//    @property(nonatomic, strong) RCloudImageView *portraitImageView;
//    
//    /**
//     *  用户昵称
//     */
//    @property(nonatomic, strong) UILabel *nicknameLabel;
//    
//    /**
//     *  消息内容视图
//     */
//    @property(nonatomic, strong) RCContentView *messageContentView;
//    
//    /**
//     *  消息状态视图
//     */
//    @property(nonatomic, strong) UIView *statusContentView;
//    
//    /**
//     *  消息发送失败状态视图
//     */
//    @property(nonatomic, strong) UIButton *messageFailedStatusView;
//    
//    /**
//     *  消息发送指示视图
//     */
//    @property(nonatomic, strong) UIActivityIndicatorView *messageActivityIndicatorView;
}

#pragma mark - Private
- (void)setup
{
    UIView *contentInfoView = [[UIView alloc] init];
    contentInfoView.backgroundColor = [UIColor blueColor];
    [self.baseContentView addSubview:contentInfoView];
    self.contentInfoView = contentInfoView;
}

@end
