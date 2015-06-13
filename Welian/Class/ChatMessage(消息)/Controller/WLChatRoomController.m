//
//  WLChatRoomController.m
//  Welian
//
//  Created by dong on 15/6/12.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "WLChatRoomController.h"
#import "UserInfoViewController.h"
#import "ChatRoomSettingViewController.h"

@interface WLChatRoomController ()


@end

@implementation WLChatRoomController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *userItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_member"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(chatRoomUserItemClicked)];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_more"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self action:@selector(shareItemClicked)];
    
    //添加创建活动按钮
    self.navigationItem.rightBarButtonItems = @[moreItem,userItem];
    
    
}

#pragma mark - Private
//查看聊天室人员
- (void)chatRoomUserItemClicked
{
    
}

//更多操作按钮
- (void)shareItemClicked
{
    ChatRoomSettingViewController *roomSettingVC = [[ChatRoomSettingViewController alloc] initWithRoomType:ChatRoomSetTypeChange];
    [self.navigationController pushViewController:roomSettingVC animated:YES];
}

#pragma mark override
/**
 *  点击头像事件
 *
 *  @param userId 用户的ID
 */
- (void)didTapCellPortrait:(NSString *)userId
{
    IBaseUserM *userMode = [[IBaseUserM alloc] init];
    //自己发送
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    if (userId.integerValue == loginUser.uid.integerValue) {
        userMode = [loginUser toIBaseUserModelInfo];
    }else{
        //好友头像
        MyFriendUser *friendUser = [loginUser getMyfriendUserWithUid:@(userId.integerValue)];
        userMode = [friendUser toIBaseUserModelInfo];
    }
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithBaseUserM:userMode OperateType:userMode.friendship.integerValue == 1 ? @(10) : nil HidRightBtn:NO];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
