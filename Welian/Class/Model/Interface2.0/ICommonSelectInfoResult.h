//
//  ICommonSelectInfoResult.h
//  Welian
//
//  Created by weLian on 15/5/26.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IFBase.h"

@interface ICommonSelectInfoResult : IFBase

@property (nonatomic, strong) NSArray *activecity;//活动城市
@property (nonatomic, strong) NSArray *industry;//领域
@property (nonatomic, strong) NSArray *projectcity;//项目城市刷选条件

@end

/*
 activecity =     (
 {
 cityid = 131;
 name = "\U5317\U4eac";
 },
 {
 cityid = 289;
 name = "\U4e0a\U6d77";
 },
 {
 cityid = 179;
 name = "\U676d\U5dde";
 },
 {
 cityid = 257;
 name = "\U5e7f\U5dde";
 },
 {
 cityid = 340;
 name = "\U6df1\U5733";
 },
 {
 cityid = 75;
 name = "\U6210\U90fd";
 },
 {
 cityid = 180;
 name = "\U5b81\U6ce2";
 },
 {
 cityid = 194;
 name = "\U53a6\U95e8";
 },
 {
 cityid = 218;
 name = "\U6b66\U6c49";
 },
 {
 cityid = 243;
 name = "\U8862\U5dde";
 },
 {
 cityid = 315;
 name = "\U5357\U4eac";
 },
 {
 cityid = 334;
 name = "\U5609\U5174";
 }
 );
 industry =     (
 {
 industryid = 1;
 name = "\U6e38\U620f";
 },
 {
 industryid = 2;
 name = "\U793e\U4ea4";
 },
 {
 industryid = 3;
 name = "\U7535\U5b50\U5546\U52a1";
 },
 {
 industryid = 4;
 name = "\U5a92\U4f53";
 },
 {
 industryid = 5;
 name = "\U6559\U80b2";
 },
 {
 industryid = 6;
 name = "\U5065\U5eb7\U533b\U7597";
 },
 {
 industryid = 7;
 name = "\U91d1\U878d";
 },
 {
 industryid = 8;
 name = "\U65c5\U6e38";
 },
 {
 industryid = 9;
 name = "\U6587\U5316\U827a\U672f";
 },
 {
 industryid = 10;
 name = "\U751f\U6d3b\U6d88\U8d39";
 },
 {
 industryid = 11;
 name = "\U5de5\U5177";
 },
 {
 industryid = 12;
 name = "\U786c\U4ef6";
 },
 {
 industryid = 13;
 name = "\U4f01\U4e1a\U670d\U52a1";
 },
 {
 industryid = 14;
 name = "\U7ad9\U957f\U5de5\U5177";
 },
 {
 industryid = 15;
 name = "\U521b\U4e1a\U670d\U52a1";
 },
 {
 industryid = 16;
 name = "\U8425\U9500\U5e7f\U544a";
 },
 {
 industryid = 17;
 name = "\U79fb\U52a8\U4e92\U8054\U7f51";
 },
 {
 industryid = 18;
 name = "\U89c6\U9891\U5a31\U4e50";
 },
 {
 industryid = 19;
 name = "\U641c\U7d22\U5b89\U5168";
 },
 {
 industryid = 20;
 name = "\U4f53\U80b2";
 },
 {
 industryid = 21;
 name = "\U6c7d\U8f66";
 },
 {
 industryid = 22;
 name = "\U5176\U4ed6";
 }
 );
 projectcity =     (
 {
 cityid = 131;
 name = "\U5317\U4eac";
 },
 {
 cityid = 289;
 name = "\U4e0a\U6d77";
 },
 {
 cityid = 257;
 name = "\U5e7f\U5dde";
 },
 {
 cityid = 340;
 name = "\U6df1\U5733";
 },
 {
 cityid = 179;
 name = "\U676d\U5dde";
 }
 );
 */
