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
@property (assign,nonatomic) WLTextField *roomIdTF;
@property (assign,nonatomic) NSInteger pageIndex;
@property (assign,nonatomic) NSInteger pageSize;
@property (strong,nonatomic) ChatRoomInfo *joinedRoom;

@end

@implementation ChatRoomListController

- (void)dealloc
{
    _datasource = nil;
    _notView = nil;
    _joinedRoom = nil;
    [KNSNotification removeObserver:self];
}

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pageIndex = 1;
        self.pageSize = KCellConut;
        
        [KNSNotification addObserver:self selector:@selector(refreshDataAndUI) name:@"NeedRloadChatRoomList" object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //注册键盘
    [DaiDodgeKeyboard addRegisterTheViewNeedDodgeKeyboard:self.view];
    
    if (_joinedRoom) {
        //退出聊天室
        //融云加入聊天室
        [[RCIMClient sharedRCIMClient] quitChatRoom:_joinedRoom.chatroomid.stringValue
                                            success:^{
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    self.joinedRoom = nil;
                                                    DLog(@"quitChatRoom success");
                                                });
                                            } error:^(RCErrorCode status) {
                                                NSString *errStr = @"";
                                                switch (status) {
                                                    case ERRORCODE_UNKNOWN:
                                                        errStr = @"未知错误";
                                                        break;
                                                    case ERRORCODE_TIMEOUT:
                                                        errStr = @"超时错误";
                                                        break;
                                                    case REJECTED_BY_BLACKLIST:
                                                        errStr = @"被对方加入黑名单时发送消息的状态";
                                                        break;
                                                    case NOT_IN_DISCUSSION:
                                                        errStr = @"不在讨论组中。";
                                                        break;
                                                    case NOT_IN_GROUP:
                                                        errStr = @"不在群组中。";
                                                        break;
                                                    case NOT_IN_CHATROOM:
                                                        errStr = @"不在聊天室中。";
                                                        break;
                                                    default:
                                                        break;
                                                }
                                                DLog(@"quitChatRoom erro:%@",errStr);
                                            }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //移除監控
    [DaiDodgeKeyboard removeRegisterTheViewNeedDodgeKeyboard];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.datasource = [ChatRoomInfo getAllChatRoomInfos];
    
    //添加创建活动按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建" style:UIBarButtonItemStyleDone target:self action:@selector(createChatRoom)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-KPasswordH) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //下方的输入栏
    UIView *bottomView = [[UIView alloc] initWithFrame:Rect(0.f, tableView.bottom, self.view.width, KPasswordH)];
    bottomView.backgroundColor = RGB(246.f, 246.f, 246.f);
    bottomView.layer.borderColorFromUIColor = RGB(171.f, 172.f, 173.f);
    bottomView.layer.borderWidths = @"{0.6f,0,0,0}";
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
    roomIdTF.returnKeyType = UIReturnKeyGo;
    [bottomView addSubview:roomIdTF];
    self.roomIdTF = roomIdTF;
//    [roomIdTF setDebug:YES];
    
    //回车
    WEAKSELF
    [roomIdTF setBk_shouldReturnBlock:^BOOL(UITextField *textField) {
        [weakSelf checkTextCodeAndJoinRoom];
        return YES;
    }];
    
    //下拉刷新
    [_tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(loadReflshData)];
    //上提加载更多
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    [_tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataArray)];
    // 隐藏当前的上拉刷新控件
    _tableView.footer.hidden = YES;
    
    if (_datasource.count > 0) {
        //后台加载数据
        [self loadReflshData];
    }else{
        //自动下拉刷新数据
        [_tableView.header beginRefreshing];
    }
}

#pragma mark - Private
//进入聊天室
- (void)joinBtnClicked:(UIButton *)sender
{
    [self checkTextCodeAndJoinRoom];
}

//检测并加入聊天室
- (void)checkTextCodeAndJoinRoom
{
    [[self.view findFirstResponder] resignFirstResponder];
    
    if([_roomIdTF.text deleteTopAndBottomKonggeAndHuiche].length == 0){
        [WLHUDView showErrorHUD:@"请输入聊天室口令！"];
        return;
    }
    [self joinRoomWithCode:_roomIdTF.text Room:nil];
}

//需要重新输入口令
- (void)needReSetCode:(IBaseModel *)baseModel
{
    //口令被修改过
    UIAlertView *alert = [[UIAlertView alloc] bk_initWithTitle:@"口令" message:baseModel.errormsg.length > 0 ? baseModel.errormsg : @"口令已被修改，请重新输入"];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert bk_addButtonWithTitle:@"取消" handler:nil];
    [alert bk_addButtonWithTitle:@"开启" handler:^{
        if([[alert textFieldAtIndex:0].text deleteTopAndBottomKonggeAndHuiche].length > 0){
            [self joinRoomWithCode:[alert textFieldAtIndex:0].text Room:nil];
        }
    }];
    [alert show];
}

- (void)hasNoThisCodeRoom:(IBaseModel *)baseModel ChatRoom:(ChatRoomInfo *)chatRoom
{
    [UIAlertView bk_showAlertViewWithTitle:@""
                                   message:baseModel.errormsg.length > 0 ? baseModel.errormsg : @"该聊天室已失效！"
                         cancelButtonTitle:@"知道了"
                         otherButtonTitles:nil
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if(chatRoom){
                                           [self deleteChatRoomWithRoom:chatRoom isNeedNote:NO];
                                       }
                                   }];
}

//加入聊天室
- (void)joinRoomWithCode:(NSString *)code Room:(ChatRoomInfo *)chatRoomInfo
{
    [WLHUDView showHUDWithStr:@"" dim:NO];
    //首次进入chatroom根据code可以直接进入，第二次进入的时候验证code
    [WeLianClient chatroomJoinWithId:code.length > 0 ? @(0) : chatRoomInfo.chatroomid
                                Code:code.length > 0 ? code : chatRoomInfo.code
                             Success:^(id resultInfo) {
                                 [WLHUDView hiddenHud];
                                 
                                 //清空口令
                                 _roomIdTF.text = @"";
                                 
                                 if ([resultInfo isKindOfClass:[IBaseModel class]]) {
                                     //1000，1020：没有这个口令的聊天室，1100，口令被修改过，不正确
                                     IBaseModel *model = resultInfo;
                                     switch (model.state.integerValue) {
                                         case 1100:
                                             [self needReSetCode:model];
                                             break;
                                         case 1020:
                                             [self hasNoThisCodeRoom:model ChatRoom:chatRoomInfo];
                                             break;
                                         default:
                                             break;
                                     }
                                 }else{
                                     ChatRoomInfo *chatRoom = [ChatRoomInfo createChatRoomInfoWith:resultInfo];
                                     //融云加入聊天室
                                     [[RCIMClient sharedRCIMClient] joinChatRoom:chatRoom.chatroomid.stringValue
                                                                    messageCount:0
                                                                         success:^{
                                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                                 self.joinedRoom = chatRoom;
                                                                                 
                                                                                 //只有code
                                                                                 RCConversationModel *model = [[RCConversationModel alloc] init];
                                                                                 model.targetId = chatRoom.chatroomid.stringValue;
                                                                                 model.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
                                                                                 model.conversationType = ConversationType_CHATROOM;
                                                                                 model.conversationTitle = chatRoom.title;
                                                                                 
                                                                                 WLChatRoomController *chatRoomVC = [[WLChatRoomController alloc] initWithChatRoomInfo:chatRoom];
                                                                                 chatRoomVC.conversationType = model.conversationType;
                                                                                 chatRoomVC.targetId = model.targetId;
                                                                                 chatRoomVC.userName = model.conversationTitle;
                                                                                 //    chatRoomVC.title = model.conversationTitle;
                                                                                 [self.navigationController pushViewController:chatRoomVC animated:YES];
                                                                                 //更新加入的数据
                                                                                 [self refreshDataAndUI];
                                                                             });
                                                                         } error:^(RCErrorCode status) {
                                                                             NSString *errStr = @"";
                                                                             switch (status) {
                                                                                 case ERRORCODE_UNKNOWN:
                                                                                     errStr = @"未知错误";
                                                                                     break;
                                                                                 case ERRORCODE_TIMEOUT:
                                                                                     errStr = @"超时错误";
                                                                                     break;
                                                                                 case REJECTED_BY_BLACKLIST:
                                                                                     errStr = @"被对方加入黑名单时发送消息的状态";
                                                                                     break;
                                                                                 case NOT_IN_DISCUSSION:
                                                                                     errStr = @"不在讨论组中。";
                                                                                     break;
                                                                                 case NOT_IN_GROUP:
                                                                                     errStr = @"不在群组中。";
                                                                                     break;
                                                                                 case NOT_IN_CHATROOM:
                                                                                     errStr = @"不在聊天室中。";
                                                                                     break;
                                                                                 default:
                                                                                     break;
                                                                             }
                                                                             DLog(@"joinChatRoom erro:%@",errStr);
                                                                         }];
                                 }
                             } Failed:^(NSError *error) {
                                 //清空口令
                                 _roomIdTF.text = @"";
                                 //1000，1020：没有这个口令的聊天室，1100，口令被修改过，不正确
                                 if (error) {
                                     [WLHUDView showErrorHUD:error.localizedDescription];
                                 }else{
                                     [WLHUDView showErrorHUD:@"加入聊天室失败，请重试！"];
                                 }
                             }];
}

- (void)loadReflshData
{
    self.pageIndex = 1;
    [self initData];
}

//加载更多数据
- (void)loadMoreDataArray
{
    [self initData];
}

- (void)initData
{
    [WeLianClient getChatroomListWithPage:@(_pageIndex)
                                     Size:@(_pageSize)
                                  Success:^(id resultInfo) {
                                      //第一页 隐性 删除所有
                                      [ChatRoomInfo deleteAllChatRoomInfos];
                                      
                                      if([resultInfo count] > 0){
                                          //异步保存数据
                                          [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                              NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isNow",@(YES)];
                                              LogInUser *loginUser = [LogInUser MR_findFirstWithPredicate:pre inContext:localContext];
                                              if (!loginUser) {
                                                  return;
                                              }
                                              
                                              for (IChatRoomInfo *iChatRoomInfo in resultInfo) {
                                                  NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"chatroomid",iChatRoomInfo.chatroomid];
                                                  ChatRoomInfo *chatRoomInfo = [ChatRoomInfo MR_findFirstWithPredicate:pre inContext:localContext];
                                                  if (!chatRoomInfo) {
                                                      chatRoomInfo = [ChatRoomInfo MR_createEntityInContext:localContext];
                                                  }
                                                  chatRoomInfo.chatroomid = iChatRoomInfo.chatroomid;
                                                  chatRoomInfo.title = iChatRoomInfo.title;
                                                  chatRoomInfo.code = chatRoomInfo.code.length > 0 ? chatRoomInfo.code : iChatRoomInfo.code;
                                                  chatRoomInfo.starttime = iChatRoomInfo.starttime;
                                                  chatRoomInfo.endtime = iChatRoomInfo.endtime;
                                                  chatRoomInfo.avatorUrl = iChatRoomInfo.avatar;
                                                  chatRoomInfo.joinUserCount = iChatRoomInfo.total;
                                                  chatRoomInfo.isShow = @(YES);
                                                  chatRoomInfo.role = iChatRoomInfo.role;
                                                  chatRoomInfo.shareUrl = iChatRoomInfo.shareurl;
//                                                  chatRoomInfo.lastJoinTime = [iChatRoomInfo.created dateFromNormalStringNoss];
                                                  chatRoomInfo.lastJoinTime = [NSDate date];
                                                  
                                                  [loginUser addRsChatRoomInfosObject:chatRoomInfo];
                                              }
                                          } completion:^(BOOL contextDidSave, NSError *error) {
                                              [self loadDataAndUIWith:resultInfo];
                                          }];
                                      }else{
                                          [self loadDataAndUIWith:resultInfo];
                                      }
                                  } Failed:^(NSError *error) {
                                      [_tableView.header endRefreshing];
                                      [_tableView.footer endRefreshing];
                                      if (error) {
                                          [WLHUDView showErrorHUD:error.localizedDescription];
                                      }else{
                                          [WLHUDView showErrorHUD:@"获取聊天室失败，请重试！"];
                                      }
                                  }];
}

- (void)loadDataAndUIWith:(id)resultInfo
{
    [_tableView.header endRefreshing];
    [_tableView.footer endRefreshing];
    
    self.datasource = [ChatRoomInfo getAllChatRoomInfos];
    [_tableView reloadData];
    
    //设置是否可以下拉刷新
    if ([resultInfo count] != _pageSize) {
        _tableView.footer.hidden = YES;
    }else{
        _tableView.footer.hidden = NO;
        _pageIndex++;
    }
    
    //加载数据
    if(_datasource.count == 0){
        [_tableView addSubview:self.notView];
        [_tableView sendSubviewToBack:self.notView];
    }else{
        [_notView removeFromSuperview];
    }
}

- (void)refreshDataAndUI
{
    self.datasource = [ChatRoomInfo getAllChatRoomInfos];
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
    ChatRoomSettingViewController *roomSettingVC = [[ChatRoomSettingViewController alloc] initWithRoomType:ChatRoomSetTypeCreate ChatRoomInfo:nil];
    [self.navigationController pushViewController:roomSettingVC animated:YES];
}

//删除，并退出 当前聊天室
- (void)deleteChatRoomWithRoom:(ChatRoomInfo *)chatRoomInfo isNeedNote:(BOOL)isNeedNote
{
    if (!chatRoomInfo) {
        return;
    }
    [WLHUDView showHUDWithStr:@"删除中..." dim:NO];
    [WeLianClient chatroomQuitWithId:chatRoomInfo.chatroomid
                             Success:^(id resultInfo) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [WLHUDView hiddenHud];
                                     
                                     //本地删除
                                     [chatRoomInfo MR_deleteEntity];
                                     [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                                     if (isNeedNote) {
                                         [UIAlertView bk_showAlertViewWithTitle:@""
                                                                        message:chatRoomInfo.role.boolValue ? @"删除并解散聊天室成功！" : @"删除并退出聊天室成功！"
                                                              cancelButtonTitle:@"知道了"
                                                              otherButtonTitles:nil
                                                                        handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                            [self refreshDataAndUI];
                                                                        }];
                                     }else{
                                         [self refreshDataAndUI];
                                     }
                                 });
                             } Failed:^(NSError *error) {
                                 if (error) {
                                     [WLHUDView showErrorHUD:error.localizedDescription];
                                 }else{
                                     [WLHUDView showErrorHUD:@"删除或解散聊天室失败，请重试！"];
                                 }
                             }];
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
    cell.chatRoomInfo = _datasource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //直接进入聊天室
    [self joinRoomWithCode:nil Room:_datasource[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewCellHeight;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - 删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatRoomInfo *chatRoomInfo = _datasource[indexPath.row];
    [UIAlertView bk_showAlertViewWithTitle:@""
                                   message:chatRoomInfo.role.boolValue ? @"确认删除并解散当前聊天室？" : @"确认删除并退出当前聊天室？"
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@[@"删除"]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (buttonIndex == 0) {
                                           return ;
                                       }else{
                                           //删除项目
                                           [self deleteChatRoomWithRoom:chatRoomInfo isNeedNote:YES];
                                       }
                                   }];
}

@end
