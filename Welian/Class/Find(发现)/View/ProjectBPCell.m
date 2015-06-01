//
//  ProjectBPCell.m
//  Welian
//
//  Created by dong on 15/6/1.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectBPCell.h"

@implementation ProjectBPCell

- (void)awakeFromNib {
    [self.projectNameLabel setTextColor:kTitleNormalTextColor];
    [self.bPNameLabel setTextColor:kNormalTextColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
