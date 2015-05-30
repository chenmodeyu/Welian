//
//  ProjectsMailingView.h
//  Welian
//
//  Created by dong on 15/5/25.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectTouDiModel.h"

typedef void(^MailingProjectBlock)(ProjectTouDiModel *projectModel);
typedef void(^AddProjectBlock)(void);

@interface ProjectsMailingView : UIView

@property (nonatomic, copy) AddProjectBlock addProjectBlock;
@property (nonatomic,copy) MailingProjectBlock mailingProBlock;

- (instancetype)initWithFrame:(CGRect)frame andProjects:(NSArray *)projects;
- (void)cancelSelfVC;
@end
