//
//  WLChatCustomCardCell.m
//  Welian
//
//  Created by dong on 15/6/17.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "WLChatCustomCardCell.h"
#import "CustomCardMessage.h"
#import "UIImage+ImageEffects.h"

#import "WLMessageBubbleFactory.h"

#define InfoMaxWidth (CGRectGetWidth([[UIScreen mainScreen] bounds]) * (0.65))

@interface WLChatCustomCardCell ()
{
    LogInUser *_logUser;
    UIImageView *_baseImageView;
    RCMessageModel *_cellMessageModel;
}

@end

@implementation WLChatCustomCardCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _logUser = [LogInUser getCurrentLoginUser];
        [self.baseContentView setFrame:CGRectMake(0, 10, frame.size.width, frame.size.height)];
        _baseImageView = [[UIImageView alloc] init];
        [self.baseContentView addSubview:_baseImageView];
        [self.messageTimeLabel setFrame:CGRectMake(0, 10, 100, 20)];
        [self.messageTimeLabel setTextAlignment:NSTextAlignmentCenter];
        self.messageTimeLabel.marginInsets = UIEdgeInsetsMake(0, 0, -10, 0);
        
        self.avatorBut = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 45, 45)];
        [self.avatorBut addTarget:self action:@selector(iconClickBut) forControlEvents:UIControlEventTouchUpInside];
        [self.avatorBut.layer setMasksToBounds:YES];
        [self.avatorBut.layer setCornerRadius:45*0.5];
        [self.avatorBut setDebug:YES];
        [self.baseContentView addSubview:self.avatorBut];
        self.msgCardView = [[WLMessageCardView alloc] init];
        self.msgCardView.top = 0;
        [self.baseContentView addSubview:self.msgCardView];
        
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        [singleTapGestureRecognizer setNumberOfTapsRequired:1];
        [self.msgCardView addGestureRecognizer:singleTapGestureRecognizer];
        
        UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerHandle:)];
        longPressGr.minimumPressDuration = .5;
        [self.msgCardView addGestureRecognizer:longPressGr];
    }
    return self;
}



// 长按卡片
- (void)longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    
    CustomCardMessage *customCardM = (CustomCardMessage *)_cellMessageModel.content;
    if (longPressGestureRecognizer.state != UIGestureRecognizerStateBegan || ![self becomeFirstResponder])
        return;
    NSMutableArray *menuArray = [NSMutableArray array];
    if (customCardM.content.length) {
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"copy", @"MessageDisplayKitString", @"复制文本消息") action:@selector(copyed:)];
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"删除", @"MessageDisplayKitString", @"删除") action:@selector(deleteCell:)];
        [menuArray addObjectsFromArray:@[copyItem,deleteItem]];
    }else{
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"删除", @"MessageDisplayKitString", @"删除") action:@selector(deleteCell:)];
        [menuArray addObjectsFromArray:@[deleteItem]];
        
    }
    
    if (menuArray.count) {
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:menuArray];
        
        CGRect targetRect = [self convertRect:longPressGestureRecognizer.view.frame fromView:self.baseContentView];
        
        [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:self];
        [menu setMenuVisible:YES animated:YES];
    }
}


// 单击卡片
- (void)singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    if (self.chatCardBlock) {
        self.chatCardBlock();
    }
}
// 点击头像
- (void)iconClickBut
{
    if (self.chatIconBlock) {
        self.chatIconBlock();
    }
}

- (void)setDataModel:(RCMessageModel *)model
{
    _cellMessageModel = model;
    self.messageDirection = model.messageDirection;
    CustomCardMessage *customCardM = (CustomCardMessage *)model.content;
    
    [self.avatorBut sd_setImageWithURL:[NSURL URLWithString:customCardM.portraitUri] forState:UIControlStateNormal];
    
    [self.messageTimeLabel setHidden:!model.isDisplayMessageTime];
    if (model.isDisplayMessageTime) {
        [self.messageTimeLabel setText:[NSString stringWithFormat:@"%lld",model.sentTime]];
        self.baseContentView.top = self.messageTimeLabel.bottom+10;
        self.messageTimeLabel.centerx = self.centerx;
    }else{
        self.baseContentView.top = 10;
    }
    CGSize msgCardsize = [WLMessageCardView calculateCellSizeWithCardMessage:customCardM];
    [self.msgCardView setWidth:msgCardsize.width];
    [self.msgCardView setHeight:msgCardsize.height];
    
    CardStatuModel *cardM = [CardStatuModel objectWithDict:customCardM.card];
    self.msgCardView.cardInfo = cardM;
    WLBubbleMessageType direcType;
    if (model.messageDirection == MessageDirection_SEND) {
        self.avatorBut.right = self.bounds.size.width-10;
        self.msgCardView.right = self.avatorBut.left -15;
        direcType = WLBubbleMessageTypeSending;
        [_baseImageView setFrame:self.msgCardView.frame];
    }else{
        direcType = WLBubbleMessageTypeReceiving;
        self.avatorBut.left = 10;
        self.msgCardView.left = self.avatorBut.right +15;
        [_baseImageView setFrame:self.msgCardView.frame];
        _baseImageView.left -= 5;
    }
    _baseImageView.width += 5;
    _baseImageView.image = [WLMessageBubbleFactory bubbleImageViewForType:direcType style:WLBubbleImageViewStyleWeChat meidaType:WLBubbleMessageMediaTypeCard];
}

+ (CGSize)getCellSizeWithCardMessage:(CustomCardMessage *)cardMsg
{
    CGSize msgCardsize = [WLMessageCardView calculateCellSizeWithCardMessage:cardMsg];
    
    return CGSizeMake(InfoMaxWidth, msgCardsize.height+10);
}


#pragma mark - Copying Method

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copyed:) || action == @selector(transpond:) || action == @selector(favorites:) || action == @selector(more:) || action == @selector(deleteCell:));
}

#pragma mark - Menu Actions
// 复制
- (void)copyed:(id)sender {
    CustomCardMessage *customCardM = (CustomCardMessage *)_cellMessageModel.content;
    [[UIPasteboard generalPasteboard] setString:customCardM.content];
    [self resignFirstResponder];
}
// 删除
- (void)deleteCell:(id)sender{
    if (self.chatDeleteBlock) {
        self.chatDeleteBlock();
    }
}
// 转发
- (void)transpond:(id)sender {

}
// 收藏
- (void)favorites:(id)sender {
    DLog(@"Cell was favorites");
}

// 更多
- (void)more:(id)sender {
    DLog(@"Cell was more");
}

@end
