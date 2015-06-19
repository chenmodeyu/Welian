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
    UILabel *_timeLabel;
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
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 100, 20)];
        [_timeLabel setBackgroundColor:WLRGB(188, 188, 188)];
        [_timeLabel setTextAlignment:NSTextAlignmentCenter];
        [_timeLabel setTextColor:[UIColor whiteColor]];
        [_timeLabel.layer setMasksToBounds:YES];
        [_timeLabel.layer setCornerRadius:5];
        [_timeLabel setFont:WLFONT(13)];
        [self addSubview:_timeLabel];

        self.avatorBut = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 45, 45)];
        [self.avatorBut addTarget:self action:@selector(iconClickBut) forControlEvents:UIControlEventTouchUpInside];
        [self.avatorBut.layer setMasksToBounds:YES];
        [self.avatorBut.layer setCornerRadius:45*0.5];
        
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
    if (customCardM.msg.length) {
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
    
    [self.avatorBut sd_setImageWithURL:[NSURL URLWithString:[customCardM.fromuser objectForKey:@"avatar"]] forState:UIControlStateNormal];
    
    [_timeLabel setHidden:!model.isDisplayMessageTime];
    if (model.isDisplayMessageTime) {
        [_timeLabel setText:[self formatterTimeText:model.receivedTime/1000]];
        self.baseContentView.top = _timeLabel.bottom+10;
        CGSize timeLsize = [_timeLabel.text sizeWithCustomFont:WLFONT(13) constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
        _timeLabel.width = timeLsize.width+10;
        _timeLabel.centerx = self.centerx;

    }else{
        self.baseContentView.top = 10;
    }
    CGSize msgCardsize = [WLMessageCardView calculateCellSizeWithCardMessage:customCardM];
    [self.msgCardView setWidth:msgCardsize.width];
    [self.msgCardView setHeight:msgCardsize.height];
    
    CardStatuModel *cardM = [CardStatuModel objectWithDict:customCardM.card];
    cardM.content = customCardM.msg;
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
    [[UIPasteboard generalPasteboard] setString:customCardM.msg];
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

- (NSString *)formatterTimeText:(NSTimeInterval)secs
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSDate *send = [NSDate dateWithTimeIntervalSince1970:secs];
    NSString *sendStr = [fmt stringFromDate:send];
    NSDate *now = [NSDate date];
    NSString *nowStr = [fmt stringFromDate:now];
    
    NSDate *yesterday = [[NSDate alloc] initWithTimeIntervalSinceNow:-(24 * 60 * 60)];
    NSString *strYesterday = [fmt stringFromDate:yesterday];
    
    if ([sendStr isEqualToString:nowStr]) {
        fmt.dateFormat = @"HH:mm";
        return [fmt stringFromDate:send];
    }else if([strYesterday isEqualToString:sendStr]){
        fmt.dateFormat = @"HH:mm";
        return [NSString stringWithFormat:@"昨天 %@",[fmt stringFromDate:send]];
    }else{
        return sendStr;
    }
}
@end
