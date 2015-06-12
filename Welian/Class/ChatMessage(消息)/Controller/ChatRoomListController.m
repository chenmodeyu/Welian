//
//  ChatRoomListController.m
//  Welian
//
//  Created by dong on 15/6/11.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ChatRoomListController.h"

#define KPasswordH 50

@interface ChatRoomListController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation ChatRoomListController

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, SuperSize.height-KPasswordH) style:UITableViewStylePlain];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setTableFooterView:[UIView new]];
        [_tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"聊天室";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];
    UIView *dfasd = [[UIView alloc] initWithFrame:CGRectMake(0, SuperSize.height-KPasswordH, SuperSize.width, KPasswordH)];
    UITextField *textF = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, SuperSize.width-30-40, KPasswordH-10)];
    [textF setBackgroundColor:[UIColor whiteColor]];
    textF.borderStyle = UITextBorderStyleRoundedRect;
    [dfasd addSubview:textF];
    [dfasd setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:dfasd];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
