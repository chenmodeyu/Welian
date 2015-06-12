//
//  WLQuestionTextView.m
//  Welian
//
//  Created by weLian on 15/6/11.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "WLQuestionTextView.h"

#define kMarginEdge 10.f
#define kMaxLength 50

@interface WLQuestionTextView ()

@property (assign,nonatomic) UILabel *questionLabel;

@end

@implementation WLQuestionTextView

-(void)dealloc{
    _changeBlock = nil;
    _questionInfo = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UITextFieldTextDidChangeNotification
                                                 object:_answerTF];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setQuestionInfo:(IAskInfoMdoel *)questionInfo
{
    [super willChangeValueForKey:@"questionInfo"];
    _questionInfo = questionInfo;
    [super didChangeValueForKey:@"questionInfo"];
    _questionLabel.text = _questionInfo.title;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_questionLabel sizeToFit];
    _questionLabel.left = 0.f;
    _questionLabel.top = 0.f;
    
    _answerTF.frame = CGRectMake(0.f, _questionLabel.bottom + kMarginEdge, self.width, self.height - kMarginEdge - _questionLabel.height);
}

#pragma mark - Private
- (void)setup
{
    UILabel *questionLabel = [[UILabel alloc] init];
    questionLabel.backgroundColor = [UIColor clearColor];
    questionLabel.font = kNormal15Font;
    questionLabel.textColor = kTitleTextColor;
    [self addSubview:questionLabel];
    self.questionLabel = questionLabel;
    
    WLTextField *answerTF = [[WLTextField alloc] init];
    answerTF.backgroundColor = [UIColor whiteColor];
    answerTF.isToBounds = YES;
    answerTF.placeholder = @"必填";
    answerTF.font = kNormal14Font;
    [self addSubview:answerTF];
    self.answerTF = answerTF;
    
    //控制字数
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:UITextFieldTextDidChangeNotification
                                              object:answerTF];
}

- (void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    // 键盘输入模式(判断输入模式的方法是iOS7以后用到的,如果想做兼容,另外谷歌)
    NSArray * currentar = [UITextInputMode activeInputModes];
    UITextInputMode * current = [currentar firstObject];
    
    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
                //此方法是我引入的第三方警告框.读者可以自己完成警告弹窗.
            }
        }else{
            // 有高亮选择的字符串，则暂不对文字进行统计和限制
        }
    }else{
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
    }
    if (_changeBlock) {
        _changeBlock();
    }
}

@end
