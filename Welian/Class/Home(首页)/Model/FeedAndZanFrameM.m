//
//  FeedAndZanFrameM.m
//  weLian
//
//  Created by dong on 14/11/13.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "FeedAndZanFrameM.h"
#import "M80AttributedLabel.h"

@interface FeedAndZanFrameM()
{
    CGFloat _cellWidth;
}
@property (nonatomic, strong) M80AttributedLabel *HBlabel;
@end

@implementation FeedAndZanFrameM

- (M80AttributedLabel *)HBlabel
{
    if (_HBlabel == nil) {
        _HBlabel = [[M80AttributedLabel alloc] init];
        [_HBlabel setFont:WLFONT(13)];
    }
    return _HBlabel;
}

- (instancetype)initWithWidth:(CGFloat)width
{
    self = [super init];
    if (self){
     _cellWidth = width;
        
    }
    return self;
}

- (void)setCellWidth:(CGFloat)cellWidth
{
    _cellWidth = cellWidth;
}

- (void)setFeedAndzanDic:(NSDictionary *)feedAndzanDic
{
    _feedAndzanDic = feedAndzanDic;

    CGFloat imageX = 10;
    CGFloat imageY = 10;
    _cellHigh = imageY;
    
    UIImage *image = [UIImage imageNamed:@"good_small"];
    _zanImageF = CGRectMake(imageX, imageY+3, image.size.width, image.size.height);
    
    NSArray *feedArray = [feedAndzanDic objectForKey:@"forwards"];
    NSArray *zanArray = [feedAndzanDic objectForKey:@"zans"];
    
    CGFloat labelW = _cellWidth- CGRectGetMaxX(_zanImageF)-20;
    NSMutableString *zanStrM = [NSMutableString string];
    if (zanArray.count) {
        for (UserInfoModel *zanModel  in zanArray) {
            if (zanModel != zanArray.lastObject) {
                
                [zanStrM appendFormat:@"%@，",zanModel.name];
            }else{
                [zanStrM appendFormat:@"%@",zanModel.name];
            }
        }
        CGFloat zanlabelH = [self textViewHeightForAttributedText:zanStrM andWidth:labelW];
        _zanLabelF = CGRectMake(CGRectGetMaxX(_zanImageF)+5, imageY, labelW, zanlabelH);
        _zanNameStr = zanStrM;
        _cellHigh = CGRectGetMaxY(_zanLabelF);
    }
    
    NSMutableString *feedStrM = [NSMutableString string];
    if (feedArray.count) {
        if (zanArray.count) {
        _cellHigh +=5;            
        }

        _feedImageF = CGRectMake(imageX-3, _cellHigh+3, image.size.width+5, image.size.height);
        
        for (UserInfoModel *feedModel in feedArray) {
            if (feedModel != feedArray.lastObject) {
                
                [feedStrM appendFormat:@"%@，",feedModel.name];
            }else{
                [feedStrM appendFormat:@"%@",feedModel.name];
            }
        }
        CGFloat feedlabelH = [self textViewHeightForAttributedText:feedStrM andWidth:labelW];
        _feedLabelF = CGRectMake(CGRectGetMaxX(_zanImageF)+5, _cellHigh, labelW, feedlabelH);
        _feedNameStr = feedStrM;
        _cellHigh = CGRectGetMaxY(_feedLabelF);
    }
    _cellHigh += 5;
}


- (CGFloat)textViewHeightForAttributedText:(NSString *)text andWidth:(CGFloat)width
{
    [self.HBlabel setText:text];
    CGSize size = [self.HBlabel sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}


@end
