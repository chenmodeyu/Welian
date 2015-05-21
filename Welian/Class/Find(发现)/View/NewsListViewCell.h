//
//  NewsListViewCell.h
//  Welian
//
//  Created by weLian on 15/5/19.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsListViewCell : UITableViewCell


@property (strong,nonatomic) TouTiaoInfo *infoData;

//返回cell的高度
+ (CGFloat)configureWithNewInfo:(ITouTiaoModel *)newInfo;

@end
