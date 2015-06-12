//
//  ActivityQuestionView.m
//  Welian
//
//  Created by weLian on 15/6/11.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ActivityQuestionView.h"
#import "WLQuestionTextView.h"

#define kMarginLeft 15.f
#define kMarginEdge 15.f
#define kTagOfTextFieldView 90000

@interface ActivityQuestionView ()<UITextFieldDelegate>

@property (strong,nonatomic) NSArray *questions;

@end

@implementation ActivityQuestionView

- (void)dealloc
{
    _questions = nil;
    _checkBlock = nil;
}

- (instancetype)initWithQuestions:(NSArray *)questions
{
    self = [super init];
    if (self) {
        self.questions = questions;
        [self setup];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    for (int i = 0; i < _questions.count; i++) {
        WLQuestionTextView *questionTV = (WLQuestionTextView *)[self viewWithTag:kTagOfTextFieldView + i];
        questionTV.size = CGSizeMake(self.width - kMarginLeft * 2.f, kTextViewHeight);
        questionTV.left = kMarginLeft;
        questionTV.top = kMarginEdge * i +  kTextViewHeight * i;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DLog(@"textField:%d",textField.tag);
    [textField resignFirstResponder];
    if (_questions.count > 1) {
        if ((textField.tag - kTagOfTextFieldView) < (_questions.count - 1)) {
            WLQuestionTextView *questionTV = (WLQuestionTextView *)[self viewWithTag:textField.tag + 1];
            [questionTV.answerTF becomeFirstResponder];
        }
    }
    return YES;
}

#pragma mark - Private
- (void)setup
{
    WEAKSELF
    for (int i = 0; i < _questions.count; i++) {
        WLQuestionTextView *questionTV = [[WLQuestionTextView alloc] init];
        questionTV.questionInfo = _questions[i];
        questionTV.tag = kTagOfTextFieldView + i;
        questionTV.answerTF.tag = kTagOfTextFieldView + i;
        questionTV.answerTF.delegate = self;
        if (_questions.count > 1) {
            if (i < _questions.count - 1) {
                questionTV.answerTF.returnKeyType = UIReturnKeyNext;
            }else{
                questionTV.answerTF.returnKeyType = UIReturnKeyDone;
            }
        }else{
            questionTV.answerTF.returnKeyType = UIReturnKeyDone;
        }
        [self addSubview:questionTV];
        
        [questionTV setChangeBlock:^(){
            [weakSelf checkActivityCanJoin];
        }];
    }
}

//检查是否可以报名
- (void)checkActivityCanJoin
{
    NSMutableArray *postInfos = [NSMutableArray array];
    BOOL canJoin = NO;
    for (int i = 0; i < _questions.count; i++) {
        WLQuestionTextView *questionTV = (WLQuestionTextView *)[self viewWithTag:kTagOfTextFieldView + i];
        if (questionTV.answerTF.text.length > 0) {
            canJoin = YES;
            //返回的参数
            [postInfos addObject:@{@"field":[_questions[i] field],
                                   @"value":questionTV.answerTF.text}];
        }else{
            canJoin = NO;
        }
    }
    if (_checkBlock) {
        _checkBlock(canJoin,[NSArray arrayWithArray:postInfos]);
    }
}


+ (CGFloat)configureQuestionViewHeight:(NSArray *)questinos
{
    if (questinos.count > 0) {
        return questinos.count * kTextViewHeight + (questinos.count - 1) * kMarginEdge;
    }else{
        return 0.f;
    }
}

@end
