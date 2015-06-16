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
#define kMaxLength 10.f

@interface ChatRoomSettingViewController ()<UITableViewDelegate, UITableViewDataSource ,UITextFieldDelegate>

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
@property (assign,nonatomic) WLTextField *nameTF;
@property (assign,nonatomic) WLTextField *passWdTF;
@property (strong,nonatomic) ChatRoomInfo *chatRoomInfo;

@end

@implementation ChatRoomSettingViewController

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    _datePicker = nil;
    _datasource = nil;
    _startTime = nil;
    _endTime = nil;
    _chatRoomInfo = nil;
}

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

- (instancetype)initWithRoomType:(ChatRoomSetType)roomSetType ChatRoomInfo:(ChatRoomInfo *)chatRoomInfo
{
    self = [super init];
    if (self) {
        self.roomSetType = roomSetType;
        self.chatRoomInfo = chatRoomInfo;
        self.startTime = _chatRoomInfo ? (_chatRoomInfo.starttime.length > 0 ? _chatRoomInfo.starttime : @"") : @"";
        self.endTime = _chatRoomInfo ? (_chatRoomInfo.endtime.length > 0 ? _chatRoomInfo.endtime : @"") : @"";
        self.datasource = _chatRoomInfo ? @[_startTime,_endTime] : [NSArray array];
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
    
    if (_startTime.length > 0 && _endTime.length > 0) {
        self.selectType = 1;
    }else{
        self.selectType = 0;
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
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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
    nameTF.text = _chatRoomInfo ? _chatRoomInfo.title : @"";
    nameTF.layer.borderColorFromUIColor = kNormalLineColor;
    nameTF.layer.borderWidths = @"{0.8f,0,0.4,0}";
    nameTF.delegate = self;
    [headerView addSubview:nameTF];
    self.nameTF = nameTF;
    //    [roomIdTF setDebug:YES];
    
    //口令
    WLTextField *passWdTF = [[WLTextField alloc] initWithFrame:Rect(0, nameTF.bottom, headerView.width, 44.f)];
    passWdTF.backgroundColor = [UIColor whiteColor];
    passWdTF.font = kNormal14Font;
    passWdTF.textColor = kTitleNormalTextColor;
    passWdTF.placeholder = @"口令，10个字以内";
    passWdTF.text = _chatRoomInfo ? _chatRoomInfo.code : @"";
    passWdTF.layer.borderColorFromUIColor = kNormalLineColor;
    passWdTF.layer.borderWidths = @"{0.4f,0,0.8f,0}";
    passWdTF.delegate = self;
    [headerView addSubview:passWdTF];
    self.passWdTF = passWdTF;

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
    [segmentedControl setSelectedSegmentIndex:_selectType];
    [headerView addSubview:segmentedControl];
    self.segmentedControl = segmentedControl;
    
    //告示2
    UILabel *noteLabel2 = [[UILabel alloc] init];
    noteLabel2.backgroundColor = [UIColor clearColor];
    noteLabel2.font = kNormal12Font;
    noteLabel2.textColor = kNormalTextColor;
    noteLabel2.numberOfLines = 0.f;
    [headerView addSubview:noteLabel2];
    self.noteLabel2 = noteLabel2;
    
    tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 30.f)];
    footerView.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = footerView;
    
    //设置数据
    [self checkDateTypeInfo];
    
    //控制字数
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:UITextFieldTextDidChangeNotification
                                              object:_nameTF];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:UITextFieldTextDidEndEditingNotification
                                              object:_nameTF];
    
    //控制字数
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:UITextFieldTextDidChangeNotification
                                              object:_passWdTF];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:UITextFieldTextDidEndEditingNotification
                                              object:_passWdTF];
}

#pragma mark - private
- (void)rightBarButtonItemClicked
{
    //隐藏键盘
    [[self.view findFirstResponder] resignFirstResponder];
    
    if ([_nameTF.text deleteTopAndBottomKonggeAndHuiche].length == 0) {
        [WLHUDView showErrorHUD:@"请输入聊天室名称！"];
        return;
    }
    if ([_passWdTF.text deleteTopAndBottomKonggeAndHuiche].length == 0) {
        [WLHUDView showErrorHUD:@"请输入聊天室口令！"];
        return;
    }
    NSString *startTimeStr = @"";
    NSString *endTimeStr = @"";
    if(_selectType == 1){
        startTimeStr = _startTime;
        endTimeStr = _endTime;
        if ([startTimeStr deleteTopAndBottomKonggeAndHuiche].length == 0) {
            [WLHUDView showErrorHUD:@"请选择开始时间！"];
            return;
        }
        if ([endTimeStr deleteTopAndBottomKonggeAndHuiche].length == 0) {
            [WLHUDView showErrorHUD:@"请选择结束时间！"];
            return;
        }
    }
    //创建或者修改聊天室信息
    [WLHUDView showHUDWithStr:_roomSetType == ChatRoomSetTypeCreate ? @"创建中..." : @"保存中..." dim:NO];
    [WeLianClient chatroomCreateOrChangeWithId:_roomSetType == ChatRoomSetTypeCreate ? @(0) : _chatRoomInfo.chatroomid
                                         Title:_nameTF.text
                                     Starttime:startTimeStr
                                       Endtime:endTimeStr
                                          Code:_passWdTF.text
                                       Success:^(id resultInfo) {
                                           [WLHUDView hiddenHud];
                                           IChatRoomInfo *iChatRoomInfo = resultInfo;
                                           iChatRoomInfo.title = _nameTF.text;
                                           iChatRoomInfo.code = _passWdTF.text;
                                           iChatRoomInfo.starttime = startTimeStr;
                                           iChatRoomInfo.endtime = endTimeStr;
                                           iChatRoomInfo.total = _roomSetType == ChatRoomSetTypeCreate ? @(0) : _chatRoomInfo.joinUserCount;
                                           iChatRoomInfo.role = @(1);
                                           iChatRoomInfo.created = [[NSDate date] formattedDateWithFormat:@"yyyy-MM-dd HH:mm"];
                                           //保存到数据库
                                           [ChatRoomInfo createChatRoomInfoWith:iChatRoomInfo];
                                           [UIAlertView bk_showAlertViewWithTitle:@""
                                                                          message:_roomSetType == ChatRoomSetTypeCreate ? @"聊天室创建成功！" : @"聊天室修改成功！"
                                                                cancelButtonTitle:@"知道了"
                                                                otherButtonTitles:nil
                                                                          handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                              ///通知刷新列表
                                                                              [KNSNotification postNotificationName:@"NeedRloadChatRoomList" object:nil];
                                                                              [self.navigationController popViewControllerAnimated:YES];
                                                                          }];
                                       } Failed:^(NSError *error) {
                                           if (error) {
                                               [WLHUDView showErrorHUD:error.localizedDescription];
                                           }else{
                                               [WLHUDView showErrorHUD:_roomSetType == ChatRoomSetTypeCreate ? @"聊天室创建失败，请重试！" : @"聊天室修改失败，请重试！"];
                                           }
                                       }];
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
    
    //时间控制
    NSDate *startDate = _startTime.length > 0 ? [_startTime dateFromNormalString] : [NSDate date];
    NSDate *endDate = _endTime.length > 0 ? [_endTime dateFromNormalString] : [NSDate date];
    if (_startTime.length > 0 && _endTime.length == 0) {
        //如果只有开始时间，设置结束时间是开始时间的下一个小时
        _endTime = [[startDate dateByAddingHours:1] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    }else if(_startTime.length == 0 && _endTime.length > 0){
        if ([endDate daysUntil] > 0) {
            //比结束时间往前一小时
            _startTime = [[endDate dateBySubtractingHours:1] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
        }else{
            //如果结束时间等于当前时间  把结束时间当作开始时间，结束时间往后加1小时
            _startTime = _endTime;
            _endTime = [[[_startTime dateFromNormalString] dateByAddingHours:1] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
    }else if(_startTime.length > 0 && _endTime.length > 0){
        //开始和结束时间都有
        if ([startDate isLaterThanOrEqualTo:endDate]) {
            _endTime = [[startDate dateByAddingHours:1] formattedDateWithFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
    }
    
    self.datasource = @[_startTime,_endTime];
    [_tableView reloadData];
//    [_tableView reloadRowsAtIndexPaths:@[_selectIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)segmentedControlChanged:(UISegmentedControl *)sender
{
    DLog(@"segmentedControlChanged-->%ld",(long)sender.selectedSegmentIndex);
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
    
//    if (_selectType == 0) {
//        self.startTime = @"";
//        self.endTime = @"";
//    }else{
//        self.startTime = _chatRoomInfo.starttime;
//        self.endTime = _chatRoomInfo.endtime;
//    }
    self.datasource = @[_startTime,_endTime];
    [_tableView reloadData];
}

- (void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    // 键盘输入模式(判断输入模式的方法是iOS7以后用到的,如果想做兼容,另外谷歌)
    NSArray * currentar = [UITextInputMode activeInputModes];
    UITextInputMode * current = [currentar firstObject];
    
    if ([current.primaryLanguage isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
                //此方法是我引入的第三方警告框.读者可以自己完成警告弹窗.
            }
        }else{
            // 有高亮选择的字符串，则暂不对文字进行统计和限制
        }
    }else{
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
    }
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //键盘出现前，隐藏时间选项
    [_datePicker hidden];
    _tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    return YES;
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
    NSString *detailStr = [_datasource[indexPath.row] length] > 0 ? _datasource[indexPath.row] : @"请选择";
    cell.detailTextLabel.text = detailStr;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[self.view findFirstResponder] resignFirstResponder];
    
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
