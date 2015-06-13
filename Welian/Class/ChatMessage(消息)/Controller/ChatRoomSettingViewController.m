//
//  ChatRoomSettingViewController.m
//  Welian
//
//  Created by weLian on 15/6/13.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ChatRoomSettingViewController.h"

#import "YUDatePicker.h"
#import "WLTextField.h"
#import "BaseTableViewCell.h"

#define kTableViewCellHeight 50.f
#define kTableHeaderViewHeight 213.f

@interface ChatRoomSettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong,nonatomic) YUDatePicker *datePicker;
@property (assign,nonatomic) UITableView *tableView;
@property (strong,nonatomic) NSArray *datasource;
@property (assign,nonatomic) ChatRoomSetType roomSetType;
@property (assign,nonatomic) NSInteger selectType;
@property (assign,nonatomic) UILabel *noteLabel2;
@property (assign,nonatomic) UISegmentedControl *segmentedControl;
@property (strong,nonatomic) NSString *startTime;
@property (strong,nonatomic) NSString *endTime;
@property (strong,nonatomic) NSIndexPath *selectIndexPath;

@end

@implementation ChatRoomSettingViewController

- (YUDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[YUDatePicker alloc] init];
        _datePicker.datePickerMode = UIYUDatePickerModeDateYYYYMMDDHHmm;
        
        NSDate* minDate = [NSDate date];
        //    NSDate* maxDate = [minDate dateByAddingYears:100];//[NSDate dateWithTimeIntervalSince1970:10];
        _datePicker.minimumDate = minDate;
        //    datePicker.maximumDate = minDate;
        _datePicker.date = minDate; //默认的日期
        _datePicker.showToolbar = YES;
        
        [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    WEAKSELF
    [_datePicker setDoneSelectDateBlock:^(BOOL isFromDone,NSString *dateStr){
        DLog(@"setDoneSelectDateBlock ==%@ ",dateStr);
        weakSelf.tableView.frame = CGRectMake(0, 0, weakSelf.view.width, weakSelf.view.height);
        if (isFromDone) {
            [weakSelf updateSelectDateInfo:dateStr];
        }
    }];
    return _datePicker;
}

- (NSString *)title
{
    switch (_roomSetType) {
        case ChatRoomSetTypeCreate:
            return @"聊天室创建";
            break;
        case ChatRoomSetTypeChange:
            return @"设置";
            break;
        default:
            return @"";
            break;
    }
}

- (instancetype)initWithRoomType:(ChatRoomSetType)roomSetType
{
    self = [super init];
    if (self) {
        self.roomSetType = roomSetType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *rightTitle = @"";
    switch (_roomSetType) {
        case ChatRoomSetTypeCreate:
            rightTitle = @"创建";
            break;
        case ChatRoomSetTypeChange:
            rightTitle = @"保存";
            break;
        default:
            break;
    }
    //添加创建活动按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightTitle
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(rightBarButtonItemClicked)];
    
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) style:UITableViewStylePlain];
    tableView.backgroundColor = RGB(246.f, 247.f, 248.f);
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    //头部
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, kTableHeaderViewHeight)];
    headerView.backgroundColor = [UIColor clearColor];
    
    WLTextField *nameTF = [[WLTextField alloc] initWithFrame:Rect(0, 13.f, headerView.width, 44.f)];
    nameTF.backgroundColor = [UIColor whiteColor];
    nameTF.isToBounds = YES;//圆角
    nameTF.font = kNormal14Font;
    nameTF.textColor = kTitleNormalTextColor;
    nameTF.placeholder = @"聊天室名称，10个字以内";
    nameTF.layer.borderColorFromUIColor = kNormalLineColor;
    nameTF.layer.borderWidths = @"{0.8f,0,0.4,0}";
    [headerView addSubview:nameTF];
    //    [roomIdTF setDebug:YES];
    
    //口令
    WLTextField *passWdTF = [[WLTextField alloc] initWithFrame:Rect(0, nameTF.bottom, headerView.width, 44.f)];
    passWdTF.backgroundColor = [UIColor whiteColor];
    passWdTF.font = kNormal14Font;
    passWdTF.textColor = kTitleNormalTextColor;
    passWdTF.placeholder = @"口令，10个字以内";
    passWdTF.layer.borderColorFromUIColor = kNormalLineColor;
    passWdTF.layer.borderWidths = @"{0.4f,0,0.8f,0}";
    [headerView addSubview:passWdTF];

    //告示1
    UILabel *noteLabel1 = [[UILabel alloc] init];
    noteLabel1.backgroundColor = [UIColor clearColor];
    noteLabel1.font = kNormal12Font;
    noteLabel1.textColor = kNormalTextColor;
    noteLabel1.text = @"进入聊天室需要口令，也可以用口令快速进入聊天室";
    [noteLabel1 sizeToFit];
    noteLabel1.left = 15.f;
    noteLabel1.top = passWdTF.bottom + 5.f;
    [headerView addSubview:noteLabel1];
    
    //切换按钮
    //添加title内容
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"不限制时间",@"限制时间"]];
    segmentedControl.frame = CGRectMake(20.f, noteLabel1.bottom + 15.f, headerView.width - 40.f, 30.f);
    [segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    //设置默认选择的内容
    [segmentedControl setSelectedSegmentIndex:0];
    [headerView addSubview:segmentedControl];
    self.segmentedControl = segmentedControl;
    
    //告示2
    UILabel *noteLabel2 = [[UILabel alloc] init];
    noteLabel2.backgroundColor = [UIColor clearColor];
    noteLabel2.font = kNormal12Font;
    noteLabel2.textColor = kNormalTextColor;
//    noteLabel2.text = @"到开始时间之后，聊天室才会开启；过了结束时间，聊天室自动销毁";
    noteLabel2.numberOfLines = 0.f;
//    noteLabel2.width = headerView.width - 30.f;
//    [noteLabel2 sizeToFit];
//    noteLabel2.left = 15.f;
//    noteLabel2.top = segmentedControl.bottom + 5.f;
    [headerView addSubview:noteLabel2];
    self.noteLabel2 = noteLabel2;
    
    tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 50.f)];
    footerView.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = footerView;
    
    self.selectType = 0;
    [self checkDateTypeInfo];
}

#pragma mark - private
- (void)rightBarButtonItemClicked
{

}

- (void)dateChanged:(id)sender{
    YUDatePicker* control = (YUDatePicker*)sender;
    //    NSDate *_date = control.date;
    /*添加你自己响应代码*/
    //    NSLog(@"date ==%@ ",[XYNSDate dateToString:_date]);
    NSLog(@"date ==%@ ",control.dateStr);
    [self updateSelectDateInfo:control.dateStr];
//    txtField.text = control.dateStr;
}

- (void)updateSelectDateInfo:(NSString *)dateStr
{
    if (_selectIndexPath.row == 0) {
        _startTime = dateStr;
    }else{
        _endTime = dateStr;
    }
    [_tableView reloadRowsAtIndexPaths:@[_selectIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)segmentedControlChanged:(UISegmentedControl *)sender
{
    DLog(@"segmentedControlChanged-->%d",sender.selectedSegmentIndex);
    self.selectType = sender.selectedSegmentIndex;
    [_tableView reloadData];
    [self checkDateTypeInfo];
}

- (void)checkDateTypeInfo
{
    _noteLabel2.text = _selectType == 0 ? @"没有时间限制，聊天室将会一直存在" : @"到开始时间之后，聊天室才会开启；过了结束时间，聊天室自动销毁";
    _noteLabel2.width = _tableView.width - 30.f;
    [_noteLabel2 sizeToFit];
    _noteLabel2.left = 15.f;
    _noteLabel2.top = _segmentedControl.bottom + 5.f;
}

#pragma mark - UITableView Datasource&delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _selectType == 0 ? 0 : 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //微信联系人
    static NSString *cellIdentifier = @"ChatRoom_Setting_Cell";
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    //    cell.baseUser = _datasource[indexPath.row];
    cell.textLabel.text = indexPath.row == 0 ? @"开始时间" : @"结束时间";
    if(indexPath.row == 0){
        cell.detailTextLabel.text = _startTime.length > 0 ? _startTime : @"请选择";
    }else{
        cell.detailTextLabel.text = _endTime.length > 0 ? _endTime : @"请选择";
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.datePicker showInView:self.view block:^(YUDatePicker *date) {
        DLog(@"showInView ==%@ ",date.dateStr);
        self.selectIndexPath = indexPath;
        //        self.selectDate = date;
        _tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - self.datePicker.height);
        [_tableView scrollToRowAtIndexPath:_selectIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewCellHeight;
}

@end
