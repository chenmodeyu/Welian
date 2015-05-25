//
//  ProjectsMailingView.m
//  Welian
//
//  Created by dong on 15/5/25.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectsMailingView.h"

@interface ProjectsMailingView () <UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UIView *tapGestureView;

@property (strong, nonatomic) NSIndexPath *seletIndex;

@end

@implementation ProjectsMailingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tapGestureView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.tapGestureView];
        [self.tapGestureView setBackgroundColor:[UIColor colorWithWhite:0.3 alpha:0.7]];
        
        UIView *backGuView = [[UIView alloc] initWithFrame:CGRectMake(30, 100, SuperSize.width-60, SuperSize.height-200)];
        [backGuView setBackgroundColor:[UIColor whiteColor]];
        backGuView.layer.cornerRadius = 8;
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
        [toudiBut setTitle:@"投递" forState:UIControlStateNormal];
        [backGuView addSubview:toudiBut];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, cancelBut.top, backGuView.width, 0.5)];
        [bottomLine setBackgroundColor:WLRGB(125, 125, 125)];
        [backGuView addSubview:bottomLine];
        
        UIView *erectLine = [[UIView alloc] initWithFrame:CGRectMake(cancelBut.right, cancelBut.top, 0.5, 50)];
        [erectLine setBackgroundColor:WLRGB(125, 125, 125)];
        [backGuView addSubview:erectLine];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topLine.bottom, backGuView.width, backGuView.height-topLine.bottom-50) style:UITableViewStylePlain];
        [tableView setDelegate:self];
        [tableView setDataSource:self];
        [tableView setEditing:YES];
        [tableView setTableFooterView:[UIView new]];
        [tableView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [backGuView addSubview:tableView];
        
    }
    return self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    }
    return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==1) {
        return UITableViewCellEditingStyleNone;
    }else{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }
}

//添加一项
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:self.seletIndex animated:NO];
    
    self.seletIndex = indexPath;
    
    DLog(@"添加一项");
   
}

//取消一项
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    DLog(@"取消一项");

}



- (void)cancelSelfVC
{
    [self removeFromSuperview];
}


@end
