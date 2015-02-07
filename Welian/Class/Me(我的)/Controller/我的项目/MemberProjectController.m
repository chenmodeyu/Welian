//
//  MemberProjectController.m
//  Welian
//
//  Created by dong on 15/1/30.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "MemberProjectController.h"
#import "FinancingProjectController.h"
#import "FriendCell.h"
#import "ChineseString.h"

@interface MemberProjectController () <UITableViewDataSource, UITableViewDelegate>
{
    BOOL _isEdit;
    IProjectDetailInfo *_projectModel;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *allArray;
@end

static NSString *fridcellid = @"fridcellid";
@implementation MemberProjectController

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView setDelegate: self];
        [_tableView setDataSource:self];
        [_tableView registerNib:[UINib nibWithNibName:@"FriendCell" bundle:nil] forCellReuseIdentifier:fridcellid];
        [_tableView setSectionFooterHeight:0.01];
        [_tableView setEditing:YES];
    }
    return _tableView;
}

- (instancetype)initIsEdit:(BOOL)isEdit withData:(IProjectDetailInfo *)projectModel
{
    self = [super init];
    if (self) {
        _isEdit = isEdit;
        _projectModel = projectModel;
        [self.view addSubview:self.tableView];
        if (isEdit) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(financingProject)];
        }else{
            [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, 90)]];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStyleBordered target:self action:@selector(financingProject)];
        }
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"团队成员"];
    self.selectArray = [NSMutableArray array];
    [WLHttpTool loadFriendWithSQL:YES ParameterDic:nil success:^(id JSON) {
        IBaseUserM *meUserM = [[IBaseUserM alloc] init];
        LogInUser *logUser = [LogInUser getCurrentLoginUser];
        [meUserM setName:logUser.name];
        [meUserM setUid:logUser.uid];
        meUserM.friendship = logUser.friendship;
        meUserM.avatar = logUser.avatar;
        meUserM.company = logUser.company;
        meUserM.position = logUser.position;
        self.allArray = [JSON objectForKey:@"array"];
        [self.allArray insertObject:@{@"key":@"我",@"userF":@[meUserM]} atIndex:0];
        [self.tableView reloadData];
        if (_isEdit) {
            [WLHttpTool getProjectMembersParameterDic:@{@"pid":_projectModel.pid} success:^(id JSON) {
                self.selectArray = [NSMutableArray arrayWithArray:[IBaseUserM objectsWithInfo:JSON]];
                NSMutableArray *seleIndexPath = [NSMutableArray arrayWithCapacity:self.selectArray.count];
                for (IBaseUserM *selectUserM in self.selectArray) {
                    for (NSInteger i = 0; i<self.allArray.count; i++) {
                        NSDictionary *userDic = self.allArray[i];
                        NSArray *userArray = [userDic objectForKey:@"userF"];
                        for (NSInteger j = 0; j<userArray.count; j++) {
                            IBaseUserM *IBuserM = userArray[j];
                            if ([selectUserM.uid.stringValue isEqualToString:IBuserM.uid.stringValue]) {
                                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:j inSection:i];
                                [seleIndexPath addObject:indexPath];
                            }
                        }
                    }
                }
                
                for (NSIndexPath *indexpath in seleIndexPath) {
                    [self.tableView selectRowAtIndexPath:indexpath animated:NO scrollPosition:UITableViewScrollPositionBottom];
                }
            } fail:^(NSError *error) {
                
            }];

        }else{
            // 默认选中自己
            NSIndexPath *ip=[NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionBottom];
            [self.selectArray addObject:meUserM];
        }
    } fail:^(NSError *error) {
        
    }];
}

#pragma mark - tableView代理
- (NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:self.allArray.count];
    for (NSDictionary *dickey in self.allArray) {
        [arrayM addObject:[dickey objectForKey:@"key"]];
    }
    return arrayM;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return self.allArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSDictionary *userF = self.allArray[section];
    return [[userF objectForKey:@"userF"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dick = self.allArray[section];
    return [dick objectForKey:@"key"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCell *fcell = [tableView dequeueReusableCellWithIdentifier:fridcellid];
    NSDictionary *usersDic = self.allArray[indexPath.section];
    NSArray *modear = usersDic[@"userF"];
    IBaseUserM *modeIM = modear[indexPath.row];
    [fcell setUserMode:modeIM];
    return fcell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

//添加一项
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
        NSDictionary *usersDic = self.allArray[indexPath.section];
        NSArray *modear = usersDic[@"userF"];
        IBaseUserM *modeIM = modear[indexPath.row];
        [self.selectArray addObject:modeIM];
}

//取消一项
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSDictionary *usersDic = self.allArray[indexPath.section];
    NSArray *modear = usersDic[@"userF"];
    IBaseUserM *modeIM = modear[indexPath.row];
    [self.selectArray removeObject:modeIM];
}


#pragma mrak - 下一步融资
- (void)financingProject
{
    NSMutableDictionary *ProjectMemberDic = [NSMutableDictionary dictionary];
    [ProjectMemberDic setObject:_projectModel.pid forKey:@"pid"];
    NSMutableArray *members = [NSMutableArray array];
    for (IBaseUserM *friendM in self.selectArray) {
        [members addObject:@{@"uid":friendM.uid}];
    }
    [ProjectMemberDic setObject:members forKey:@"members"];
    [WLHttpTool addProjectMembersParameterDic:ProjectMemberDic success:^(id JSON) {
        if (_isEdit) {
            if (self.projectDataBlock) {
                self.projectDataBlock(_projectModel);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [_projectModel setMembercount:@(self.selectArray.count)];
            FinancingProjectController *financingVC = [[FinancingProjectController alloc] initIsEdit:NO withData:_projectModel];
            [self.navigationController pushViewController:financingVC animated:YES];
        }
        
    } fail:^(NSError *error) {
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
