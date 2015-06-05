//
//  CommentHeadView.m
//  weLian
//
//  Created by dong on 14/11/24.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "CommentHeadView.h"
#import "WLContentCellView.h"

@interface CommentHeadView()
{
    //    /** 内容 */
    WLContentCellView *_contentView;
    UIView *_lineView;
}
@end


@implementation CommentHeadView

- (instancetype)init{
    self = [super init];
    if (self) {
        
        // 清除cell默认的背景色(才能只显示背景view、背景图片)
        self.backgroundColor = [UIColor clearColor];
        
        _cellHeadView = [[WLCellHead alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
        [self addSubview:_cellHeadView];
        
        _contentView = [[WLContentCellView alloc] init];
        __weak CommentHeadView *weakcell = self;
        _contentView.feedzanBlock = ^(WLStatusM *statusM){
            if (weakcell.feezanBlock) {
                weakcell.feezanBlock (statusM);
            }
        };
        
        _contentView.feedTuiBlock = ^(WLStatusM *statusM){
            if (weakcell.feedTuiBlock) {
                weakcell.feedTuiBlock (statusM);
            }
        };
        [self addSubview:_contentView];
        UIView *lineView = [[UIView alloc] init];
        [lineView setBackgroundColor:KBgGrayColor];
        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:lineView];
        _lineView = lineView;
    }
    return self;
}

- (void)setCommHeadFrame:(CommentHeadFrame *)commHeadFrame
{
    _commHeadFrame = commHeadFrame;
    
    WLStatusM *status = commHeadFrame.status;

    WLContentCellFrame *contenFrame = commHeadFrame.contentFrame;
    
    [_cellHeadView setUserStat:status];
    [_cellHeadView setControllVC:self.homeVC];
    
    [_contentView setCommentFrame:commHeadFrame];
    [_contentView setFrame:CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width, contenFrame.cellHeight)];
    [_lineView setFrame:CGRectMake(0, commHeadFrame.cellHigh-0.5, SuperSize.width, 0.5)];
    [_contentView setHomeVC:self.homeVC];
}

@end
