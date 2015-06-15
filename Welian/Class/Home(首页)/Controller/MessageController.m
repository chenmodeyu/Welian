//
//  MessageController.m
//  weLian
//
//  Created by dong on 14/11/13.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "MessageController.h"
#import "MessageHomeModel.h"
#import "MJExtension.h"
#import "MessageCell.h"
#import "CommentInfoController.h"
#import "WLStatusFrame.h"
#import "WLStatusM.h"
#import "NotstringView.h"
#import "UIImage+ImageEffects.h"
#import "HomeMessage.h"
#import "ProjectDetailsViewController.h"

@interface MessageController ()
{
    NSMutableArray *_messageDataArray;
    NSArray *_allMessgeArray;
}

@property (nonatomic, strong) NotstringView *notView;

@property (nonatomic, strong) UIButton *footButton;

@end

@implementation MessageController

- (UIView *)footButton
{
    if (_footButton== nil) {
        _footButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_footButton setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateNormal];
        // tableFooterView的宽度是不需要设置。默认就是整个tableView的宽度
        _footButton.bounds = CGRectMake(0, 0, 0, 44);
        [_footButton.titleLabel setFont:kNormal14Font];
        [_footButton setTitle:@"查看更早的信息" forState:UIControlStateNormal];
        [_footButton addTarget:self action:@selector(loadAllMessgeData:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footButton;
}


- (void)loadAllMessgeData:(UIButton*)but
{
    [self.tableView setTableFooterView:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空列表" style:UIBarButtonItemStyleBordered target:self action:@selector(cleacMessage)];
    [_messageDataArray removeAllObjects];
    _allMessgeArray = nil;
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    _allMessgeArray = [loginUser getAllMessages];
    for (HomeMessage *mesitme in _allMessgeArray) {
        MessageFrameModel *messageFrameM = [[MessageFrameModel alloc] init];
        [messageFrameM setMessageDataM:mesitme];
        [_messageDataArray addObject:messageFrameM];
    }
    [self.tableView reloadData];
}

- (NotstringView *)notView
{
    if (_notView == nil ) {
        _notView = [[NotstringView alloc] initWithFrame:self.tableView.frame withTitStr:@"还没有消息通知哦！" andImageName:@"remind_big_logo"];
    }
    return _notView;
}

- (void)cleacMessage
{
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    loginUser.rsHomeMessages = nil;
//    [MOC save];
    [[loginUser managedObjectContext] MR_saveToPersistentStoreAndWait];
    [_messageDataArray removeAllObjects];
    [self.tableView reloadData];
    [self.tableView addSubview:self.notView];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [UserDefaults removeObjectForKey:KMessagebadge];
        _messageDataArray = [NSMutableArray array];
        [self.tableView setSectionHeaderHeight:0.1];
        [self.tableView setBackgroundColor:[UIColor whiteColor]];
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        [self.tableView setSectionFooterHeight:0];
        
        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
        _allMessgeArray = [loginUser getAllMessages];
        
        if (!loginUser.homemessagebadge.integerValue) {
            if (_allMessgeArray.count) {
                 self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空列表" style:UIBarButtonItemStyleBordered target:self action:@selector(cleacMessage)];
            }
            for (HomeMessage *hoemM in _allMessgeArray) {
                MessageFrameModel *messageFrameM = [[MessageFrameModel alloc] init];
                [messageFrameM setMessageDataM:hoemM];
                [_messageDataArray addObject:messageFrameM];
            }
        }else{
            for (HomeMessage *homeM  in _allMessgeArray) {
                if (!homeM.isLook.boolValue) {
                    homeM.isLook = @(1);
                    MessageFrameModel *messageFrameM = [[MessageFrameModel alloc] init];
                    [messageFrameM setMessageDataM:homeM];
                    [_messageDataArray addObject:messageFrameM];
                }
            }
            [self.tableView setTableFooterView:self.footButton];
        }
        if (!_messageDataArray.count) {
            
            [self.tableView addSubview:self.notView];
            
        }
        [LogInUser setUserHomemessagebadge:@(0)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"消息列表"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _messageDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *messageCell = [MessageCell cellWithTableView:tableView];
    
    MessageFrameModel *messageFrameModel = _messageDataArray[indexPath.row];
    
    [messageCell setMessageFrameModel:messageFrameModel];
    
    return messageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageFrameModel *messageFrameModel = _messageDataArray[indexPath.row];
    
    return messageFrameModel.cellHigh;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MessageFrameModel *messageFrameModel = _messageDataArray[indexPath.row];
    HomeMessage *messagedata = messageFrameModel.messageDataM;
    if ([messagedata.type isEqualToString:@"projectComment"]||[messagedata.type isEqualToString:@"projectCommentZan"]) {
        //进入项目详情
        ProjectDetailsViewController *projectDetailVC = [[ProjectDetailsViewController alloc] initWithProjectPid:messagedata.feedid];
        [self.navigationController pushViewController:projectDetailVC animated:YES];
    }else{
        //动态详情
        YTKKeyValueItem *item = [[WLDataDBTool sharedService] getYTKKeyValueItemById:[NSString stringWithFormat:@"%@",messagedata.feedid] fromTable:KWLStutarDataTableName];
        
        WLStatusM *statusM = [WLStatusM objectWithDict:item.itemObject];
        [statusM setFid:messagedata.feedid];
        [statusM setTopid:messagedata.feedid];
        CommentInfoController *commentVC = [[CommentInfoController alloc] init];
        [commentVC setStatusM:statusM];
        [self.navigationController pushViewController:commentVC animated:YES];
    }
}

@end
