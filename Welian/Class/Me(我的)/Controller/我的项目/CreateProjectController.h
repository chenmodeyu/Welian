//
//  CreateProjectController.h
//  Welian
//
//  Created by dong on 15/1/30.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "BasicViewController.h"

typedef void(^ProjectDataBlock)(ProjectDetailInfo *projectModel);
@interface CreateProjectController : BasicViewController

@property (nonatomic, copy) ProjectDataBlock projectDataBlock;

- (instancetype)initIsEdit:(BOOL)isEdit withData:(IProjectDetailInfo *)projectModel;

@end
