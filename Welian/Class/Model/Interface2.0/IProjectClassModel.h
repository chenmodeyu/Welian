//
//  IProjectClassModel.h
//  Welian
//
//  Created by weLian on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"

@interface IProjectClassModel : IFBase

@property (nonatomic, strong) NSNumber *cid;//项目集id
@property (nonatomic, strong) NSString *title;//标题
@property (nonatomic, strong) NSString *photo;//照片
@property (nonatomic, strong) NSNumber *projectCount;//包含的项目数量

@end

/*
 cid = 2;
 count = 0;
 photo = "http://img.welian.com/061450411610019.jpg";
 title = O2O;
 */
