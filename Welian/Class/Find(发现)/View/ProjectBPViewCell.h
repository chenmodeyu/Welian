//
//  ProjectBPViewCell.h
//  Welian
//
//  Created by weLian on 15/5/20.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "BaseTableViewCell.h"

typedef void(^GetBPBtnClicekdBlock)(void);

@interface ProjectBPViewCell : BaseTableViewCell

@property (strong,nonatomic) GetBPBtnClicekdBlock block;
@property (strong,nonatomic) NSString *fineName;
@property (assign,nonatomic) BOOL showGetBPBtn;

@end
