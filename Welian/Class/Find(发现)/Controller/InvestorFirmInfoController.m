//
//  InvestorFirmInfoController.m
//  Welian
//
//  Created by dong on 15/5/27.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "InvestorFirmInfoController.h"
#import "InvestorCell.h"
#import "FirmInfoHeaderView.h"

@interface InvestorFirmInfoController ()

@end

static NSString *usercellid = @"investorcellid";

@implementation InvestorFirmInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *tableH = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, 150)];
    [tableH setBackgroundColor:[UIColor blueColor]];
    [self.tableView setTableHeaderView:tableH];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SuperSize.width, 50)];
    [headerV setBackgroundColor:[UIColor orangeColor]];
    return headerV;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:usercellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:usercellid];
    }
    [cell.textLabel setText:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    return cell;
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
