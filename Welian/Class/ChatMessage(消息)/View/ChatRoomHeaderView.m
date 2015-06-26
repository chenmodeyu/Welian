//
//  ChatRoomHeaderView.m
//  Welian
//
//  Created by dong on 15/6/12.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ChatRoomHeaderView.h"

@implementation ChatRoomHeaderView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [UIView new];
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, 65)];
        [cellView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:cellView];
        _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 45, 45)];
        
        [_iconImage setImage:[UIImage imageNamed:@"chat_chatroom_logo.png"]];
        [_iconImage.layer setMasksToBounds:YES];
        [_iconImage.layer setCornerRadius:45*0.5];
        [cellView addSubview:_iconImage];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_iconImage.right+10, 0, SuperSize.width-_iconImage.right+20, 65)];
        [nameLabel setFont:WLFONT(16)];
        [nameLabel setText:@"聊天室"];
        [cellView addSubview:nameLabel];
        //设置下边边线
        cellView.layer.borderColor = RGB(210, 210, 210).CGColor;
        cellView.layer.borderWidths = @"{0,0,0.5,0}";
    }
    return self;
}

@end
