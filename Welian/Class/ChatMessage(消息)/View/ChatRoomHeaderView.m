//
//  ChatRoomHeaderView.m
//  Welian
//
//  Created by dong on 15/6/12.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ChatRoomHeaderView.h"

@implementation ChatRoomHeaderView

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, 70)];
        [cellView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:cellView];
        _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
        
        [_iconImage setImage:[UIImage imageNamed:@"header_background_bottom.png"]];
        [_iconImage.layer setMasksToBounds:YES];
        [_iconImage.layer setCornerRadius:25];
        [cellView addSubview:_iconImage];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_iconImage.right+10, 0, SuperSize.width-_iconImage.right+20, 70)];
        [nameLabel setText:@"聊天室"];
        [cellView addSubview:nameLabel];

        _clickBut = [[UIButton alloc] initWithFrame:cellView.bounds];
        [cellView addSubview:_clickBut];
        
    }
    return self;
}

@end
