//
//  ChatRoomListController.m
//  Welian
//
//  Created by dong on 15/6/11.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ChatRoomListController.h"
#import "WLChatRoomController.h"
#import "ChatRoomTextf.h"

#define KPasswordH 50

@interface ChatRoomListController () <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic, strong) ChatRoomTextf *roomIDTextf;
@end

@implementation ChatRoomListController

- (ChatRoomTextf *)roomIDTextf
{
    if (_roomIDTextf == nil) {
        _roomIDTextf = [[ChatRoomTextf alloc] initWithFrame:CGRectMake(0, SuperSize.height-KPasswordH, SuperSize.width, KPasswordH)];
        [_roomIDTextf.textF setPlaceholder:@"输入口令，快速进入聊天室"];
        [_roomIDTextf.textF setDelegate:self];
    }
    return _roomIDTextf;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, SuperSize.height-KPasswordH) style:UITableViewStylePlain];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setTableFooterView:[UIView new]];
        [_tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"聊天室";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.roomIDTextf];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"口令" message:@"输入口令，快速进入聊天室"];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert bk_addButtonWithTitle:@"取消" handler:nil];
    [alert bk_addButtonWithTitle:@"进入" handler:^{
        
    }];
    [alert show];
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    [cell.textLabel setText:@"fdsads"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RCConversationModel *model = [[RCConversationModel alloc] init];
    model.targetId = @"10019";
    model.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
    model.conversationType = ConversationType_CHATROOM;
    model.conversationTitle = @"微链聊天室";
    
    WLChatRoomController *chatRoomVC = [[WLChatRoomController alloc] init];
    chatRoomVC.conversationType = model.conversationType;
    chatRoomVC.targetId = model.targetId;
    chatRoomVC.userName = model.conversationTitle;
    chatRoomVC.title = model.conversationTitle;
    [self.navigationController pushViewController:chatRoomVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
