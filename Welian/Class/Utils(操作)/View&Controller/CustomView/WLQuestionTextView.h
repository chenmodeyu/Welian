//
//  WLQuestionTextView.h
//  Welian
//
//  Created by weLian on 15/6/11.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLTextField.h"

typedef void(^TextFieldChangedBlock)(void);

@interface WLQuestionTextView : UIView

@property (strong,nonatomic) IAskInfoMdoel *questionInfo;
@property (strong,nonatomic) TextFieldChangedBlock changeBlock;

@property (assign,nonatomic) WLTextField *answerTF;

@end
