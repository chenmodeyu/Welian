//
//  UserInfoBasicVC.m
//  weLian
//
//  Created by dong on 14/10/20.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "UserInfoBasicVC.h"
#import "InvestAuthModel.h"
#import "HaderInfoCell.h"
#import "SameFriendsCell.h"
#import "StaurCell.h"
#import "SchoolModel.h"
#import "CompanyModel.h"
#import "UIImage+ImageEffects.h"
#import "HomeController.h"
#import "ListdaController.h"

@interface UserInfoBasicVC () <UIAlertViewDelegate>
{
    UserInfoModel *_userMode;
    NSMutableDictionary *_dataDicM;
    NSMutableArray *_sameFriendArry;
}

@property (nonatomic,strong) UIView *addFriendView;

@property (nonatomic, strong) UIView *sendView;

@end

static NSString *sameFriendcellid = @"sameFriendcellid";
static NSString *staurCellid = @"staurCellid";

@implementation UserInfoBasicVC

- (UIView*)sendView
{
    if (_sendView == nil) {
        _sendView = [[UIView alloc] init];
        [_sendView setBounds:CGRectMake(0, 0, 0, 40)];
        // 3.要在tableView底部添加一个按钮
        UIButton *logout = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [logout setBackgroundImage:[UIImage resizedImage:@"bluebutton"] forState:UIControlStateNormal];
        [logout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [logout setBackgroundImage:[UIImage resizedImage:@"bluebuttton_pressed"] forState:UIControlStateHighlighted];
        logout.frame = CGRectMake(20, 0, 280, 40);
        // 4.设置按钮文字
        [logout setTitle:@"发送消息" forState:UIControlStateNormal];
        [_sendView addSubview:logout];
    }
    return _sendView;
}


- (UIView*)addFriendView
{
    if (_addFriendView == nil) {
        _addFriendView = [[UIView alloc] init];
        [_addFriendView setBounds:CGRectMake(0, 0, 0, 40)];
        // 3.要在tableView底部添加一个按钮
        UIButton *logout = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [logout setBackgroundImage:[UIImage resizedImage:@"yellowbutton"] forState:UIControlStateNormal];
        [logout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [logout setBackgroundImage:[UIImage resizedImage:@"yellowbutton_pressed"] forState:UIControlStateHighlighted];
        logout.frame = CGRectMake(20, 0, 280, 40);
        [logout addTarget:self action:@selector(requestFriend) forControlEvents:UIControlEventTouchUpInside];
        // 4.设置按钮文字
        [logout setTitle:@"+加为好友" forState:UIControlStateNormal];
        [_addFriendView addSubview:logout];
    }
    return _addFriendView;
}

- (void)requestFriend
{
    UserInfoModel *mode = [[UserInfoTool sharedUserInfoTool] getUserInfoModel];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友验证" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alert textFieldAtIndex:0] setText:[NSString stringWithFormat:@"我是%@",mode.name]];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [WLHttpTool requestFriendParameterDic:@{@"fid":_userMode.uid,@"message":[alertView textFieldAtIndex:0].text} success:^(id JSON) {
            
        } fail:^(NSError *error) {
            
        }];
    }
}


- (instancetype)initWithStyle:(UITableViewStyle)style andUsermode:(UserInfoModel *)usermode
{
    _userMode = usermode;
    _dataDicM = [NSMutableDictionary dictionary];
    self = [super initWithStyle:style];
    if (self) {
        [self.tableView setSectionHeaderHeight:0.0];
        
        UserInfoModel *mode = [[UserInfoTool sharedUserInfoTool] getUserInfoModel];
        [WLHttpTool loadUserInfoParameterDic:@{@"uid":_userMode.uid} success:^(id JSON) {
            
            [WLHttpTool loadSameFriendParameterDic:@{@"uid":mode.uid,@"fid":_userMode.uid,@"size":@(4)} success:^(id JSON) {
                _sameFriendArry = [JSON objectForKey:@"samefriends"];
                [self.tableView reloadData];
            } fail:^(NSError *error) {
                
            }];

            _dataDicM = JSON;
            _userMode = [_dataDicM objectForKey:@"profile"];
            if ([_userMode.friendship integerValue]==1) {
                [self.tableView setTableFooterView:self.sendView];
            }else {
                [self.tableView setTableFooterView:self.addFriendView];
            }
            [self.tableView reloadData];
        } fail:^(NSError *error) {
            
        }];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [self.tableView registerNib:[UINib nibWithNibName:@"SameFriendsCell" bundle:nil] forCellReuseIdentifier:sameFriendcellid];
        [self.tableView registerNib:[UINib nibWithNibName:@"StaurCell" bundle:nil] forCellReuseIdentifier:staurCellid];
        [self.tableView setBackgroundColor:IWGlobalBg];
        [self.tableView setSeparatorColor:WLLineColor];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSInteger i = 2;
    InvestAuthModel *inve = [_dataDicM objectForKey:@"investor"];
    if (inve.auth==InvestAuthTypeInvestor) {
        i+=1;
    }
    if (section == i) {
        return 15;
    }
    return 0;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"个人信息"];
    
}




- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger n = 3;
    InvestAuthModel *inve = [_dataDicM objectForKey:@"investor"];
    if (inve.auth==InvestAuthTypeInvestor) {
        n+=1;
    }
    return n;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if(section ==1){
        NSInteger a = 1;
        if (_userMode.provincename||_userMode.cityname) {
            a+=1;
        }
        
        if (_sameFriendArry.count) {
            a+=1;
        }
        return a;
    }else if (section == 2){
        return 2;
    }else if (section == 3){
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *yibancellid = @"yibancellid";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:yibancellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:yibancellid];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    WLStatusM *statMode = [_dataDicM objectForKey:@"feed"];
    NSArray *userschool = [_dataDicM objectForKey:@"userschool"];
    NSArray *usercompany = [_dataDicM objectForKey:@"usercompany"];
    
    if (indexPath.section==0) {
        HaderInfoCell *hacell = [HaderInfoCell cellWithTableView:self.tableView];
        [hacell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [hacell setUserM:_userMode];
        return hacell;
    }else if (indexPath.section==1){
        
        if (indexPath.row==0) {
            if (_userMode.provincename||_userMode.cityname) {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell.textLabel setText:@"所在地区"];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@   %@",_userMode.provincename,_userMode.cityname]];
            }else if(_sameFriendArry.count){
                SameFriendsCell *samcell = [tableView dequeueReusableCellWithIdentifier:sameFriendcellid];
                
                return samcell;
            }else{
                StaurCell *staucell = [tableView dequeueReusableCellWithIdentifier:staurCellid];
                [staucell setStatusM:statMode];
                return staucell;
            }
        }else if (indexPath.row==1){
            if ((_userMode.provincename||_userMode.cityname)&&_sameFriendArry.count) {
                SameFriendsCell *samcell = [tableView dequeueReusableCellWithIdentifier:sameFriendcellid];
                
                return samcell;
            }else{
                StaurCell *staucell = [tableView dequeueReusableCellWithIdentifier:staurCellid];
                [staucell setStatusM:statMode];
                return staucell;
            }
            
        }else if (indexPath.row==2){
            StaurCell *staucell = [tableView dequeueReusableCellWithIdentifier:staurCellid];
            [staucell setStatusM:statMode];
            return staucell;
        }
    }else if (indexPath.section==2){
        if (indexPath.row==0) {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell.textLabel setText:@"教育背景"];
            
            if (userschool.count) {
                SchoolModel *schoolM = userschool.firstObject;
                [cell.detailTextLabel setText:schoolM.schoolname];
            }else{
                [cell.detailTextLabel setText:@"暂无"];
            
            }
            
        }else if (indexPath.row==1){
            [cell.textLabel setText:@"工作经历"];
            if (usercompany.count) {
                CompanyModel *companM = usercompany.firstObject;
                [cell.detailTextLabel setText:companM.companyname];
            }else{
                [cell.detailTextLabel setText:@"暂无"];
            }
        }
    }else if (indexPath.section ==3){
        InvestAuthModel *inve = [_dataDicM objectForKey:@"investor"];
        if (inve.auth==InvestAuthTypeInvestor) {
            [cell.textLabel setText:@"投资案例"];
            [cell.detailTextLabel setText:inve.items];
        }
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 90.0;
    }else if(indexPath.section==1){
        if (indexPath.row==0) {
            if (_userMode.provincename||_userMode.cityname) {
                return 44.0;
            }else if (_sameFriendArry.count){
                return 60.0;
            }else{
                return 60.0;
            }
        }else {
            return 60.0;
        }
    }else {
        return 44.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *celltext = cell.textLabel.text;
    if ([celltext isEqualToString:@"教育背景"]) {
        NSArray *userschool = [_dataDicM objectForKey:@"userschool"];

        ListdaController *schooL = [[ListdaController alloc] initWithStyle:UITableViewStyleGrouped WithList:userschool andType:@"1"];

        [self.navigationController pushViewController:schooL animated:YES];
    }else if ([celltext isEqualToString:@"工作经历"]){
        NSArray *usercompany = [_dataDicM objectForKey:@"usercompany"];

        ListdaController *workVC = [[ListdaController alloc] initWithStyle:UITableViewStyleGrouped WithList:usercompany andType:@"2"];
        [self.navigationController pushViewController:workVC animated:YES];
    }else if([celltext isEqualToString:@"投资案例"]){
        InvestAuthModel *inves = [_dataDicM objectForKey:@"investor"];
//        NSArray *items = [inves.items componentsSeparatedByString:@","];
        ListdaController *investVC = [[ListdaController alloc] initWithStyle:UITableViewStyleGrouped WithList:inves.itemsArray andType:@"3"];
        [self.navigationController pushViewController:investVC animated:YES];
    }else{
        if (indexPath.section==1) {
            if (indexPath.row==0) {
                if (_userMode.provincename||_userMode.cityname) {
                    
                }else if (_sameFriendArry.count){
                    
                }else{
                    [self.navigationController pushViewController:[[HomeController alloc] initWithStyle:UITableViewStylePlain anduid:_userMode.uid]animated:YES];
                }
            }else if (indexPath.row==1){
                if ((_userMode.provincename||_userMode.cityname)&&_sameFriendArry.count) {
                    
                }else{
                    [self.navigationController pushViewController:[[HomeController alloc] initWithStyle:UITableViewStylePlain anduid:_userMode.uid]animated:YES];
                }
            }else if (indexPath.row==2){
                [self.navigationController pushViewController:[[HomeController alloc] initWithStyle:UITableViewStylePlain anduid:_userMode.uid]animated:YES];
            }
        }
    
    }
    
}

@end
