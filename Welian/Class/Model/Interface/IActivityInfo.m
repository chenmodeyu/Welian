//
//  IActivityInfo.m
//  Welian
//
//  Created by weLian on 15/3/3.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "IActivityInfo.h"

@implementation IActivityInfo

- (void)customOperation:(NSDictionary *)dict
{
    self.guests = [IBaseUserM objectsWithInfo:self.guests];
    self.confs = [IAskInfoMdoel objectsWithInfo:self.confs];
    //主办方
    NSArray *sponsorsArray = dict[@"sponsors"];
    //类型
    NSMutableString *types = [NSMutableString string];
    if (sponsorsArray.count > 0) {
        [types appendFormat:@"%@",[[sponsorsArray[0] objectForKey:@"name"] deleteTopAndBottomKonggeAndHuiche]];
        if(sponsorsArray.count > 1){
            for (int i = 1; i < sponsorsArray.count;i++) {
                NSDictionary *industry = sponsorsArray[i];
                [types appendFormat:@" | %@",[[industry objectForKey:@"name"] deleteTopAndBottomKonggeAndHuiche]];
            }
        }
    }else{
        [types appendString:@""];
    }
    self.sponsors = types;
}

//获取活动开始是周几
- (NSString *)displayStartWeekDay
{
    NSDate *startDate = [self.startime dateFromNormalString];
    NSString *day = @"";
    switch ([startDate weekday]) {
        case 1:
            day = @"周日";
            break;
        case 2:
            day = @"周一";
            break;
        case 3:
            day = @"周二";
            break;
        case 4:
            day = @"周三";
            break;
        case 5:
            day = @"周四";
            break;
        case 6:
            day = @"周五";
            break;
        case 7:
            day = @"周六";
            break;
        default:
            break;
    }
    return day;
}

//获取活动结束是周几
- (NSString *)displayEndWeekDay
{
    NSDate *endDate = [self.endtime dateFromNormalString];
    NSString *day = @"";
    switch ([endDate weekday]) {
        case 1:
            day = @"周日";
            break;
        case 2:
            day = @"周一";
            break;
        case 3:
            day = @"周二";
            break;
        case 4:
            day = @"周三";
            break;
        case 5:
            day = @"周四";
            break;
        case 6:
            day = @"周五";
            break;
        case 7:
            day = @"周六";
            break;
        default:
            break;
    }
    return day;
}

//获取活动时间
- (NSString *)displayStartTimeInfo
{
    NSDate *startDate = [self.startime dateFromNormalString];
    NSDate *endDate = [self.endtime dateFromNormalString];
    NSString *time = @"";
    if ([endDate daysLaterThan:startDate] == 0) {
        time = [NSString stringWithFormat:@"%@ %@ %@～%@",[startDate formattedDateWithFormat:@"yyyy/MM/dd"],[self displayStartWeekDay],[startDate formattedDateWithFormat:@"HH:mm"],[endDate formattedDateWithFormat:@"HH:mm"]];
    }else{
        time = [NSString stringWithFormat:@"%@ %@ %@ ～ %@ %@ %@",[startDate formattedDateWithFormat:@"yyyy/MM/dd"],[self displayStartWeekDay],[startDate formattedDateWithFormat:@"HH:mm"],[endDate formattedDateWithFormat:@"yyyy/MM/dd"],[self displayEndWeekDay],[endDate formattedDateWithFormat:@"HH:mm"]];
    }
    return time;
}

@end
