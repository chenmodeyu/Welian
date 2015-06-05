//
//  FeedAndZanCell.h
//  weLian
//
//  Created by dong on 14/11/13.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "FeedAndZanFrameM.h"

@interface FeedAndZanCell : BaseTableViewCell

@property (nonatomic, strong) FeedAndZanFrameM *feedAndZanFrame;

@property (nonatomic, weak) UIViewController *commentVC;

@end
