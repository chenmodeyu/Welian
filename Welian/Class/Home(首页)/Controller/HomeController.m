//
//  HomeController.m
//  Welian
//
//  Created by dong on 14-9-10.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "HomeController.h"
#import "PublishStatusController.h"
#import "NavViewController.h"
#import "MJRefresh.h"
#import "WLStatusCell.h"
#import "WLUserStatusesResult.h"
#import "WLStatusM.h"
#import "WLStatusFrame.h"
#import "UIImageView+WebCache.h"
#import "CommentInfoController.h"
#import "MJExtension.h"
#import "HomeView.h"
#import "MessageController.h"
#import "UIBarButtonItem+Badge.h"
#import "CommentMode.h"
#import "MainViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "NotstringView.h"
#import "WLPhoto.h"
#import "IPhotoUp.h"

@interface HomeController () <UITableViewDelegate,UITableViewDataSource>
{
   __block NSMutableArray *_dataArry;
    
    NSNumber *_uid;
    NSIndexPath *_seletIndexPath;
    
    NSInteger _page;
}
@property (nonatomic, strong) HomeView *homeView;

@property (nonatomic, strong) NotstringView *notDataView;

@end

@implementation HomeController

- (NotstringView *)notDataView
{
    if (_notDataView == nil) {
        _notDataView = [[NotstringView alloc] initWithFrame:self.tableView.frame withTitleStr:@"你还没发布过动态"];
        [_notDataView setHidden:YES];
        [self.tableView addSubview:_notDataView];
    }
    return _notDataView;
}

- (HomeView *)homeView
{
    if (_homeView == nil) {
        _homeView = [[HomeView alloc] initWithFrame:self.tableView.frame];
        [_homeView setHomeController:self];
        [_homeView setHidden:YES];
        [self.tableView addSubview:_homeView];
    }
    return _homeView;
}

- (void)beginRefreshing
{
    [self.tableView.header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //现实头部导航
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (instancetype)initWithUid:(NSNumber *)uid
{
    _uid = uid;
    self = [super init];
    if (self) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.tableView setDataSource:self];
        [self.tableView setDelegate:self];
        [self.view addSubview:self.tableView];
        [self.tableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(beginPullDownRefreshing)];
        self.tableView.header.updatedTimeHidden = YES;
        [self.tableView.header beginRefreshing];
        [self.tableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        self.tableView.footer.hidden = YES;

        _dataArry = [NSMutableArray array];
        if (!_uid) {
            NSArray *againArray = [self getSendAgainStuatArray];
            [_dataArry addObjectsFromArray:againArray];
            NSArray *arrr  = [[WLDataDBTool sharedService] getAllItemsFromTable:KHomeDataTableName];
            [self loadFirstFID:[self dataFrameWith:[[arrr firstObject] itemObject]]];
            for (YTKKeyValueItem *aa in arrr) {
                WLStatusFrame *sf = [self dataFrameWith:aa.itemObject];
                [_dataArry addObject:sf];
            }
        }
    }
    return self;
}

#pragma mark - 取第一条ID保存
- (void)loadFirstFID:(WLStatusFrame *)statusF
{
    // 1.第一条微博的ID
    [LogInUser setUserFirststustid:statusF.status.fid];
}

- (void)endRefreshing
{
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
}

#pragma mark - 刷新动态列表数据
- (void)beginPullDownRefreshing
{
    NSMutableDictionary *darDic = [NSMutableDictionary dictionary];
    [darDic setObject:@(KCellConut) forKey:@"size"];
    _page = 1;
    if (_uid) {
        [darDic setObject:@(_page) forKey:@"page"];
        [darDic setObject:_uid forKey:@"uid"];        
    }else {
        [darDic setObject:@(0) forKey:@"start"];
    }
    WEAKSELF
    [WeLianClient getFeedListWithParameterDic:darDic Success:^(id resultInfo) {
        weakSelf.tableView.tableHeaderView = nil;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 耗时的操作
            NSArray *jsonarray = [NSArray arrayWithArray:resultInfo];
            NSMutableArray *newDataArray = [NSMutableArray array];
            
            NSArray *againArray = [weakSelf getSendAgainStuatArray];
            [newDataArray addObjectsFromArray:againArray];
            
            for (NSDictionary *statusDic in jsonarray) {
                WLStatusFrame *sf = [weakSelf dataFrameWith:statusDic];
                [newDataArray addObject:sf];
            }
            _page++;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_uid) {
                    [LogInUser setUserNewstustcount:@(0)];
                    [weakSelf loadFirstFID:[weakSelf dataFrameWith:[jsonarray firstObject]]];
                }
                DLog(@"-----更新界面");
                _dataArry = newDataArray;
                // 更新界面
                if (!_uid) {
                    [weakSelf.homeView setHidden:_dataArry.count];
                }else if(_uid.integerValue == 0){
                    [weakSelf.notDataView setHidden:_dataArry.count];
                }
                [[MainViewController sharedMainViewController] updataItembadge];
                [weakSelf.tableView reloadData];
                [weakSelf endRefreshing];
                if (jsonarray.count<KCellConut) {
                    [weakSelf.tableView.footer setHidden:YES];
                }else{
                    [weakSelf.tableView.footer setHidden:NO];
                }
            });  
        });
        
        
    } Failed:^(NSError *error) {
        [self endRefreshing];
    }];
}

- (WLStatusFrame*)dataFrameWith:(NSDictionary *)statusDic
{
    WLStatusM *statusM = [WLStatusM objectWithDict:statusDic];
    WLStatusFrame *sf = [[WLStatusFrame alloc] initWithWidth:[UIScreen mainScreen].bounds.size.width-60];
    sf.status = statusM;
    return sf;
}

#pragma mark 加载更多数据
- (void)loadMoreData
{
    NSMutableDictionary *darDic = [NSMutableDictionary dictionary];
    [darDic setObject:@(KCellConut) forKey:@"size"];
    if (_uid) {
        [darDic setObject:_uid forKey:@"uid"];
        [darDic setObject:@(_page) forKey:@"page"];
    }else{
        // 1.最后1条微博的ID
        WLStatusFrame *f = [_dataArry lastObject];
        [darDic setObject:f.status.fid forKey:@"start"];
    }
    [WeLianClient getFeedListWithParameterDic:darDic Success:^(id resultInfo) {
        NSArray *jsonarray = [NSArray arrayWithArray:resultInfo];
        
        // 1.在拿到最新微博数据的同时计算它的frame
        NSMutableArray *newFrames = [NSMutableArray array];
        
        for (NSDictionary *dic in jsonarray) {
            WLStatusFrame *sf = [self dataFrameWith:dic];
            [newFrames addObject:sf];
        }
        // 2.将newFrames整体插入到旧数据的后面
        [_dataArry addObjectsFromArray:newFrames];
        _page++;
        [self.tableView reloadData];
        
        [self endRefreshing];
        if (jsonarray.count<KCellConut) {
            [self.tableView.footer setHidden:YES];
        }
    } Failed:^(NSError *error) {
        [self endRefreshing];
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [KNSNotification addObserver:self selector:@selector(beginPullDownRefreshing) name:KPublishOK object:nil];
    
    [KNSNotification addObserver:self selector:@selector(messageHomenotif) name:KMessageHomeNotif object:nil];
    
    //刷新所有好友通知
//    [KNSNotification addObserver:self selector:@selector(loadMyAllFriends) name:KupdataMyAllFriends object:nil];
    
    // 1.设置界面属性
    [self buildUI];
    
    // 获取所有好友
    [self loadMyAllFriends];
    
    //每次程序启动获取一次活动里面的城市列表
//    [self loadAcitvityCitys];
    //获取默认筛选条件
    [self loadCommonSelectInfos];
}

- (void)dealloc
{
    [KNSNotification removeObserver:self];
}

#pragma mark - 来了新消息
- (void)messageHomenotif
{
    NSString *badgeStr = [NSString stringWithFormat:@"%@",[LogInUser getCurrentLoginUser].homemessagebadge];
    [self.navigationItem.leftBarButtonItem setBadgeValue:badgeStr];
    [[MainViewController sharedMainViewController] updataItembadge];
}


#pragma mark 设置界面属性
- (void)buildUI
{
    if (!_uid||(_uid!=nil &&_uid.integerValue==0)) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_write"] style:UIBarButtonItemStyleBordered target:self action:@selector(publishStatus)];
    }
    // 背景颜色
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setBackgroundColor:WLLineColor];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, IWTableBorderWidth, 0);
    
    // 检查网络连接
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    WEAKSELF
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            [weakSelf showStatusNotReachable];
              [WLHUDView showErrorHUD:@"网络已断开，请检查网络"];
        }else{
            [weakSelf.tableView.header beginRefreshing];

        }
    }];
}

/**
 *  显示最新微博的数量（提示）
 */
- (void)showStatusNotReachable
{
    // 1.创建一个按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.userInteractionEnabled = NO;
    btn.backgroundColor = RGB(255, 238, 238);
    [btn setImage:[UIImage imageNamed:@"Shape"] forState:UIControlStateNormal];
    // 3.设置文字
    [btn setTitle:@"网络无法连接，请检查网络配置" forState:UIControlStateNormal];
    [btn setTitleColor:RGB(127, 127, 127) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    // 4.设置frame
    CGFloat btnW = self.view.frame.size.width;
    CGFloat btnH = 44;
    CGFloat btnY = 64 - btnH;
    btn.frame = CGRectMake(0, btnY, btnW, btnH);
    
    // 5.添加按钮
    [self.navigationController.view insertSubview:btn belowSubview:self.navigationController.navigationBar];
    
    // 6.执行动画

    CGFloat duration = 0.7;
    [UIView animateWithDuration:duration animations:^{
        btn.transform = CGAffineTransformMakeTranslation(0, btnH);
    } completion:^(BOOL finished) {
        [self.tableView setTableHeaderView:nil];
        [self.tableView setTableHeaderView:btn];
    }];
}

#pragma mark - 发表状态
- (void)publishStatus
{
    PublishStatusController *publishVC = [[PublishStatusController alloc] init];
    publishVC.publishDicBlock = ^(NSDictionary *reqDataDic, NSString *fidStr){
        [self sendAgainStuat:reqDataDic withFidStr:fidStr];
    };
    [self presentViewController:[[NavViewController alloc] initWithRootViewController:publishVC] animated:YES completion:^{
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArry.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.取出一个cell
    WLStatusCell *cell = [WLStatusCell cellWithTableView:tableView];
    [cell setHomeVC:self];
    
    // 2.给cell传递模型数据
    // 传递的模型：文字数据 + 子控件frame数据
    cell.statusFrame = _dataArry[indexPath.row];
    cell.feedzanBlock = ^(WLStatusM *statusM){
        WLStatusFrame *statusF = _dataArry[indexPath.row];
        [statusF setStatus:statusM];
        [_dataArry replaceObjectAtIndex:indexPath.row withObject:statusF];
        [self.tableView reloadData];
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    };
    cell.feedTuiBlock = ^(WLStatusM *statusM){
        WLStatusFrame *statusF = _dataArry[indexPath.row];
        [statusF setStatus:statusM];
        [_dataArry replaceObjectAtIndex:indexPath.row withObject:statusF];
        [self.tableView reloadData];
    };
    //    // 评论
    [cell.contentAndDockView.dock.commentBtn addTarget:self action:@selector(commentBtnClick:event:) forControlEvents:UIControlEventTouchUpInside];
    
    // 重新发送
    [cell.contentAndDockView.dock.sendAgainBtn addTarget:self action:@selector(sendAgainBtnClick:event:) forControlEvents:UIControlEventTouchUpInside];
    
    // 更多
    [cell.moreBut addTarget:self action:@selector(moreClick:event:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - 重新发送按钮
- (void)sendAgainBtnClick:(UIButton*)but event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if(indexPath)
    {
        WLStatusFrame *statusF = _dataArry[indexPath.row];
        YTKKeyValueItem *itemDic = [[WLDataDBTool sharedService] getYTKKeyValueItemById:statusF.status.sendId fromTable:KSendAgainDataTableName];
        [self sendStuat:itemDic.itemObject withIndexPath:indexPath];
    }

}

#pragma mark- 评论
- (void)commentBtnClick:(UIButton*)but event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if(indexPath)
    {
        [self pushCommentInfoVC:indexPath];
    }
}

#pragma mark - 更多按钮
- (void)moreClick:(UIButton*)but event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if(indexPath)
    {
        WEAKSELF
        UIActionSheet *sheet = [[UIActionSheet alloc] bk_initWithTitle:nil];
        [sheet bk_setDestructiveButtonWithTitle:@"删除该条动态" handler:^{
            WLStatusFrame *statuF = _dataArry[indexPath.row];
            if (statuF.status.type.integerValue==101) { // 删除自己发布的
                [[WLDataDBTool sharedService] deleteObjectById:statuF.status.sendId fromTable:KSendAgainDataTableName];
                [_dataArry removeObject:statuF];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                if (_uid) {
                    [weakSelf.notDataView setHidden:_dataArry.count];
                }else{
                    [weakSelf.homeView setHidden:_dataArry.count];
                }
            }else{
                [WeLianClient deleteFeedWithID:statuF.status.fid
                                       Success:^(id resultInfo) {
                                           [_dataArry removeObject:statuF];
                                           [weakSelf.tableView reloadData];
                                           if (_uid) {
                                               [weakSelf.notDataView setHidden:_dataArry.count];
                                           }else{
                                               [weakSelf.homeView setHidden:_dataArry.count];
                                           }
                                       } Failed:^(NSError *error) {
                                           
                                       }];
            }
        }];
        [sheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [sheet showInView:self.view];
    }
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_dataArry[indexPath.row] cellHigh]+5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_dataArry[indexPath.row] cellHigh]+5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self pushCommentInfoVC:indexPath];
}

#pragma mark - 进入详情页
- (void)pushCommentInfoVC:(NSIndexPath*)indexPath
{
    WLStatusFrame *statusF = _dataArry[indexPath.row];
    NSInteger type = statusF.status.type.integerValue;
    if (type==2 ||type==4 || type==5||type==6||type==12 || type ==101) return;
    
    CommentInfoController *commentInfo = [[CommentInfoController alloc] init];
    [commentInfo setStatusM:statusF.status];
    commentInfo.feedzanBlock = ^(WLStatusM *statusM){
        
        WLStatusFrame *statusF = _dataArry[indexPath.row];
        [statusF setStatus:statusM];
        [_dataArry replaceObjectAtIndex:indexPath.row withObject:statusF];
        [self.tableView reloadData];
    };
    commentInfo.feedTuiBlock = ^(WLStatusM *statusM){
        
        WLStatusFrame *statusF = _dataArry[indexPath.row];
        [statusF setStatus:statusM];
        [_dataArry replaceObjectAtIndex:indexPath.row withObject:statusF];
        [self.tableView reloadData];
    };
    commentInfo.commentBlock = ^(WLStatusM *statusM){
        WLStatusFrame *statusF = _dataArry[indexPath.row];
        [statusF setStatus:statusM];
        [_dataArry replaceObjectAtIndex:indexPath.row withObject:statusF];
        [self.tableView reloadData];
    };
    
    commentInfo.deleteStustBlock = ^(WLStatusM *statusM){
        WLStatusFrame *statusF = _dataArry[indexPath.row];
        [statusF setStatus:statusM];
        [_dataArry removeObject:statusF];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    };
    _seletIndexPath = indexPath;
    [self.navigationController pushViewController:commentInfo animated:YES];
}

//加载好友列表
-(void)loadMyAllFriends
{
    LogInUser *nowLoginUser = [LogInUser getCurrentLoginUser];
    if(nowLoginUser.rsMyFriends.count == 0 && nowLoginUser != nil){
        //获取好友列表
        [WeLianClient getFriendListWithID:nowLoginUser.uid
                                  Success:^(id resultInfo) {
                                      dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          NSArray *myFriends = [nowLoginUser getAllMyFriendUsers];
                                          //循环，删除本地数据库多余的缓存数据
                                          for (int i = 0; i < [myFriends count]; i++){
                                              MyFriendUser *myFriendUser = myFriends[i];
                                              //判断返回的数组是否包含
                                              BOOL isHave = [resultInfo bk_any:^BOOL(id obj) {
                                                  //判断是否包含对应的
                                                  return [[obj uid] integerValue] == [myFriendUser uid].integerValue;
                                              }];
                                              //删除新的好友本地数据库
                                              NewFriendUser *newFuser = [nowLoginUser getNewFriendUserWithUid:myFriendUser.uid];
                                              //本地不存在，不是好友关系
                                              if(!isHave){
                                                  if (newFuser) {
                                                      //更新好友请求列表数据为 添加
                                                      [newFuser updateOperateType:0];
                                                  }
                                                  
                                                  //如果uid大于100的为普通好友，刷新的时候可以删除本地，系统好友，保留
                                                  if(myFriendUser.uid.integerValue > 100){
                                                      //不包含，删除当前数据
                                                      //                    [myFriendUser MR_deleteEntityInContext:nowLoginUser.managedObjectContext];
                                                      //更新设置为不是我的好友
                                                      [myFriendUser updateIsNotMyFriend];
                                                  }
                                              }else{
                                                  //好友
                                                  if (newFuser) {
                                                      //更新好友请求列表数据为 添加
                                                      [newFuser updateOperateType:2];
                                                  }
                                              }
                                          }
                                          
                                          [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                                              NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@", @"isNow",@(YES)];
                                              LogInUser *loginUser = [LogInUser MR_findFirstWithPredicate:pre inContext:localContext];
                                              if (!loginUser) {
                                                  return ;
                                              }
                                              
                                              //循环添加数据库数据
                                              for (IBaseUserM *baseUser in resultInfo) {
                                                  baseUser.friendship = @(1);//设置为好友关系
                                                  
                                                  NSPredicate *pre = [NSPredicate predicateWithFormat:@"%K == %@ && %K == %@", @"rsLogInUser",loginUser,@"uid",baseUser.uid];
                                                  MyFriendUser *myFriend = [MyFriendUser MR_findFirstWithPredicate:pre inContext:localContext];
                                                  if (!myFriend) {
                                                      myFriend = [MyFriendUser MR_createEntityInContext:localContext];
                                                  }
                                                  myFriend.uid = baseUser.uid;
                                                  myFriend.name = baseUser.name;
                                                  myFriend.avatar = baseUser.avatar;
                                                  myFriend.company = baseUser.company;
                                                  myFriend.position = baseUser.position;
                                                  myFriend.investorauth = baseUser.investorauth;
                                                  myFriend.friendship = baseUser.friendship;
                                                  myFriend.checked = baseUser.checked;
                                                  myFriend.mobile = baseUser.mobile;
                                                  myFriend.cityname = baseUser.cityname;
                                                  myFriend.isMyFriend = @(YES);
                                                  [loginUser addRsMyFriendsObject:myFriend];
                                              }
                                              
                                          } completion:^(BOOL contextDidSave, NSError *error) {
                                              //通知刷新好友通知页面
                                              [KNSNotification postNotificationName:KNewFriendNotif object:self];
                                          }];
                                      });
                                  } Failed:^(NSError *error) {
//                                      [self.refreshControl endRefreshing];
//                                      [WLHUDView hiddenHud];
                                  }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    [mgr cancelAll];
    [mgr.imageCache clearMemory];
}

//获取活动城市列表
- (void)loadAcitvityCitys
{
    [WeLianClient getActiveCitiesSuccess:^(id resultInfo) {
        if ([resultInfo count] > 0) {
            NSArray *citys = [NSArray arrayWithArray:resultInfo];
            //写入到本地
            BOOL state = [citys writeToFile:[[ResManager documentPath] stringByAppendingString:@"/ActivityCitys.plist"] atomically:YES];
            if (state == YES) {
                DLog(@"getActiveCities write successfully");
            }else{
                DLog(@"getActiveCities fail to write");
            }
        }
    } Failed:^(NSError *error) {
        DLog(@"getActiveCities error:%@",error.description);
    }];
}

//获取默认刷选列表
- (void)loadCommonSelectInfos
{
    [WeLianClient getSelectInfoWithSuccess:^(id resultInfo) {
        NSArray *activecitys = resultInfo[@"activecity"];
        if (activecitys.count > 0) {
            //写入到本地
            BOOL state = [activecitys writeToFile:[[ResManager documentPath] stringByAppendingString:@"/ActivityCitys.plist"] atomically:YES];
            if (state == YES) {
                DLog(@"activecitys write successfully");
            }else{
                DLog(@"activecitys fail to write");
            }
            
            //删除本地数据库的缓存  //1：活动城市   2：项目城市
            NSArray *citys = [ICityModel objectsWithInfo:activecitys];
            if (citys.count > 0) {
                [CityInfo deleteAllCityInfosRealWithType:@(1)];
                for (ICityModel *iCityModel in citys) {
                    [CityInfo createCityInfoWith:iCityModel Type:@(1)];
                }
            }
        }
        
        NSArray *projectcitys = resultInfo[@"projectcity"];
        if (projectcitys.count > 0) {
            //写入到本地
            BOOL state = [projectcitys writeToFile:[[ResManager documentPath] stringByAppendingString:@"/ProjectCitys.plist"] atomically:YES];
            if (state == YES) {
                DLog(@"projectcitys write successfully");
            }else{
                DLog(@"projectcitys fail to write");
            }
            
            NSArray *citys = [ICityModel objectsWithInfo:projectcitys];
            if (citys.count > 0) {
                [CityInfo deleteAllCityInfosRealWithType:@(2)];
                for (ICityModel *iCityModel in citys) {
                    [CityInfo createCityInfoWith:iCityModel Type:@(2)];
                }
            }
        }
        
        NSArray *industrys = resultInfo[@"industry"];
        if (industrys.count > 0) {
            //写入到本地
            BOOL state = [industrys writeToFile:[[ResManager documentPath] stringByAppendingString:@"/Industrys.plist"] atomically:YES];
            if (state == YES) {
                DLog(@"projectcitys write successfully");
            }else{
                DLog(@"projectcitys fail to write");
            }
            
            NSArray *industryInfos = [IInvestIndustryModel objectsWithInfo:industrys];
            if (industryInfos.count > 0) {
                //删除本地的
                [InvestIndustry deleteAllInvestIndustrys];
                for (IInvestIndustryModel *iInvestIndustry in industryInfos) {
                    [InvestIndustry createInvestIndustryWith:iInvestIndustry];
                }
            }
        }
    } Failed:^(NSError *error) {
        DLog(@"getSelectInfo error:%@",error.localizedDescription);
    }];
}

#pragma mark - 加载缓存重新发送的动态
- (NSMutableArray *)getSendAgainStuatArray
{
    NSMutableArray *sendFrameArray = [NSMutableArray array];
    
    if (!_uid) {
        NSArray *arrr  = [[WLDataDBTool sharedService] getAllItemsFromTable:KSendAgainDataTableName];
        
        for (YTKKeyValueItem *aa in arrr) {
            WLStatusFrame *sf = [self relodStatusFrameWithDic:aa.itemObject withFidStr:aa.itemId];
            [sendFrameArray addObject:sf];
        }
    }
    
    return sendFrameArray;
}


#pragma mark - 重新发布动态
- (void)sendAgainStuat:(NSDictionary *)reqDataDic withFidStr:(NSString *)fidStr
{
    WLStatusFrame *newsf = [self relodStatusFrameWithDic:reqDataDic withFidStr:fidStr];
    [_dataArry insertObject:newsf atIndex:0];
    
    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self sendStuat:reqDataDic withIndexPath:indexPath];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    // 更新界面
    if (!_uid) {
        [self.homeView setHidden:_dataArry.count];
    }else if(_uid.integerValue == 0){
        [self.notDataView setHidden:_dataArry.count];
    }
    
}

- (WLStatusFrame *)relodStatusFrameWithDic:(NSDictionary *)reqDataDic withFidStr:(NSString *)fidStr
{
    WLStatusM *statusM = [WLStatusM objectWithDict:reqDataDic];
    WLStatusFrame *newsf = [[WLStatusFrame alloc] initWithWidth:[UIScreen mainScreen].bounds.size.width-60];
    statusM.sendId = fidStr;
    statusM.sendType = 1;
    statusM.type = @(101);
    IBaseUserM *meBasic =  [IBaseUserM getLoginUserBaseInfo];
    statusM.user = meBasic;
    newsf.status = statusM;
    return newsf;
}


- (void)sendStuat:(NSDictionary *)reqDataDic withIndexPath:(NSIndexPath *)indexPath
{
    WLStatusFrame *statusFrame = _dataArry[indexPath.row];
    WLStatusM *statusM = statusFrame.status;
    statusM.sendType = 2;
    statusFrame.status = statusM;
    [_dataArry replaceObjectAtIndex:indexPath.row withObject:statusFrame];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    NSArray *photosArray = statusM.photos;
    NSMutableDictionary *reqstDic = [NSMutableDictionary dictionaryWithDictionary:reqDataDic];
    WEAKSELF
    if (photosArray.count) {
        NSMutableArray *imageDataArray = [NSMutableArray arrayWithCapacity:photosArray.count];
        for (WLPhoto *photo in photosArray) {
            NSData *data = [[NSData data] initWithBase64EncodedString:photo.imageDataStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
            [imageDataArray addObject:data];
        }
        [[WeLianClient sharedClient] uploadImageWithImageData:imageDataArray Type:@"feed" FeedID:statusM.sendId  Success:^(id resultInfo) {
            DLog(@"%@",resultInfo);
            NSMutableArray *photoReqst = [NSMutableArray arrayWithCapacity:photosArray.count];
            NSArray *photoUrlArray = [IPhotoUp objectsWithInfo:resultInfo];
            for (IPhotoUp *photoUp in photoUrlArray) {
                [photoReqst addObject:@{@"photo":photoUp.photo}];
            }
            [reqstDic setObject:photoReqst forKey:@"photos"];

            [WeLianClient saveFeedWithParameterDic:reqstDic Success:^(id resultInfo) {
                [[WLDataDBTool sharedService] deleteObjectById:statusFrame.status.sendId fromTable:KSendAgainDataTableName];
                [weakSelf beginPullDownRefreshing];
            } Failed:^(NSError *error) {
                WLStatusM *statusM = statusFrame.status;
                statusM.sendType = 1;
                statusFrame.status = statusM;
                [_dataArry replaceObjectAtIndex:indexPath.row withObject:statusFrame];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [WLHUDView showErrorHUD:@"发布失败！"];
            }];
            
        } Failed:^(NSError *error) {
            
        }];
    }else{

        [WeLianClient saveFeedWithParameterDic:reqstDic Success:^(id resultInfo) {
            [[WLDataDBTool sharedService] deleteObjectById:statusFrame.status.sendId fromTable:KSendAgainDataTableName];
            [weakSelf beginPullDownRefreshing];
        } Failed:^(NSError *error) {
            WLStatusM *statusM = statusFrame.status;
            statusM.sendType = 1;
            statusFrame.status = statusM;
            [_dataArry replaceObjectAtIndex:indexPath.row withObject:statusFrame];
            [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [WLHUDView showErrorHUD:@"发布失败！"];
        }];
    }
    
    
   
//    [WLHttpTool addFeedParameterDic:reqDataDic success:^(id JSON) {
//        [[WLDataDBTool sharedService] deleteObjectById:statusFrame.status.sendId fromTable:KSendAgainDataTableName];
//        [weakSelf beginPullDownRefreshing];
//    } fail:^(NSError *error) {
//        
//        WLStatusM *statusM = statusFrame.status;
//        statusM.sendType = 1;
//        statusFrame.status = statusM;
//        [_dataArry replaceObjectAtIndex:indexPath.row withObject:statusFrame];
//        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [WLHUDView showErrorHUD:@"发布失败！"];
//    }];
}

@end
