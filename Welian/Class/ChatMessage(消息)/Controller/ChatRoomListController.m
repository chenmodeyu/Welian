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

//@property (nonatomic,assign) UITableView *tableView;
//@property (nonatomic,assign) ChatRoomTextf *roomIDTextf;

@end

@implementation ChatRoomListController

- (NSString *)title
{
    return @"聊天室";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, SuperSize.height-KPasswordH) style:UITableViewStylePlain];
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    [tableView setTableFooterView:[UIView new]];
    [tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:tableView];
    
    ChatRoomTextf *roomIDTextf = [[ChatRoomTextf alloc] initWithFrame:CGRectMake(0, SuperSize.height-KPasswordH, SuperSize.width, KPasswordH)];
    [roomIDTextf.textF setPlaceholder:@"输入口令，快速进入聊天室"];
    [roomIDTextf.textF setDelegate:self];
    [self.view addSubview:roomIDTextf];
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
