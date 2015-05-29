//
//  WLCellCardView.m
//  Welian
//
//  Created by dong on 15/3/3.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "WLCellCardView.h"

@implementation WLCellCardView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addUIView];
    }
    return self;
}

- (void)addUIView
{
    self.backgroundColor = [UIColor clearColor];
    self.isHidLine = NO;
    
    _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 40, 40)];
//    [_iconImage setBackgroundColor:[UIColor lightGrayColor]];
    [self addSubview:_iconImage];
    
    _titLabel = [[UILabel alloc] init];
    _titLabel.font = WLFONT(15);
    _titLabel.textColor = WLRGB(51, 51, 51);
    [self addSubview:_titLabel];
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = WLFONT(13);
    _detailLabel.textColor = WLRGB(173, 173, 173);
    [self addSubview:_detailLabel];
    
    _tapBut = [[UIButton alloc] init];
    [self addSubview:_tapBut];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _tapBut.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    _titLabel.frame = CGRectMake(55, 8, frame.size.width-55-8, 21);
    _detailLabel.frame = CGRectMake(55, CGRectGetMaxY(_titLabel.frame), frame.size.width-55-8, 21);
}

- (void)setIsHidLine:(BOOL)isHidLine
{
    _isHidLine = isHidLine;
    if (!_isHidLine) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4.0;
        self.layer.borderWidth = 0.6;
        self.layer.borderColor = [WLRGB(220, 220, 220) CGColor];
    }else{
        self.layer.borderWidth = 0.f;
    }
}

- (void)setCardM:(CardStatuModel *)cardM
{
    //3 活动，10项目，11 网页  13 投递项目卡片 14 用户名片卡片 15 投资人索要项目卡片
    _iconImage.layer.cornerRadius = 0;
    
    _cardM = cardM;
    NSInteger typeint = cardM.type.integerValue;
    NSString *imageName = @"";
    BOOL cidBool = cardM.cid.boolValue;
    switch (typeint) {
        case 3:
        case 5:
        {
            //活动
            imageName = cidBool? @"home_repost_huodong":@"home_repost_huodong_no";
        }
            break;
        case 4:
        case 6:
        {
            // 个人信息
            imageName = @"home_repost_beijing";
        }
            break;
        case 10:
        case 12:
        case 13:
        {
            //项目
            imageName = cidBool? @"home_repost_xiangmu":@"home_repost_xiangmu_no";
        }
            break;
        case 11:
        {
            // 网页
            imageName = @"home_repost_link";
        }
            break;
//        case 13:
//        {
//            // 话题
//            imageName = @"home_repost_huati";
//        }
//            break;
        case 14:
        case 15:
        {
            _iconImage.layer.cornerRadius = 40 /2.f;
            _iconImage.layer.masksToBounds = YES;
            //名片  需要下载
//            [_iconImage sd_setImageWithURL:[NSURL URLWithString:_cardM.url]
//                          placeholderImage:[UIImage imageNamed:@"user_small"]
//                                   options:SDWebImageRetryFailed|SDWebImageLowPriority];
            [_iconImage sd_setImageWithURL:[NSURL URLWithString:_cardM.url]
                          placeholderImage:[UIImage imageNamed:@"user_small"]
                                   options:SDWebImageRetryFailed|SDWebImageLowPriority
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     if (image) {
                                         _iconImage.image = image;
                                     }else{
                                         _iconImage.image = [UIImage imageNamed:@"user_small"];
                                     }
                                 }];
        }
            break;
        default:
            break;
    }
    
//    if (typeint == 12 || typeint == 10 || typeint == 13) { // 项目
//        imageName = cidBool? @"home_repost_xiangmu":@"home_repost_xiangmu_no";
//    }else if (typeint==11){    // 网页
//        imageName = @"home_repost_link";
//        
//    }else if (typeint==3||typeint==5){ // 活动
//        imageName = cidBool? @"home_repost_huodong":@"home_repost_huodong_no";
//    }else if (typeint==13){ // 话题
//        imageName = @"home_repost_huati";
//    }else if (typeint==4 || typeint==6){ // 个人信息
//        
//        imageName = @"home_repost_beijing";
//    }else if (typeint == 15 || typeint == 14){
//        
//    }
    if(imageName.length > 0){
        [_iconImage setImage:[UIImage imageNamed:imageName]];
    }
    _titLabel.text = cardM.title;
    _detailLabel.text = cardM.intro;
}

@end
