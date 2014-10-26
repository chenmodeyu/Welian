//
//  HaderInfoCell.m
//  weLian
//
//  Created by dong on 14/10/21.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "HaderInfoCell.h"
#import "UIImageView+WebCache.h"

@interface HaderInfoCell()
{
    // 头像
    UIImageView *_iconImage;
    // 姓名
    UILabel *_nameLabel;
    // 投资者图
    UIImageView *_investorImage;
    // 创业者图
    UIImageView *_startupImage;
    // 公司职务信息
    UILabel *_infoLabel;
}
@end


@implementation HaderInfoCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *CellIdentifier = @"haderCell";
    HaderInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HaderInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadUI];
    }
    return self;
}




- (void)loadUI
{
    CGFloat x = 20.0;
    _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, x, 50, 50)];
    [_iconImage.layer setMasksToBounds:YES];
    [_iconImage.layer setCornerRadius:25.0];
    [self.contentView addSubview:_iconImage];
    
    _nameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:_nameLabel];
    
    _infoLabel = [[UILabel alloc] init];
    [_infoLabel setFont:[UIFont systemFontOfSize:14]];
    [_infoLabel setNumberOfLines:2];
    [_infoLabel setTextColor:[UIColor grayColor]];
    [self.contentView addSubview:_infoLabel];
    
    _investorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badge_tou_big.png"]];
    [_investorImage setHidden:YES];
    [self.contentView addSubview:_investorImage];
    
    _startupImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"badge_chuang_big.png"]];
    [_startupImage setHidden:YES];
    [self.contentView addSubview:_startupImage];
}

- (void)setUserM:(UserInfoModel *)userM
{
    _userM = userM;
    
    [_iconImage sd_setImageWithURL:[NSURL URLWithString:_userM.avatar] placeholderImage:[UIImage imageNamed:@"user_small"] options:SDWebImageRetryFailed|SDWebImageLowPriority];
    
    CGSize timeSize = [userM.name sizeWithFont:[UIFont systemFontOfSize:17]];
    CGFloat labelx = CGRectGetMaxX(_iconImage.frame)+10;
    [_nameLabel setFrame:CGRectMake(labelx, 20.0, timeSize.width, timeSize.height)];
    [_nameLabel setText:userM.name];
    
    if ([userM.investorauth integerValue]==1) {
        [_investorImage setFrame:CGRectMake(CGRectGetMaxX(_nameLabel.frame)+5, 20.0, 20, 20)];
        [_investorImage setHidden:NO];
    }
    
    if (userM.position&&userM.company) {
        NSString *infostr = [NSString stringWithFormat:@"%@   %@",userM.position,userM.company];
        // 3
        CGSize contentSize = [infostr sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.bounds.size.width - 95, MAXFLOAT)];
        [_infoLabel setText:infostr];
        CGFloat infLabelY =CGRectGetMaxY(_nameLabel.frame);
        if (contentSize.height<20) {
            infLabelY += 10;
        }
        [_infoLabel setFrame:CGRectMake(labelx, infLabelY, contentSize.width, contentSize.height)];
    }
    
}

@end
