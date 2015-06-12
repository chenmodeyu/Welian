//
//  ActivityQuestionView.h
//  Welian
//
//  Created by weLian on 15/6/11.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTextViewHeight 70.f

typedef void(^CheckCanJoinBlock)(BOOL canJoin,NSArray *questInfos);

@interface ActivityQuestionView : UIView

@property (strong,nonatomic) CheckCanJoinBlock checkBlock;

- (instancetype)initWithQuestions:(NSArray *)questions;

+ (CGFloat)configureQuestionViewHeight:(NSArray *)questinos;

@end
