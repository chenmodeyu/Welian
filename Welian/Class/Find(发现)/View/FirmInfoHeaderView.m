//
//  FirmInfoHeaderView.m
//  Welian
//
//  Created by dong on 15/5/27.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "FirmInfoHeaderView.h"
#import "UIImage+ImageEffects.h"
#import "TouzijigouModel.h"

#define ImageX 15
#define ImageW 55
#define LabelX (ImageW+(ImageX*2))
#define NameLabelH 22
#define TiteLabelW 70
#define LabelInterval 6

@interface FirmInfoHeaderView ()
{
    UIImageView *_backgImage;
    UIImageView *_logoImage;
    
    UILabel *_nameLabel;
    UILabel *_introLabel;
    UILabel *_stageTiteLabel;
    UILabel *_stageStrLabel;
    UILabel *_industryTiteLabel;
    UILabel *_industryStrLabel;
    
}
@end

@implementation FirmInfoHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backgImage = [[UIImageView alloc] init];
        [_backgImage setBackgroundColor:kNormalGrayTextColor];
        [self addSubview:_backgImage];
        
        _logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(ImageX, ImageX, ImageW, ImageW)];
        [_logoImage setBackgroundColor:KBgLightGrayColor];
        [_backgImage addSubview:_logoImage];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(LabelX, ImageX, SuperSize.width-LabelX-ImageX, NameLabelH)];
        [_nameLabel setTextColor:[UIColor whiteColor]];
        [_nameLabel setFont:WLFONTBLOD(18)];
        [_backgImage addSubview:_nameLabel];
        
        _introLabel = [[UILabel alloc] init];
        [_introLabel setNumberOfLines:0];
        [_introLabel setTextColor:[UIColor colorWithWhite:1 alpha:0.8]];
        [_introLabel setFont:WLFONT(15)];
        [_backgImage addSubview:_introLabel];
        
        _stageTiteLabel = [[UILabel alloc] init];
        [_stageTiteLabel setText:@"投资阶段："];
        [_stageTiteLabel setTextColor:[UIColor whiteColor]];
        [_stageTiteLabel setFont:WLFONT(14)];
        [_backgImage addSubview:_stageTiteLabel];
        
        _stageStrLabel = [[UILabel alloc] init];
        [_stageStrLabel setTextColor:[UIColor whiteColor]];
        [_stageStrLabel setFont:WLFONT(14)];
        [_stageStrLabel setNumberOfLines:0];
        [_backgImage addSubview:_stageStrLabel];
        
        _industryTiteLabel = [[UILabel alloc] init];
        [_industryTiteLabel setText:@"投资领域："];
        [_industryTiteLabel setTextColor:[UIColor whiteColor]];
        [_industryTiteLabel setFont:WLFONT(14)];
        [_backgImage addSubview:_industryTiteLabel];
        
        _industryStrLabel = [[UILabel alloc] init];
        [_industryStrLabel setNumberOfLines:0];
        [_industryStrLabel setTextColor:[UIColor whiteColor]];
        [_industryStrLabel setFont:WLFONT(14)];
        [_backgImage addSubview:_industryStrLabel];
    }
    return self;
}

- (void)setTouziJiGouM:(TouzijigouModel *)touziJiGouM
{
    _touziJiGouM = touziJiGouM;
    
    [_nameLabel setText:touziJiGouM.title];
    [_introLabel setText:touziJiGouM.intro];
    [_industryStrLabel setText:touziJiGouM.industrysStr];
    [_stageStrLabel setText:touziJiGouM.stagesStr];
    
    CGSize introSize = [touziJiGouM.intro sizeWithCustomFont:WLFONT(15) constrainedToSize:CGSizeMake(SuperSize.width-LabelX-ImageX, MAXFLOAT)];
    [_introLabel setFrame:CGRectMake(LabelX, _nameLabel.bottom+LabelInterval, introSize.width, introSize.height)];
    CGSize stageSize = CGSizeZero;
    if (touziJiGouM.stagesStr) {
        [_stageTiteLabel setFrame:CGRectMake(LabelX, _introLabel.bottom+LabelInterval, TiteLabelW, 16)];
        stageSize = [touziJiGouM.stagesStr sizeWithCustomFont:WLFONT(14) constrainedToSize:CGSizeMake(SuperSize.width-LabelX-TiteLabelW-ImageX, MAXFLOAT)];
        [_stageStrLabel setFrame:CGRectMake(_stageTiteLabel.right, _stageTiteLabel.top, stageSize.width, stageSize.height)];
    }else{
        [_stageTiteLabel setFrame:CGRectZero];
        [_stageStrLabel setFrame:CGRectZero];
        _stageStrLabel.top = _introLabel.bottom+LabelInterval;
    }
    CGSize industrySize = CGSizeZero;
    if (touziJiGouM.industrysStr) {
        [_industryTiteLabel setFrame:CGRectMake(LabelX, _stageStrLabel.bottom, TiteLabelW, 16)];
        industrySize = [touziJiGouM.industrysStr sizeWithCustomFont:WLFONT(14) constrainedToSize:CGSizeMake(SuperSize.width-LabelX-TiteLabelW-ImageX, MAXFLOAT)];
        [_industryStrLabel setFrame:CGRectMake(_industryTiteLabel.right, _industryTiteLabel.top, industrySize.width, industrySize.height)];
    }else{
        [_industryTiteLabel setFrame:CGRectZero];
        [_industryStrLabel setFrame:CGRectZero];
        _industryStrLabel.top = _stageStrLabel.bottom;
    }
    CGRect backgFrame = CGRectMake(0, 0, SuperSize.width, _industryStrLabel.bottom+ImageX);
    [_backgImage setFrame:backgFrame];
    [_logoImage sd_setImageWithURL:[NSURL URLWithString:touziJiGouM.logo] placeholderImage:nil options:SDWebImageRetryFailed|SDWebImageLowPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [_backgImage setImage:[image applyLightEffect]];
    }];
}

+ (CGFloat)getFirmHeaderHeigh:(TouzijigouModel *)touziJiGouM
{
    CGFloat headerH = 0;
    NSInteger count = 0;
    if (touziJiGouM.intro) {
        count += 1;
    }
    if (touziJiGouM.stagesStr||touziJiGouM.industrysStr) {
        count += 1;
    }
    CGSize introSize = [touziJiGouM.intro sizeWithCustomFont:WLFONT(15) constrainedToSize:CGSizeMake(SuperSize.width-LabelX-ImageX, MAXFLOAT)];
   CGSize stageSize = [touziJiGouM.stagesStr sizeWithCustomFont:WLFONT(14) constrainedToSize:CGSizeMake(SuperSize.width-LabelX-TiteLabelW-ImageX, MAXFLOAT)];
   CGSize industrySize = [touziJiGouM.industrysStr sizeWithCustomFont:WLFONT(14) constrainedToSize:CGSizeMake(SuperSize.width-LabelX-TiteLabelW-ImageX, MAXFLOAT)];
    
    headerH = ImageX+NameLabelH+introSize.height+stageSize.height+industrySize.height+ImageX+count*LabelInterval;
    if (headerH<ImageW+2*ImageX) {
        headerH = ImageW+2*ImageX;
    }
    return headerH;
}

@end
