//
//  ChatRoomListController.m
//  Welian
//
//  Created by dong on 15/6/11.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ChatRoomListController.h"
#import "WLChatRoomController.h"
#import "ChatRoomSettingViewController.h"

#import "WLTextField.h"
#import "NotstringView.h"
#import "ChatRoomListViewCell.h"

#define KPasswordH 50.f
#define kMarginLeft 10.f
#define kMarginTop 8.f
#define kTableViewCellHeight 70.f

@interface ChatRoomListController () <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>

@property (assign,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *datasource;
@property (strong,nonatomic) NotstringView *notView;

@end

@implementation ChatRoomListController

- (NSString *)title
{
    return @"聊天室";
}

- (NotstringView *)notView
{
    if (!_notView) {
        _notView = [[NotstringView alloc] initWithFrame:_tableView.frame withTitleStr:@"没有发现你参与过的聊天室"];
    }
    return _notView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加创建活动按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建" style:UIBarButtonItemStyleDone target:self action:@selector(createChatRoom)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-KPasswordH) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //下方的输入栏
    UIView *bottomView = [[UIView alloc] initWithFrame:Rect(0.f, tableView.bottom, self.view.width, KPasswordH)];
    bottomView.backgroundColor = RGB(246.f, 246.f, 246.f);
    bottomView.layer.borderColorFromUIColor = RGB(184.f, 184.f, 184.f);
    bottomView.layer.borderWidths = @"{1,0,0,0}";
    [self.view addSubview:bottomView];
    
    //输入按钮
    UIButton *joinBtn = [UIButton getBtnWithTitle:nil image:[UIImage imageNamed:@"chat_list_go_logo"]];
    joinBtn.backgroundColor = [UIColor clearColor];
    [joinBtn sizeToFit];
    joinBtn.height = bottomView.height - kMarginTop * 2.f;
    joinBtn.right = bottomView.width - kMarginLeft;
    joinBtn.centerY = bottomView.height / 2.f;
    [joinBtn addTarget:self action:@selector(joinBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:joinBtn];
//    [joinBtn setDebug:YES];
    
    WLTextField *roomIdTF = [[WLTextField alloc] init];
    roomIdTF.backgroundColor = [UIColor whiteColor];
    roomIdTF.size = CGSizeMake(joinBtn.left - kMarginLeft * 2.f, joinBtn.height);
    roomIdTF.left = kMarginLeft;
    roomIdTF.centerY = bottomView.height / 2.f;
    roomIdTF.isToBounds = YES;//圆角
    roomIdTF.font = kNormal14Font;
    roomIdTF.textColor = kTitleNormalTextColor;
    roomIdTF.placeholder = @"输入口令，快速进入聊天室";
    roomIdTF.layer.borderColor = KBgGrayColor.CGColor;
    roomIdTF.layer.borderWidth = 0.8f;
    [bottomView addSubview:roomIdTF];
//    [roomIdTF setDebug:YES];
    
    //下拉刷新
    [_tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadReflshData)];
    //自动下拉刷新数据
    [_tableView.header beginRefreshing];
}

#pragma mark - Private
//进入聊天室
- (void)joinBtnClicked:(UIButton *)sender
{
    
}

- (void)loadReflshData
{
    [_tableView.header endRefreshing];
    
    //获取数据
    self.datasource = @[@{@"name":@"迭代资本聊天室",@"num":@"20"},
                        @{@"name":@"微链聊天室",@"num":@"20"},
                        @{@"name":@"迭代资本聊天室",@"num":@"20"},
                        @{@"name":@"迭代资本聊天室",@"num":@"20"},
                        @{@"name":@"迭代资本聊天室",@"num":@"20"},
                        @{@"name":@"迭代资本聊天室",@"num":@"20"}];
    [_tableView reloadData];
    
    //加载数据
    if(_datasource.count == 0){
        [_tableView addSubview:self.notView];
        [_tableView sendSubviewToBack:self.notView];
    }else{
        [_notView removeFromSuperview];
    }
}

//创建聊天室
- (void)createChatRoom
{
    ChatRoomSettingViewController *roomSettingVC = [[ChatRoomSettingViewController alloc] initWithRoomType:ChatRoomSetTypeCreate];
    [self.navigationController pushViewController:roomSettingVC animated:YES];
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


#pragma mark - UITableView Datasource&delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //微信联系人
    static NSString *cellIdentifier = @"ChatRoom_List_Cell";
    ChatRoomListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ChatRoomListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
//    cell.baseUser = _datasource[indexPath.row];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewCellHeight;
}

@end
