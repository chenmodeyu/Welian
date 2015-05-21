//
//  ITouTiaoModel.h
//  Welian
//
//  Created by weLian on 15/5/21.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"

@interface ITouTiaoModel : IFBase

@property (nonatomic, strong) NSNumber *touTiaoId;//id
@property (nonatomic, strong) NSString *author;//作者
@property (nonatomic, strong) NSString *created;//时间
@property (nonatomic, strong) NSString *intro;//简介
@property (nonatomic, strong) NSString *photo;//图片
@property (nonatomic, strong) NSString *title;//标题
@property (nonatomic, strong) NSString *url;//网页链接


//author = authher1;
//created = "2015-05-19 10:57";
//id = 1;
//intro = intro1;
//photo = "http://img.welian.com/12151157600-980-980.jpg";
//title = 1;
//url = "http://toutiao.welian.com/view/1";

@end
