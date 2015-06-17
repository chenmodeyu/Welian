//
//  WLMessageSpecialView.m
//  Welian
//
//  Created by weLian on 14/12/31.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "WLMessageSpecialView.h"
#import "WLMessageBubbleHelper.h"

#define kMarginLeft 8
#define kOutMarginLeft 19
#define kTextLineSpacing 3

#define kMarginTop 5

@interface WLMessageSpecialView ()

@property (nonatomic, strong, readwrite) id <WLMessageModel> message;
@property (nonatomic, weak, readwrite) MLEmojiLabel *displayLabel;

@end

@implementation WLMessageSpecialView

- (void)dealloc {
    _message = nil;
    _displayLabel = nil;
}

/**
 *  初始化消息内容显示控件的方法
 *
 *  @param frame   目标Frame
 *  @param message 目标消息Model对象
 *
 *  @return 返回XHMessageBubbleView类型的对象
 */
- (instancetype)initWithFrame:(CGRect)frame
                      message:(id <WLMessageModel>)message{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _message = message;
        
        self.backgroundColor = RGB(213.f, 214.f, 216.f);
        self.layer.cornerRadius = 5.f;
        self.layer.masksToBounds = YES;
        
        if (!_displayLabel) {
            // 5.内容
            MLEmojiLabel *displayLabel = [[MLEmojiLabel alloc]init];
            displayLabel.numberOfLines = 0;
            displayLabel.lineBreakMode = NSLineBreakByCharWrapping;
            displayLabel.font = [[WLMessageSpecialView appearance] font];
            //设置字体颜色
            displayLabel.textColor = [UIColor whiteColor];
            displayLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:displayLabel];
            self.displayLabel = displayLabel;
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _displayLabel.frame = [self bubbleFrame];
}

/**
 *  根据消息Model对象配置消息显示内容
 *
 *  @param message 目标消息Model对象
 */
- (void)configureCellWithMessage:(id <WLMessageModel>)message
{
    _message = message;
    _displayLabel.text = _message.text;
    //添加自定义类型
    [_displayLabel addLinkToCorrectionChecking:CustomLinkTypeSendAddFriend withRange:[_message.text rangeOfString:@"&sendAddFriend"]];
    [self setNeedsLayout];
}

/**
 *  根据消息Model对象计算消息内容的高度
 *
 *  @param message 目标消息Model对象
 *
 *  @return 返回所需高度
 */
+ (CGFloat)calculateCellHeightWithMessage:(id <WLMessageModel>)message
{
    CGSize size = [WLMessageSpecialView neededSizeForText:message.text];
    return size.height + kMarginTop * 2.f; //+ kMarginTop + kMarginBottom;
}

+ (CGFloat)neededWidthForText:(NSString *)text {
    CGSize stringSize;
    stringSize = [text sizeWithCustomFont:[[WLMessageSpecialView appearance] font]
                  constrainedToSize:CGSizeMake(MAXFLOAT, 19)];
    return roundf(stringSize.width);
}

+ (CGSize)neededSizeForText:(NSString *)text {
    CGFloat maxWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]) - kMarginLeft * 2.f - kOutMarginLeft * 2.f;
    
    MLEmojiLabel *displayLabel = [[MLEmojiLabel alloc]init];
    displayLabel.numberOfLines = 0;
    displayLabel.lineBreakMode = NSLineBreakByCharWrapping;
    displayLabel.font = [[WLMessageSpecialView appearance] font];
    displayLabel.text = text;
    CGSize textSize = [displayLabel preferredSizeWithMaxWidth:maxWidth];
    return textSize;
}

- (CGRect)bubbleFrame {
    CGSize bubbleSize = [WLMessageSpecialView neededSizeForText:self.message.text];
    
    return CGRectMake(kMarginLeft, kMarginTop, self.width - kMarginLeft * 2.f, bubbleSize.height + kMarginTop);
}


@end
