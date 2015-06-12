//
//  ActivityInfo.m
//  Welian
//
//  Created by weLian on 15/3/3.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ActivityInfo.h"
#import "LogInUser.h"
#import "IActivityInfo.h"

@implementation ActivityInfo

@dynamic activeid;
@dynamic name;
@dynamic logo;
@dynamic startime;
@dynamic endtime;
@dynamic status;
@dynamic city;
@dynamic address;
@dynamic limited;
@dynamic joined;
@dynamic isjoined;
@dynamic intro;
@dynamic isfavorite;
@dynamic shareurl;
@dynamic url;
@dynamic type;
@dynamic sponsor;
@dynamic activeType;
@dynamic sorttype;
@dynamic canjoined;
@dynamic canjoinedmsg;
@dynamic rsLoginUser;

//创建活动
+ (ActivityInfo *)createActivityInfoWith:(IActivityInfo *)iActivityInfo withType:(NSNumber *)activityType
{
    ActivityInfo *activityInfo = [self getActivityInfoWithActiveId:iActivityInfo.activeid Type:activityType];
    if (!activityInfo) {
        activityInfo = [ActivityInfo MR_createEntity];
    }
    activityInfo.activeid = iActivityInfo.activeid;
    activityInfo.name = iActivityInfo.name;
    activityInfo.logo = iActivityInfo.logo;
    activityInfo.startime = iActivityInfo.startime;
    activityInfo.endtime = iActivityInfo.endtime;
    activityInfo.status = iActivityInfo.status;
    activityInfo.city = iActivityInfo.city;
    activityInfo.address = iActivityInfo.address;
    activityInfo.limited = iActivityInfo.limited;
    activityInfo.joined = iActivityInfo.joined;
    activityInfo.isjoined = iActivityInfo.isjoined;
    activityInfo.intro = iActivityInfo.intro;
    activityInfo.isfavorite = iActivityInfo.isfavorite;//activeType; //0：普通   1：收藏  2：我参加的
    activityInfo.shareurl = iActivityInfo.shareurl;
    activityInfo.url = iActivityInfo.url;
    activityInfo.type = iActivityInfo.type;
    activityInfo.sponsor = iActivityInfo.sponsors;
    activityInfo.activeType = activityType;
    activityInfo.sorttype = iActivityInfo.sorttype;
    activityInfo.canjoined = iActivityInfo.canjoined;
    activityInfo.canjoinedmsg = iActivityInfo.canjoinedmsg;
    
    if (activityType != 0) {
        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
        if (loginUser) {
            [loginUser addRsActivityInfosObject:activityInfo];
        }
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    return activityInfo;
}

//更新活动
+ (ActivityInfo *)updateActivityInfoWith:(IActivityInfo *)iActivityInfo withType:(NSNumber *)activityType
{
    ActivityInfo *activityInfo = [self getActivityInfoWithActiveId:iActivityInfo.activeid Type:activityType];
    if (!activityInfo) {
        activityInfo = [ActivityInfo MR_createEntity];
    }
    activityInfo.activeid = iActivityInfo.activeid;
    activityInfo.name = iActivityInfo.name;
    activityInfo.logo = iActivityInfo.logo;
    activityInfo.startime = iActivityInfo.startime;
    activityInfo.endtime = iActivityInfo.endtime;
    activityInfo.status = iActivityInfo.status;
    activityInfo.city = iActivityInfo.city;
    activityInfo.address = iActivityInfo.address;
    activityInfo.limited = iActivityInfo.limited;
    activityInfo.joined = iActivityInfo.joined;
    activityInfo.isjoined = iActivityInfo.isjoined;
    activityInfo.intro = iActivityInfo.intro;
    activityInfo.isfavorite = iActivityInfo.isfavorite;
    activityInfo.shareurl = iActivityInfo.shareurl;
    activityInfo.url = iActivityInfo.url;
    activityInfo.type = iActivityInfo.type;
    activityInfo.sponsor = iActivityInfo.sponsors;
    activityInfo.activeType = activityType;
    activityInfo.sorttype = iActivityInfo.sorttype;
    activityInfo.canjoined = iActivityInfo.canjoined;
    activityInfo.canjoinedmsg = iActivityInfo.canjoinedmsg;
    
    if (activityType != 0) {
        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
        if (loginUser) {
            [loginUser addRsActivityInfosObject:activityInfo];
        }
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    return activityInfo;
}

//获取活动
+ (ActivityInfo *)getActivityInfoWithActiveId:(NSNumber *)activeid Type:(NSNumber *)activityType
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"activeType",activityType,@"activeid",activeid];
    ActivityInfo *activityInfo = [ActivityInfo MR_findFirstWithPredicate:pre];
    return activityInfo;
}

//删除所有指定类型的对象
+ (void)deleteAllActivityInfoWithType:(NSNumber *)type
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"activeType",type];
   
    //设置属性，而不删除
//    if (type.integerValue == 0) {
//        //删除所有查询的信息
////        [ActivityInfo MR_deleteAllMatchingPredicate:pre];
//    }else{
//        
//    }
    //隐形删除，设置对应的属性
     //0：普通   1：收藏  2：我参加的   -1：隐形删除的活动
    NSArray *all = [ActivityInfo MR_findAllWithPredicate:pre];
    for (ActivityInfo *activityInfo in all) {
        //        [activityInfo MR_deleteEntity];
        if (type.integerValue == 1) {
            //设置不收藏
            activityInfo.isfavorite = @(NO);
        }else if(type.integerValue == 2){
            //设置我参加的
            activityInfo.isjoined = @(NO);
        }else{
            activityInfo.activeType = @(-1);
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

//删除指定类型的单个对象
+ (void)deleteActivityInfoWithType:(NSNumber *)type ActiveId:(NSNumber *)activeid
{
    ActivityInfo *activityInfo = [self getActivityInfoWithActiveId:activeid Type:type];
    [activityInfo MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

//获取所有的普通的项目排序后数据
+ (NSArray *)allNormalActivityInfos
{
    //按照是否热门排序
    //    [hotArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    //        return [[obj1 sorttype] integerValue] > [[obj2 sorttype] integerValue];
    //    }];
    NSMutableArray *nowArray = [NSMutableArray array];
    //sorttype 0正常，1:new,2:hot  热门排在最前面、新的排在热门后面、其它的最后
    NSPredicate *hotPre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@ && %K != %@",@"activeType",@(0),@"sorttype",@(2),@"status",@(2)];
    NSArray *hotArray = [ActivityInfo MR_findAllSortedBy:@"startime:YES,activeid" ascending:NO withPredicate:hotPre];
    [nowArray addObjectsFromArray:hotArray];
    
    //新的
    NSPredicate *newPre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@ && %K != %@",@"activeType",@(0), @"sorttype",@(1),@"status",@(2)];
    NSArray *newArray = [ActivityInfo MR_findAllSortedBy:@"startime" ascending:YES withPredicate:newPre];
    [nowArray addObjectsFromArray:newArray];
    
    //普通
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@ && %K != %@",@"sorttype",@(0),@"activeType",@(0),@"status",@(2)];
    NSArray *normalArray = [ActivityInfo MR_findAllSortedBy:@"startime" ascending:YES withPredicate:pre];
    [nowArray addObjectsFromArray:normalArray];
    
    //0 还没开始，1进行中。2结束
    NSPredicate *pre1 = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"activeType",@(0),@"status",@(2)];
    NSArray *endArray = [ActivityInfo MR_findAllSortedBy:@"startime" ascending:NO withPredicate:pre1];
    
    NSArray *all = @[nowArray,endArray];
    
    return all;
}

//获取自己的项目或者自己收藏的
+ (NSArray *)allMyActivityInfoWithType:(NSNumber *)activityType
{
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (loginUser) {
        //未开始  //0：普通   1：收藏  2：我参加的
        NSString *serchType = activityType.integerValue == 1 ? @"isfavorite" : @"isjoined";
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@ && %K == %@ && %K != %@", @"activeType",activityType,serchType,@(YES),@"rsLoginUser",loginUser,@"status",@(2)];
        NSArray *unStartArray = [ActivityInfo MR_findAllSortedBy:@"startime" ascending:YES withPredicate:pre];
        //已结束
        NSPredicate *pre1 = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@ && %K == %@ && %K == %@", @"activeType",activityType,serchType,@(YES),@"rsLoginUser",loginUser,@"status",@(2)];
        NSArray *endArray = [ActivityInfo MR_findAllSortedBy:@"startime" ascending:NO withPredicate:pre1];
        
        NSMutableArray *allArray = [NSMutableArray array];
        [allArray addObjectsFromArray:unStartArray];
        [allArray addObjectsFromArray:endArray];
        
        return [NSArray arrayWithArray:allArray];
    }else{
        return [NSArray array];
    }
}

//更新收藏状态
- (ActivityInfo *)updateFavorite:(NSNumber *)isFavorite
{
    self.isfavorite = isFavorite;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    return self;
}

//更新报名状态
- (ActivityInfo *)updateIsjoined:(NSNumber *)isJoined
{
    self.isjoined = isJoined;
    [[self managedObjectContext] MR_saveToPersistentStoreAndWait];
    
    return self;
}

//更新已报名人数
- (ActivityInfo *)updateJoined:(NSNumber *)joined
{
    self.joined = @(self.joined.integerValue + joined.integerValue);
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
    
    return self;
}

//更新报名状态和已报名人数
- (ActivityInfo *)updateIsjoinedAndJoinedCount:(BOOL)isJoined
{
    self.isjoined = @(isJoined);
    self.joined = @(self.joined.integerValue + (isJoined ? 1 : -1));
    [[self managedObjectContext] MR_saveToPersistentStoreAndWait];
    
    return self;
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

//获取活动详情
- (NSString *)displayActivityInfo
{
    //适应网页内容
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[self.intro dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    NSString *text = attrStr.string;
    return text.length > 250 ? [text substringToIndex:250] : text;
//    //去除多余的换行
//    NSMutableString *infoText = [NSMutableString string];
//    if (text.length > 0) {
//        NSArray *infoArray = [text componentsSeparatedByString:@"\n"];
//        if (infoArray.count > 1) {
//            for (NSString *str in infoArray) {
//                DLog(@"str---->%@",[str deleteBottomHuiChe]);
//                if ([str deleteBottomHuiChe].length > 0) {
//                    [infoText appendString:str];
//                    [infoText appendString:@"\n"];
//                }
//            }
//        }else{
//            [infoText appendString:[text deleteBottomHuiChe]];
//        }
//    }
//    NSString *infoStr = infoText.length > 250 ? [infoText substringToIndex:250] : infoText;
//    return infoStr;
}

//分享到微信的内容
- (NSString *)displayShareToWx
{
    NSDate *startDate = [self.startime dateFromNormalString];
    NSString *info = [NSString stringWithFormat:@"%@ · %@(%@)\n%@",self.city,[startDate formattedDateWithFormat:@"MM月dd日"],[self displayStartWeekDay],self.address];
    return info;
}

@end
