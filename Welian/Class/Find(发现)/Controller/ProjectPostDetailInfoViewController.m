//
//  ProjectPostDetailInfoViewController.m
//  Welian
//
//  Created by weLian on 15/5/20.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectPostDetailInfoViewController.h"
#import "UserInfoViewController.h"
#import "LookBPFileViewController.h"
#import "WebViewLookBPViewController.h"
#import "ChatViewController.h"
#import "MessagesViewController.h"
#import "ProjectDetailsViewController.h"
#import "ChatListViewController.h"
#import "WLChatViewController.h"

#import "ProjectInfoViewCell.h"
#import "FinancingInfoView.h"
#import "NoteMsgView.h"
#import "NoteTableViewCell.h"
#import "ProjectBPViewCell.h"
#import "FinancingInfoViewCell.h"

#define ToolBarHeight 50.f
#define kOperateButtonHeight 35.f
#define kmarginLeft 15.f
#define kNotViewHeight 30.f
#define kProjectInfoViewHeight 70.f

@interface ProjectPostDetailInfoViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (assign,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *datasource;
@property (strong,nonatomic) IProjectDetailInfo *iProjectDetailInfo;
@property (strong,nonatomic) NSNumber *localPid;

@property (assign,nonatomic) NoteMsgView *noteView;
@property (assign,nonatomic) UIView *operateToolView;
@property (assign,nonatomic) UIButton *noLikeBtn;
@property (assign,nonatomic) UIButton *talkNowBtn;

@end

@implementation ProjectPostDetailInfoViewController

- (void)dealloc
{
    _datasource = nil;
    _iProjectDetailInfo = nil;
    _localPid = nil;
}

- (NSString *)title
{
    return @"项目信息";
}

//- (instancetype)initWithProjectInfo:(IProjectDetailInfo *)iProjectDetailInfo
//{
//    self = [super init];
//    if (self) {
//        self.iProjectDetailInfo = iProjectDetailInfo;
//        self.datasource = @[@""];
//    }
//    return self;
//}

- (instancetype)initWithPid:(NSNumber *)pid
{
    self = [super init];
    if (self) {
        self.localPid = pid;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //tableview头部距离问题
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //添加创建活动按钮
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建活动" style:UIBarButtonItemStyleDone target:self action:@selector(createActivity)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.f,ViewCtrlTopBarHeight,self.view.width,self.view.height - ViewCtrlTopBarHeight - ToolBarHeight - kNotViewHeight)];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    //隐藏表格分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    //    [tableView setDebug:YES];
    
    //设置底部空白区域
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 40.f)];
    [tableView setTableFooterView:footerView];
    
    //设置提醒
    NoteMsgView *noteView = [[NoteMsgView alloc] initWithFrame:Rect(0, tableView.bottom, self.view.width, kNotViewHeight)];
    noteView.noteInfo = @"创业不易，每一次项目的投递，都是一次等待!";
//    noteView.hidden = YES;
    [self.view addSubview:noteView];
    self.noteView = noteView;
    
    //设置底部操作栏
    UIView *operateToolView = [[UIView alloc] initWithFrame:CGRectMake(0.f, noteView.bottom, self.view.width, ToolBarHeight)];
    operateToolView.backgroundColor = RGB(247.f, 247.f, 247.f);
    operateToolView.layer.borderColorFromUIColor = kNormalTextColor;
    operateToolView.layer.borderWidths = @"{0.6,0,0,0}";
//    operateToolView.hidden = YES;
    [self.view addSubview:operateToolView];
    [self.view bringSubviewToFront:operateToolView];
    self.operateToolView = operateToolView;
    
    //不感兴趣
    CGFloat btnWidth = (self.view.width - kmarginLeft * 3.f) / 2.f;
    UIButton *noLikeBtn = [UIView getBtnWithTitle:@"不感兴趣" image:nil];
    noLikeBtn.layer.borderColor = KBlueTextColor.CGColor;
    noLikeBtn.layer.borderWidth = .7f;
    noLikeBtn.size = CGSizeMake(btnWidth, kOperateButtonHeight);
    noLikeBtn.left = kmarginLeft;
    noLikeBtn.centerY = operateToolView.height / 2.f;
    [noLikeBtn setTitleColor:KBlueTextColor forState:UIControlStateNormal];
    [noLikeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [noLikeBtn addTarget:self action:@selector(noLikeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [operateToolView addSubview:noLikeBtn];
    self.noLikeBtn = noLikeBtn;
    
    //立即约谈
    UIButton *talkNowBtn = [UIView getBtnWithTitle:@"立即约谈" image:nil];
    talkNowBtn.size = CGSizeMake(btnWidth, kOperateButtonHeight);
    talkNowBtn.right = operateToolView.width - kmarginLeft;
    talkNowBtn.centerY = operateToolView.height / 2.f;
    talkNowBtn.backgroundColor = KBlueTextColor;
    [talkNowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [talkNowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [talkNowBtn addTarget:self action:@selector(talkNowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [operateToolView addSubview:talkNowBtn];
    self.talkNowBtn = talkNowBtn;
    
    [self checkNoLikeBtnUI];
    
    //获取信息
    [self initProjectDetailInfo];
}

#pragma mark - Private
//设置不感兴趣按钮
- (void)checkNoLikeBtnUI
{
    if (_iProjectDetailInfo) {
//        _noteView.hidden = NO;
//        _operateToolView.hidden = NO;
        
        //status  0:默认状态  1：已不感兴趣 2:已约谈 3:拒绝过又再次约谈
        _talkNowBtn.enabled = YES;
        [_talkNowBtn setTitle:(_iProjectDetailInfo.feedback.integerValue > 1 ? @"再次约谈" : @"立即约谈") forState:UIControlStateNormal];
        
        _noLikeBtn.enabled = _iProjectDetailInfo.feedback.integerValue > 0 ? NO : YES;
        if (_iProjectDetailInfo.feedback.integerValue > 0) {
            if (_iProjectDetailInfo.feedback.integerValue == 2) {
                //直接点击约谈，则按钮“不感兴趣”不能点击灰掉
                [_noLikeBtn setTitle:@"不感兴趣" forState:UIControlStateDisabled];
                [_noLikeBtn setImage:nil forState:UIControlStateDisabled];
            }else{
                //先不感兴趣   还可以约谈
                [_noLikeBtn setTitle:@"已不感兴趣" forState:UIControlStateDisabled];
                [_noLikeBtn setImage:[UIImage imageNamed:@"touziren_detail_already"] forState:UIControlStateDisabled];
            }
        }
    }else{
        _noLikeBtn.enabled = NO;
        _talkNowBtn.enabled = NO;
    }
    
    _talkNowBtn.backgroundColor = _talkNowBtn.enabled == NO ? KBgGrayColor : KBlueTextColor;
    
    _noLikeBtn.backgroundColor = _noLikeBtn.enabled == NO ? KBgGrayColor : [UIColor whiteColor];
    _noLikeBtn.layer.borderColor = _noLikeBtn.enabled == NO ? KBgGrayColor.CGColor : KBlueTextColor.CGColor;
    _noLikeBtn.imageEdgeInsets = _noLikeBtn.enabled == NO ? UIEdgeInsetsMake(0.f, -10.f, 0.f, 0.f) : UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
    [_noLikeBtn setTitleColor:_noLikeBtn.enabled == NO ? [UIColor whiteColor] : KBlueTextColor forState:UIControlStateNormal];
}

- (void)initProjectDetailInfo
{
    [WLHUDView showHUDWithStr:@"获取项目信息中..." dim:NO];
    [WeLianClient getInvestorProjectDetailInfoWithPid:_localPid
                                              Success:^(id resultInfo) {
                                                  [WLHUDView hiddenHud];
                                                  
                                                  self.iProjectDetailInfo = resultInfo;
                                                  self.datasource = self.iProjectDetailInfo.bp.bpid ? @[self.iProjectDetailInfo.bp] : nil;
                                                  [self checkNoLikeBtnUI];
                                                  [self.tableView reloadData];
                                              } Failed:^(NSError *error) {
                                                  if (error) {
                                                      [WLHUDView showErrorHUD:error.localizedDescription];
                                                  }else{
                                                      [WLHUDView showErrorHUD:@"获取项目信息失败，请重试！"];
                                                  }
                                              }];
}

//不感兴趣
- (void)noLikeBtnClicked:(UIButton *)sender
{
    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@""
                                                    message:@"确定对该项目不感兴趣？"];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert textFieldAtIndex:0].placeholder = @"说一下理由吧";
    [alert bk_addButtonWithTitle:@"取消" handler:nil];
    [alert bk_addButtonWithTitle:@"不感兴趣" handler:^{
        //发送好友请求
        [WLHUDView showHUDWithStr:@"反馈中..." dim:NO];
        [WeLianClient investorFankuiWithPid:_localPid
                                       Type:@(1)//1 不感兴趣，2约谈
                                        Msg:[alert textFieldAtIndex:0].text
                                    Success:^(id resultInfo) {
                                        [WLHUDView showSuccessHUD:@"已反馈"];
                                        
                                        //status  0:默认状态  1：已不感兴趣 2:已约谈
                                        self.iProjectDetailInfo.feedback = @(1);
                                        [self checkNoLikeBtnUI];
                                    } Failed:^(NSError *error) {
                                        if (error) {
                                            [WLHUDView showErrorHUD:error.localizedDescription];
                                        }else{
                                            [WLHUDView showErrorHUD:@"反馈失败，请重试！"];
                                        }
                                    }];
    }];
    [alert show];
}

//立即约谈
- (void)talkNowBtnClicked:(UIButton *)sender
{
    MyFriendUser *myFriendUser = [[LogInUser getCurrentLoginUser] getMyfriendUserWithUid:_iProjectDetailInfo.user.uid];
    //status  0:默认状态  1：已不感兴趣 2:已约谈 3:拒绝过又再次约谈
    if (myFriendUser && _iProjectDetailInfo.feedback.integerValue > 1) {
        //已经是好友，并且约谈过
        [self linkUserToChatUi];
    }else{
        //不是好友  或者未约谈过
        [UIAlertView bk_showAlertViewWithTitle:@""
                                       message:[NSString stringWithFormat:@"要立即约谈%@吗？",_iProjectDetailInfo.user.name]
                             cancelButtonTitle:@"取消"
                             otherButtonTitles:@[@"立即约谈"]
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           if (buttonIndex == 0) {
                                               return ;
                                           }else{
                                               [self talkNow];
                                           }
                                       }];
    }
}

//立即约谈
- (void)talkNow
{
    [WLHUDView showHUDWithStr:@"约谈中..." dim:NO];
    [WeLianClient investorFankuiWithPid:_localPid
                                   Type:@(2)//1 不感兴趣，2约谈
                                    Msg:@""
                                Success:^(id resultInfo) {
                                    [WLHUDView hiddenHud];
                                    
                                    [self linkUserToChatUi];
                                } Failed:^(NSError *error) {
                                    if (error) {
                                        [WLHUDView showErrorHUD:error.localizedDescription];
                                    }else{
                                        [WLHUDView showErrorHUD:@"约谈失败，请重试！"];
                                    }
                                }];
}

//创建好友关系 进入聊天页面
- (void)linkUserToChatUi
{
    //创建好友关系
    /**  好友关系，1好友，2好友的好友,-1自己，0没关系   */
    MyFriendUser *user = [[LogInUser getCurrentLoginUser] getMyfriendUserWithUid:_iProjectDetailInfo.user.uid];
    if (!user) {
        self.iProjectDetailInfo.user.friendship = @(1);
        user = [MyFriendUser createOrUpddateMyFriendUserModel:_iProjectDetailInfo.user];
    }
    
    
    UIViewController *rootVC = [self.navigationController.viewControllers firstObject];
    //当前已经在消息页面
    if ([rootVC isKindOfClass:[ChatListViewController class]]) {
        //            [KNSNotification postNotificationName:kCurrentChatFromUserInfo object:self userInfo:@{@"uid":_baseUserModel.uid.stringValue}];
        
//        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
//        if (!loginUser) {
//            return ;
//        }
//        MyFriendUser *user = [loginUser getMyfriendUserWithUid:_baseUserModel.uid];
        WLChatViewController *chatVC = [[WLChatViewController alloc] init];
        chatVC.targetId                      = user.uid.stringValue;
        chatVC.userName                    = user.name;
        chatVC.conversationType              = ConversationType_PRIVATE;
        chatVC.title                         = user.name;
        [self.navigationController pushViewController:chatVC animated:YES];
        
        //替换中间的内容
        NSMutableArray *contros = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [contros removeObjectsInRange:NSMakeRange(1, contros.count - 1) ];
        [contros addObject:chatVC];
        
        [self.navigationController setViewControllers:contros animated:YES];
    }else{
        //进入聊天页面
        [KNSNotification postNotificationName:kChatFromUserInfo object:self userInfo:@{@"uid":user.uid.stringValue}];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
//    UIViewController *rootVC = [self.navigationController.viewControllers firstObject];
//    //当前已经在消息页面
//    if ([rootVC isKindOfClass:[MessagesViewController class]]) {
//        [KNSNotification postNotificationName:kCurrentChatFromUserInfo object:self userInfo:@{@"uid":user.uid.stringValue}];
//        ChatViewController *chatVC = [[ChatViewController alloc] initWithUser:user];
//        [self.navigationController pushViewController:chatVC animated:YES];
//        
//        //替换中间的内容
//        NSMutableArray *contros = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//        [contros removeObjectsInRange:NSMakeRange(1, contros.count - 1) ];
//        [contros addObject:chatVC];
//        
//        [self.navigationController setViewControllers:contros animated:YES];
//    }else{
//        //进入聊天页面
//        [KNSNotification postNotificationName:kChatFromUserInfo object:self userInfo:@{@"uid":user.uid.stringValue}];
//        
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
}

//查看创建用户的信息
- (void)lookCreateUserInfo:(id)userInfo
{
    if ([userInfo isKindOfClass:[IProjectDetailInfo class]]) {
        IProjectDetailInfo *iProjectDetailInfo = userInfo;
        if (iProjectDetailInfo.user.uid) {
            UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithBaseUserM:iProjectDetailInfo.user OperateType:nil HidRightBtn:NO];
            [self.navigationController pushViewController:userInfoVC animated:YES];
        }
    }
}

- (void)downloadBPAndLook:(NSString *)url
{
    //下载照片
    NSString *fileName = [url lastPathComponent];
    NSString *folder = [[ResManager userResourcePath] stringByAppendingPathComponent:@"ChatDocument/ProjectBP/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]) {
        DLog(@"创建home cover 目录!");
        [[NSFileManager defaultManager] createDirectoryAtPath:folder
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    folder = [folder stringByAppendingPathComponent:fileName];
    
    //删除文件
//    [ResManager fileDelete:folder];
    if ([ResManager fileExistByPath:folder]) {
        //本地存在的话，直接查看
        LookBPFileViewController *lookBPFileVC = [[LookBPFileViewController alloc] initWithBpPath:url];
        [self.navigationController pushViewController:lookBPFileVC animated:YES];
    }else{
        WebViewLookBPViewController *webLookVC = [[WebViewLookBPViewController alloc] initWithBpPath:url];
        [self.navigationController pushViewController:webLookVC animated:YES];
    }
    
}

#pragma mark - UITableView Datasource&Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_iProjectDetailInfo){
        return _datasource.count ? _datasource.count + (_iProjectDetailInfo.status.boolValue ? 2 : 1 ) : (_iProjectDetailInfo.status.boolValue ? 3 : 2 );
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            //项目信息
            static NSString *cellIdentifier = @"FinancingInfo_ProjectInfo_View_Cell";
            ProjectInfoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[ProjectInfoViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.iProjectDetailInfo = _iProjectDetailInfo;
            WEAKSELF
            [cell setUserInfoBlock:^(id userInfo){
                [weakSelf lookCreateUserInfo:userInfo];
            }];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        default:
        {
            if (_iProjectDetailInfo.status.boolValue && indexPath.row == 1) {
                //正在融资
                static NSString *cellIdentifier = @"FinancingInfo_View_Cell";
                FinancingInfoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (!cell) {
                    cell = [[FinancingInfoViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                }
                cell.iProjectDetailInfo = _iProjectDetailInfo;
                return cell;
            }else{
                //评论列表
                if (_datasource.count > 0) {
                    static NSString *cellIdentifier = @"FinancingInfo_List_View_Cell";
                    ProjectBPViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                    if (!cell) {
                        cell = [[ProjectBPViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    }
                    IProjectBPModel *bpModel = _datasource[indexPath.row - (_iProjectDetailInfo.status.boolValue ? 2 : 1)];
                    cell.fineName = bpModel.bpname;// @"微链商业计划书.pdf";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    return cell;
                }else{
                    static NSString *cellIdentifier = @"FinancingInfo_Not_View_Cell";
                    NoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                    if (!cell) {
                        cell = [[NoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                    }
                    cell.noteInfo = @"该项目暂未上传BP文件";
                    return cell;
                }
            }
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_iProjectDetailInfo && indexPath.row == 0) {
        //项目信息不为空的时候，可以查看详情
        IProjectInfo *iProjectInfo = [_iProjectDetailInfo toIProjectInfoModel];
        ProjectDetailsViewController *projectDetialVC = [[ProjectDetailsViewController alloc] initWithIProjectInfo:iProjectInfo];
        [self.navigationController pushViewController:projectDetialVC animated:YES];
    }
    
    if (_datasource.count > 0) {
        if((_iProjectDetailInfo.status.boolValue && indexPath.row >= 2) || (!_iProjectDetailInfo.status.boolValue && indexPath.row >= 1)){
            IProjectBPModel *bpModel = _datasource[indexPath.row - (_iProjectDetailInfo.status.boolValue ? 2 : 1)];
            [WLHUDView showHUDWithStr:@"" dim:YES];
            [WeLianClient investorDownloadWithPid:bpModel.bpid
                                          Success:^(id resultInfo) {
                                              [WLHUDView hiddenHud];
                                              //BP地址url
                                              NSString *url = resultInfo[@"url"];
                                              [self downloadBPAndLook:url];
                                          } Failed:^(NSError *error) {
                                              if (error) {
                                                  [WLHUDView showErrorHUD:error.localizedDescription];
                                              }else{
                                                  [WLHUDView showErrorHUD:@"网络连接失败，请重试！"];
                                              }
                                          }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            //项目信息
            return kProjectInfoViewHeight;
        }
            break;
        default:
        {
            if (_iProjectDetailInfo.status.boolValue && indexPath.row == 1) {
                //正在融资
                //融资信息
                return [FinancingInfoView configureWithIProjectInfo:_iProjectDetailInfo];
            }else{
                //评论列表
                return 43.f;
            }
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            //项目信息
            return kProjectInfoViewHeight;
        }
            break;
        default:
        {
            if (_iProjectDetailInfo.status.boolValue && indexPath.row == 1) {
                //正在融资
                //融资信息
                return [FinancingInfoView configureWithIProjectInfo:_iProjectDetailInfo];
            }else{
                //评论列表
                return 43.f;
            }
        }
            break;
    }
}

@end
