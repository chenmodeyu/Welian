//
//  CommentCell.m
//  weLian
//
//  Created by dong on 14-10-13.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "CommentCell.h"
#import "MLEmojiLabel.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ImageEffects.h"
#import "UserInfoViewController.h"

@interface CommentCell() <MLEmojiLabelDelegate>
{
    /** 头像 */
    UIImageView *_iconView;
    /** 昵称 */
    UILabel *_nameLabel;
    /** 时间 */
    UILabel *_timeLabel;
    /** 内容 */
    MLEmojiLabel *_contentLabel;
    //最下面的线
    UIView *_bottomLineView;
}

@end

@implementation CommentCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *CellIdentifier = @"commentCell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 1.添加原创微博的子控件
        [self setupOriginalSubviews];
        
    }
    return self;
}

/**
 *  添加原创微博的子控件
 */
- (void)setupOriginalSubviews
{
    UIImage *image = [UIImage imageNamed:@"me_mywriten_comment_small"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setFrame:CGRectMake(MainScreen.bounds.size.width-image.size.width-IWCellBorderWidth, IWCellBorderWidth, image.size.width, image.size.height)];
    [self.contentView addSubview:imageView];
    
    // 清除cell默认的背景色(才能只显示背景view、背景图片)
    self.backgroundColor = [UIColor clearColor];
    // 1.头像
    _iconView = [[UIImageView alloc] init];
    [self.contentView addSubview:_iconView];
    [_iconView setUserInteractionEnabled:YES];
    [_iconView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapiconImage:)]];
    
    // 2.昵称
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = kNormalBlod15Font;
    // 清除背景颜色
    _nameLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_nameLabel];
    
    // 3.时间
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = kNormal12Font;
    _timeLabel.textColor = [UIColor darkGrayColor];
    _timeLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_timeLabel];
    
    // 5.内容
    _contentLabel = [[MLEmojiLabel alloc] init];
    _contentLabel.numberOfLines = 0;
    _contentLabel.delegate = self;
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _contentLabel.isNeedAtAndPoundSign = NO;//是否启用@ 和 话题功能
    _contentLabel.font = WLFONT(14);
    _contentLabel.textColor = WLRGB(51, 51, 51);
    // 自动换行
    _contentLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_contentLabel];
    
    //cell下面的分割线
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = KBgGrayColor;
    [self.contentView addSubview:_bottomLineView];
}

- (void)tapiconImage:(UITapGestureRecognizer *)tap
{
    IBaseUserM *mode = _commentCellFrame.commentM.user;
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithBaseUserM:mode OperateType:nil HidRightBtn:NO];
    [self.commentVC.navigationController pushViewController:userInfoVC animated:YES];
}

- (void)setCommentCellFrame:(CommentCellFrame *)commentCellFrame
{
    _commentCellFrame = commentCellFrame;
    CommentMode *commentM = commentCellFrame.commentM;
    IBaseUserM *user = commentCellFrame.commentM.user;
    // 1.头像
    _iconView.frame = commentCellFrame.iconViewF;
    [_iconView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"user_small"] options:SDWebImageRetryFailed|SDWebImageLowPriority];
    [_iconView.layer setMasksToBounds:YES];
    [_iconView.layer setCornerRadius:commentCellFrame.iconViewF.size.height*0.5];
    
    //    [_iconView setUser:user iconType:IWIconTypeSmall];
    
    // 2.昵称
    _nameLabel.frame = commentCellFrame.nameLabelF;
    _nameLabel.text = user.name;
    
    // 7.时间
    _timeLabel.text = [self getCreated:commentM.created];
    _timeLabel.frame = commentCellFrame.timeLabelF;
    
    // 6.正文
    _contentLabel.frame = commentCellFrame.contentLabelF;
    NSString *labelstr = commentM.comment;
    if (commentM.touser) {
        labelstr = [NSString stringWithFormat:@"回复 %@：%@",commentM.touser.name,commentM.comment];
    }
    _contentLabel.text = labelstr;
 
    if (_showBottomLine) {
        //最下面的线
        _bottomLineView.frame = CGRectMake(_nameLabel.left, commentCellFrame.cellHeight - 0.5, SuperSize.width - _nameLabel.left, 0.5);
    }
}

- (void)setShowBottomLine:(BOOL)showBottomLine
{
    _showBottomLine = showBottomLine;
    //最下面的线
    _bottomLineView.frame = CGRectMake(_nameLabel.left, _commentCellFrame.cellHeight - 0.5, SuperSize.width - _nameLabel.left, 0.5);
    
}

- (NSString *)getCreated:(NSString *)created
{
    // 1.获得微博的发送时间
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *send = [fmt dateFromString:created];
    
    // 2.当前时间
    NSDate *now = [NSDate date];
    
    // 3.获得当前时间和发送时间 的 间隔  (now - send)
    NSString *timeStr = nil;
    NSTimeInterval delta = [now timeIntervalSinceDate:send];
    if (delta < 60) { // 一分钟内
        timeStr = @"刚刚";
    } else if (delta < 60 * 60) { // 一个小时内
        timeStr = [NSString stringWithFormat:@"%.f分钟前", delta/60];
    } else if (delta < 60 * 60 * 24) { // 一天内
        timeStr = [NSString stringWithFormat:@"%.f小时前", delta/60/60];
    } else { // 几天前
        fmt.dateFormat = @"MM-dd";
        timeStr = [fmt stringFromDate:send];
    }
    return timeStr;
}


@end
