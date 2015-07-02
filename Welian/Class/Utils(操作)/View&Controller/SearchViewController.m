//
//  SearchViewController.m
//  Welian
//
//  Created by weLian on 15/7/2.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "SearchViewController.h"
#import "UserInfoViewController.h"

#import "NewFriendViewCell.h"
#import "UIImage+ImageEffects.h"

@interface SearchViewController ()<UISearchBarDelegate>

@property (strong,nonatomic) UISearchBar *searchBar;
@property (strong,nonatomic) NSArray *datasource;

@end

@implementation SearchViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [_searchBar becomeFirstResponder];
//    self.tableView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
//    self.view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_searchBar becomeFirstResponder];
//    self.tableView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
//    self.view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_searchBar resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor clearColor];
    
//    self.tableView.backgroundColor = [UIColor clearColor];
    //隐藏tableiView分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //搜索栏
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.placeholder = @"手机号/姓名";
    searchBar.delegate = self;
    searchBar.backgroundImage = [UIImage resizedImage:@"searchbar_bg"];
    searchBar.showsCancelButton = YES;
    searchBar.returnKeyType = UIReturnKeySearch;
    [searchBar sizeToFit];
    [self.navigationController.navigationBar addSubview:searchBar];
    self.searchBar = searchBar;
    
//    UITapGestureRecognizer *tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
//        
//    }];
//    [self.view addGestureRecognizer:tap];
}

//===============================================
#pragma mark -
#pragma mark - tableView相关代理
//===============================================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //微信联系人
    static NSString *cellIdentifier = @"AddFriendTypeListCellIdentifier";
    
    NewFriendViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[NewFriendViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //搜索的好友
    cell.userInfoModel = _datasource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    IBaseUserM *mode = _datasource[indexPath.row];
    UserInfoViewController *userInfoVC = [[UserInfoViewController alloc] initWithBaseUserM:(IBaseUserM *)mode OperateType:nil HidRightBtn:NO];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_datasource.count > 0) {
        IBaseUserM *mode = _datasource[indexPath.row];
        return [NewFriendViewCell configureWithName:mode.name message:[NSString stringWithFormat:@"%@ %@",mode.company,mode.position]];
    }else{
        return 60.f;
    }
}


#pragma mark - UISearchBar Delegate
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [WeLianClient searchUserWithKeyword:searchBar.text
                                   Page:@(1)
                                   Size:@(1000)
                                Success:^(id resultInfo) {
                                    self.datasource = resultInfo;
                                    if (!_datasource.count) {
                                        [WLHUDView showCustomHUD:@"暂无该好友" imageview:nil];
                                    }
                                    [self.tableView reloadData];
                                } Failed:^(NSError *error) {
                                    
                                }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

@end
