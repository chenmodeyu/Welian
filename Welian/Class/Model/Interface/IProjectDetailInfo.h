//
//  IProjectDetailInfo.h
//  Welian
//
//  Created by weLian on 15/2/3.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"

@class IBaseUserM,IProjectBPModel;

@interface IProjectDetailInfo : IFBase

@property (nonatomic,strong) NSNumber *pid;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *intro;
@property (nonatomic,strong) NSString *des;
@property (nonatomic,strong) NSString *website;
@property (nonatomic,strong) NSNumber *zancount;//赞数
@property (nonatomic,strong) NSNumber *commentcount;//评论数
@property (nonatomic,strong) NSNumber *membercount;//团队成员个数
@property (nonatomic,strong) NSNumber *iszan;//0 没赞过，1赞过
@property (nonatomic,strong) NSNumber *isfavorite;//0 没收藏，1收藏
@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) NSNumber *status; //1 正在融资，0不融资
@property (nonatomic,strong) NSNumber *feedback;// 投资人反馈的状态  0:默认状态  1：已不感兴趣 2:已约谈
@property (nonatomic,strong) NSNumber *amount;//融资额度
@property (nonatomic,strong) NSNumber *stage;//融资阶段 0:种子轮投资  1:天使轮投资  2:pre-A轮投资 3:A轮投资 4:B轮投资  5:C轮投资
@property (nonatomic,strong) NSNumber *share;//出让股份
@property (nonatomic,strong) NSString *financing;//融资说明
@property (nonatomic,strong) NSString *financingtime;
@property (nonatomic,strong) IBaseUserM *user;
@property (nonatomic,strong) IProjectBPModel *bp;//项目BP对象
// 图片
@property (nonatomic,strong) NSArray *photos;
// 领域
@property (nonatomic,strong) NSArray *industrys;
// 评论
@property (nonatomic,strong) NSArray *comments;
// 赞
@property (nonatomic,strong) NSArray *zanusers;
@property (nonatomic,strong) NSString *shareurl;//分享的链接

//融资阶段
- (NSString *)displayStage;
//赞的数量
- (NSString *)displayZancountInfo;
//项目领域
- (NSString *)displayIndustrys;

// 取领域id
- (NSArray *)getindustrysID;
// 取领域name
- (NSArray *)getindustrysName;

//转换模型
- (IProjectInfo *)toIProjectInfoModel;

@end
/*
 {
 
 "pid":10056, //项目id
 "name":"微链",
 "intro":"互联网移动互联网创业者社区",
 "website":"http://www.welian.com",
 "description": "互联网移动互联网创业者社区,为创业者和投资者建设沟通桥梁",
 "iszan":0，//0 没赞过，1赞过
 "zancount"：128，//赞数
 "commentcount":189,//评论数
 "memebercount":189,//团队成员个数
 "date":"2015-02-01"，
 "user":{
 "uid":10056,
 "name":"吴玉启",
 "avatar":"http://img.welian.com/123123123.jpg"
 }
 
 "photos":[
 {
 "photo":"http://img.welian.com/123123123123_x.jpg",
 },
 
 {
 "photo":"http://img.welian.com/123123123123_x.jpg",
 }
 
 ],
 
 "industrys":
 [{
 
 "industryid":1,
 
 "industryname":"互联网"
 
 }，
 
 {
 
 "industryid":1,
 
 "industryname":"移动互联网"
 
 }
 
 ]，
 
 "comments":[   //10条评论
 
 {
 
 "uid":10056,
 
 "name":"吴玉启",
 
 "avatar":"http://img.welian.com/123123123.jpg"
 
 "comment":"很不错"，
 
 "created:":"2015-01-29 11:23:42"
 
 }
 
 ],
 
 "zanusers":[  //10个赞的用户
 
 {
 
 "uid":10056,
 
 "name":"吴玉启",
 
 "avatar":"http://img.welian.com/123123123.jpg"
 
 }
 
 ]
 
 }
 

 */