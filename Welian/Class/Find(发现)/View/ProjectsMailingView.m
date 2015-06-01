//
//  ProjectsMailingView.m
//  Welian
//
//  Created by dong on 15/5/25.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectsMailingView.h"
#import "UIImage+ImageEffects.h"
#import "ProjectBPCell.h"

@interface ProjectsMailingView () <UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_dataArray;
}
@property (strong, nonatomic) UIView *tapGestureView;
@property (strong, nonatomic) NSIndexPath *seletIndex;
@property (nonatomic, strong) UIButton *toudiBut;
@end

static NSString *projectBPcellid = @"projectBPcellid";

@implementation ProjectsMailingView

- (instancetype)initWithFrame:(CGRect)frame andProjects:(NSArray *)projects
{
    self = [super initWithFrame:frame];
    if (self) {
        _dataArray = projects;
        self.tapGestureView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.tapGestureView];
        [self.tapGestureView setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.7]];
        
        UIView *backGuView = [[UIView alloc] initWithFrame:CGRectMake(30, 100, SuperSize.width-60, 280)];
        [backGuView setBackgroundColor:[UIColor whiteColor]];
        backGuView.layer.cornerRadius = 8;
        backGuView.centerY = self.centerY;
        [self addSubview:backGuView];
        
        UILabel *titiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, backGuView.width, 20)];
        [titiLabel setText:@"投递项目"];
        [titiLabel setTextAlignment:NSTextAlignmentCenter];
        [backGuView addSubview:titiLabel];
        
        UILabel *remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titiLabel.bottom, backGuView.width, 16)];
        [remarkLabel setTextAlignment:NSTextAlignmentCenter];
        [remarkLabel setText:@"注：BP请到my.welian.com上传"];
        [remarkLabel setFont:WLFONT(15)];
        [remarkLabel setTextColor:WLRGB(125, 125, 125)];
        [backGuView addSubview:remarkLabel];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, remarkLabel.bottom+5, backGuView.width, 0.5)];
        [topLine setBackgroundColor:WLRGB(125, 125, 125)];
        [backGuView addSubview:topLine];
        
        UIButton *cancelBut = [[UIButton alloc] initWithFrame:CGRectMake(0, backGuView.height-50, backGuView.width*0.5-0.5, 50)];
        [cancelBut setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBut setTitleColor:self.tintColor forState:UIControlStateNormal];
        [cancelBut addTarget:self action:@selector(cancelSelfVC) forControlEvents:UIControlEventTouchUpInside];
        [backGuView addSubview:cancelBut];
        
        UIButton *toudiBut = [[UIButton alloc] initWithFrame:CGRectMake(backGuView.width*0.5, backGuView.height-50, backGuView.width*0.5, 50)];
        [toudiBut setTitleColor:self.tintColor forState:UIControlStateNormal];
        [toudiBut setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [toudiBut setTitle:@"投递" forState:UIControlStateNormal];
        [toudiBut addTarget:self action:@selector(mailingInvestorHttpClick) forControlEvents:UIControlEventTouchUpInside];
        [toudiBut setEnabled:NO];
        [backGuView addSubview:toudiBut];
        self.toudiBut = toudiBut;
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, cancelBut.top, backGuView.width, 0.5)];
        [bottomLine setBackgroundColor:WLRGB(125, 125, 125)];
        [backGuView addSubview:bottomLine];
        
        UIView *erectLine = [[UIView alloc] initWithFrame:CGRectMake(cancelBut.right, cancelBut.top, 0.5, 50)];
        [erectLine setBackgroundColor:WLRGB(125, 125, 125)];
        [backGuView addSubview:erectLine];
        
        CGRect tableFrame = CGRectMake(0, topLine.bottom, backGuView.width, backGuView.height-topLine.bottom-50);
        if (_dataArray.count) {
            UITableView *tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
            [tableView setDelegate:self];
            [tableView setDataSource:self];
//            [tableView setEditing:YES];
            [tableView setTableFooterView:[UIView new]];
            [tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
            [tableView registerNib:[UINib nibWithNibName:@"ProjectBPCell" bundle:nil] forCellReuseIdentifier:projectBPcellid];
            [backGuView addSubview:tableView];
        }else{
            UIView *noProject = [[UIView alloc] initWithFrame:tableFrame];
            [noProject setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
            [backGuView addSubview:noProject];
            UILabel *noLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, noProject.width, 20)];
            [noLabel setText:@"还没有项目哦~"];
            [noLabel setFont:WLFONT(15)];
            [noLabel setTextAlignment:NSTextAlignmentCenter];
            [noLabel setTextColor:WLRGB(125, 125, 125)];
            noLabel.centerY = noProject.centery-50;
            [noProject addSubview:noLabel];
            
            UIButton *addProjectBut = [UIButton buttonWithType:UIButtonTypeCustom];
            [addProjectBut setFrame:CGRectMake(58, noLabel.bottom+10, noProject.width-2*58, 40)];
            [addProjectBut setTitle:@"创建项目" forState:UIControlStateNormal];
            [addProjectBut setImage:[UIImage imageNamed:@"me_button_add"] forState:UIControlStateNormal];
            [addProjectBut setBackgroundImage:[UIImage resizedImage:@"login_my_button"] forState:UIControlStateNormal];
            [addProjectBut setBackgroundImage:[UIImage resizedImage:@"login_my_button_pre"] forState:UIControlStateHighlighted];
            [addProjectBut addTarget:self action:@selector(addNewProjectClick) forControlEvents:UIControlEventTouchUpInside];
            [noProject addSubview:addProjectBut];
        }
    }
    return self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectBPCell *cell = [tableView dequeueReusableCellWithIdentifier:projectBPcellid];
    ProjectTouDiModel *projectM = _dataArray[indexPath.row];
    [cell.projectNameLabel setText:projectM.name];
    [cell.bPNameLabel setText:projectM.notes];
    cell.userInteractionEnabled = YES;
    //  0,可以投递，1没bp，2 已投递
    if (projectM.state&&projectM.state.integerValue !=0) {
        cell.userInteractionEnabled = NO;
//        [cell.selectBut setEnabled:NO];
    }else if(self.seletIndex == indexPath){
        [cell.selectBut setSelected:YES];
    }else{
        [cell.selectBut setSelected:NO];
    }
    [cell.selectBut setEnabled:cell.userInteractionEnabled];
    return cell;
}

//添加一项
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectTouDiModel *projectM = _dataArray[indexPath.row];
    if (projectM.state &&projectM.state.integerValue!=0) {
        return;
    }
    ProjectBPCell *cell = (ProjectBPCell *)[tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:self.seletIndex animated:NO];
    if (indexPath == self.seletIndex) {
        [cell.selectBut setSelected:NO];
        self.seletIndex = nil;
        [self.toudiBut setEnabled:NO];
    }else{
        [cell.selectBut setSelected:YES];
        self.seletIndex = indexPath;
        [self.toudiBut setEnabled:YES];
    }
}

////取消一项
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectBPCell *cell = (ProjectBPCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.selectBut setSelected:NO];
}

// 投递项目
- (void)mailingInvestorHttpClick
{
    if (self.mailingProBlock) {
        if (self.seletIndex) {
            ProjectTouDiModel *projectM = _dataArray[self.seletIndex.row];
            self.mailingProBlock(projectM);
        }
    }
}

// 创建项目
- (void)addNewProjectClick
{
    if (self.addProjectBlock) {
        self.addProjectBlock();
    }
    [self cancelSelfVC];
}


- (void)cancelSelfVC
{
    [self removeFromSuperview];
}


@end
