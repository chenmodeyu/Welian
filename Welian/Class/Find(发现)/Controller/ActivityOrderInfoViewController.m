//
//  ActivityOrderInfoViewController.m
//  Welian
//
//  Created by weLian on 15/2/13.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ActivityOrderInfoViewController.h"
#import "UIImage+ImageEffects.h"
#import "ActivityOrderInfoViewCell.h"

#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"
#import "ActivityQuestionView.h"

#define kMarginEdge 8.f
#define kMarginLeft 15.f
#define kTotalPriceViewHeight 58.f
#define kTableViewBottomHeight 200.f
#define kTableViewCellHeight 30.f
#define kCenterTitleViewHeight 40.f


@interface ActivityOrderInfoViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) IActivityInfo *iActivityInfo;
@property (strong,nonatomic) NSArray *tickets;
@property (strong,nonatomic) NSArray *orderTickets;
@property (strong,nonatomic) IActivityOrderResultModel *payInfo;
@property (strong,nonatomic) NSArray *questInfos;
@property (assign,nonatomic) UIButton *payBtn;

@end

@implementation ActivityOrderInfoViewController

- (void)dealloc
{
    _iActivityInfo = nil;
    _tickets = nil;
    _orderTickets = nil;
    _payInfo = nil;
    [KNSNotification removeObserver:self];
}

- (NSString *)title
{
    return @"订单详情";
}

- (instancetype)initWithIActivityInfo:(IActivityInfo *)iActivityInfo Tickets:(NSArray *)tickets OrderTickets:(NSArray *)orderTickets payInfo:(IActivityOrderResultModel *)payInfo
{
    self = [super init];
    if (self) {
        self.iActivityInfo = iActivityInfo;
        self.tickets = tickets;
        self.orderTickets = orderTickets;
        self.payInfo = payInfo;
        
        //添加支付成功监听，支付成功，更新订单状态
        [KNSNotification addObserver:self selector:@selector(updateOrderSucess) name:kAlipayPaySuccess object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //注册键盘
    [DaiDodgeKeyboard addRegisterTheViewNeedDodgeKeyboard:self.view];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //移除監控
    [DaiDodgeKeyboard removeRegisterTheViewNeedDodgeKeyboard];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGB(237.f, 238.f, 242.f);
    
    //tableview头部距离问题
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //订单列表
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ViewCtrlTopBarHeight, self.view.width, self.view.height - ViewCtrlTopBarHeight) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
//    [tableView setDebug:YES];
    
    //头部内容
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, [self configureTableHeaderHeight])];
    headerView.backgroundColor = [UIColor whiteColor];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = kTitleNormalTextColor;
    titleLabel.font = kNormalBlod16Font;
    titleLabel.text = _iActivityInfo.name;
    titleLabel.numberOfLines = 0.f;
    titleLabel.width = headerView.width - kMarginLeft * 2.f;
    [titleLabel sizeToFit];
    titleLabel.left = kMarginLeft;
    titleLabel.top = kMarginLeft;
    [headerView addSubview:titleLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.textColor = kNormalTextColor;
    timeLabel.font = kNormal12Font;
    timeLabel.text = [_iActivityInfo displayStartTimeInfo];
    timeLabel.numberOfLines = 0.f;
    timeLabel.width = headerView.width - kMarginLeft * 2.f;
    [timeLabel sizeToFit];
    timeLabel.left = kMarginLeft;
    timeLabel.top = titleLabel.bottom + kMarginEdge;
    [headerView addSubview:timeLabel];
    
    tableView.tableHeaderView = headerView;
    
//    IAskInfoMdoel *askInfo1 = [[IAskInfoMdoel alloc] init];
//    askInfo1.confid = @(1);
//    askInfo1.title = @"邮箱";
//    askInfo1.field = @"field1";
//    
//    IAskInfoMdoel *askInfo2 = [[IAskInfoMdoel alloc] init];
//    askInfo2.confid = @(2);
//    askInfo2.title = @"为什么要参加这个活动？";
//    askInfo2.field = @"field2";
//    
//    IAskInfoMdoel *askInfo3 = [[IAskInfoMdoel alloc] init];
//    askInfo3.confid = @(1);
//    askInfo3.title = @"为什么要参加这个活动？";
//    askInfo3.field = @"field3";
//    NSArray *datasources = @[askInfo1,askInfo2,askInfo3];
    
    
    //底部内容
    CGFloat questHeight = [ActivityQuestionView configureQuestionViewHeight:_iActivityInfo.confs];
    CGFloat footerHeight = kTableViewBottomHeight + (_iActivityInfo.confs.count > 0 ? questHeight + kCenterTitleViewHeight : 0);
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width,footerHeight)];
//    [footerView setDebug:YES];
    
    UIView *totalInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, footerView.width, kTotalPriceViewHeight)];
    totalInfoView.backgroundColor = [UIColor whiteColor];
    [footerView addSubview:totalInfoView];
    
    //总金额
    UILabel *totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    totalPriceLabel.backgroundColor = [UIColor clearColor];
    totalPriceLabel.font = kNormal14Font;
    totalPriceLabel.textColor = kTitleNormalTextColor;
    totalPriceLabel.text = [NSString stringWithFormat:@"%@元",[self displayTotalPrice]];
    [totalPriceLabel setAttributedText:[NSObject getAttributedInfoString:totalPriceLabel.text searchStr:[self displayTotalPrice] color:RGB(224.f, 68.f, 0.f) font:kNormalBlod18Font]];
    [totalPriceLabel sizeToFit];
    totalPriceLabel.right = totalInfoView.right - kMarginLeft;
    totalPriceLabel.top = 19.f;
    [totalInfoView addSubview:totalPriceLabel];
    
    //总数量
    UILabel *totalNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    totalNumLabel.backgroundColor = [UIColor clearColor];
    totalNumLabel.font = kNormal14Font;
    totalNumLabel.textColor = kTitleNormalTextColor;
    totalNumLabel.text = [NSString stringWithFormat:@"共%d张　　　总计 ",[self displayTicketCount]];
    [totalNumLabel sizeToFit];
    totalNumLabel.right = totalPriceLabel.left;
    totalNumLabel.centerY = totalPriceLabel.centerY;
    [totalInfoView addSubview:totalNumLabel];
    
    //下方的分割波浪边线
    UIImageView *contentImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"discovery_activity_pay_bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:1]];
    contentImageView.frame = CGRectMake(0, totalInfoView.bottom, footerView.width, 10.f);
    [footerView addSubview:contentImageView];
    
    //支付按钮
    UIButton *payBtn = [UIView getBtnWithTitle:@"确认支付" image:nil];
    payBtn.frame = CGRectMake(kMarginLeft, contentImageView.bottom + 50.f, footerView.width - kMarginLeft * 2.f, 45.f);
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    payBtn.backgroundColor = KBlueTextColor;
    [payBtn addTarget:self action:@selector(payBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:payBtn];
    self.payBtn = payBtn;
    
    if (_iActivityInfo.confs.count > 0) {
        //标题
        UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, contentImageView.bottom, footerView.width, kCenterTitleViewHeight)];
        centerView.backgroundColor = [UIColor clearColor];
        [footerView addSubview:centerView];
        
        //标题
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = kTitleNormalTextColor;
        titleLabel.font = kNormalBlod16Font;
        titleLabel.text = @"确认信息";
        [titleLabel sizeToFit];
        titleLabel.centerX = centerView.width / 2.f;
        titleLabel.centerY = centerView.height / 2.f;
        [centerView addSubview:titleLabel];
        
        //左右两边的线
        UIView *leftLine = [[UIView alloc] init];
        leftLine.backgroundColor = RGB(197.f, 197.f, 197.f);
        leftLine.size = CGSizeMake(titleLabel.left / 2.f, 0.5f);
        leftLine.right = titleLabel.left - kMarginEdge;
        leftLine.centerY = titleLabel.centerY;
        [centerView addSubview:leftLine];
        
        UIView *rightLine = [[UIView alloc] init];
        rightLine.backgroundColor = RGB(197.f, 197.f, 197.f);
        rightLine.size = CGSizeMake(leftLine.width, 0.5f);
        rightLine.left = titleLabel.right + kMarginEdge;
        rightLine.centerY = titleLabel.centerY;
        [centerView addSubview:rightLine];
        
        //问题
        ActivityQuestionView *questionView = [[ActivityQuestionView alloc] initWithQuestions:_iActivityInfo.confs];
        questionView.frame = CGRectMake(0.f, centerView.bottom, footerView.width, questHeight);
        [footerView addSubview:questionView];
        //    [questionView setDebug:YES];
        WEAKSELF
        [questionView setCheckBlock:^(BOOL canJoin,NSArray *questInfos){
            [weakSelf checkInfoWith:canJoin QuestInfos:questInfos];
        }];
        
        payBtn.frame = CGRectMake(kMarginLeft, questionView.bottom + 50.f, footerView.width - kMarginLeft * 2.f, 45.f);
        
        UITapGestureRecognizer *tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [[self.view findFirstResponder] resignFirstResponder];
        }];
//        tap.delegate = self;
        [self.view addGestureRecognizer:tap];
        
        //默认不能点击
        [self checkConfirmBtnEnable:NO];
    }
    
    //支付说明
    UIButton *payAboutBtn = [UIView getBtnWithTitle:@"付款说明" image:nil];
    [payAboutBtn setTitleColor:KBlueTextColor forState:UIControlStateNormal];
    payAboutBtn.backgroundColor = [UIColor clearColor];
    payAboutBtn.hidden = YES;
    [payAboutBtn sizeToFit];
    payAboutBtn.right = payBtn.right;
    payAboutBtn.bottom = payBtn.top - kMarginEdge;
    [payAboutBtn addTarget:self action:@selector(payAboutBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [footerView addSubview:payAboutBtn];
    
    tableView.tableFooterView = footerView;
}

#pragma mark - UITableView Datasource&Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tickets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Activity_OrderInfo_View_Cell";
    ActivityOrderInfoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ActivityOrderInfoViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.iActivityTicket = _tickets[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewCellHeight;
}

//#pragma mark - UIGestureRecognizerDelegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    
//    DLog(@"touch.view：%@",[touch.view class]);
//    ///UITableViewWrapperView
//    if ([[NSString stringWithFormat:@"%@",[touch.view class]] isEqualToString:@"UITableViewWrapperView"]) {
//        return NO;
//    }
//    return YES;
//}

#pragma mark - Private
//获取订单详情
- (NSString *)displayOrderDetail
{
    NSMutableString *detailInfo = [NSMutableString string];
    for (int i = 0; i < _tickets.count; i++) {
        IActivityTicket *ticket = _tickets[i];
        if (i > 0) {
            [detailInfo appendString:@"|"];
        }
        [detailInfo appendString:[NSString stringWithFormat:@"%@共%@张",ticket.name,ticket.buyCount]];
    }
    return detailInfo;
}

//获取总金额
- (NSString *)displayTotalPrice
{
    float totalPrice = 0.f;
    for (int i = 0; i < _tickets.count; i++) {
        IActivityTicket *ticket = _tickets[i];
        totalPrice += ticket.price.floatValue * ticket.buyCount.integerValue;
    }
    NSString *price = [NSString stringWithFormat:@"%.2f",totalPrice];
    return price;
}

//获取总票数
- (int)displayTicketCount
{
    float ticketCount = 0;
    for (int i = 0; i < _tickets.count; i++) {
        IActivityTicket *ticket = _tickets[i];
        ticketCount += ticket.buyCount.integerValue;
    }
    return ticketCount;
}

//支付
- (void)payBtnClicked:(UIButton *)sender
{
    //总金额大于0需要支付
    if ([[self displayTotalPrice] floatValue] > 0) {
        UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"在线支付"];
        [sheet bk_addButtonWithTitle:@"支付宝支付" handler:^{
            [self confirmAliPay];
        }];
        [sheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [sheet showInView:self.view];
    }else{
        //总金额小于0
        if(_payInfo){
            //订单已经存在
            //金额为0 直接修改订单状态
            [self updateOrderSucess];
        }else{
            //先创建订单，然后更新订单状态
            //未创建订单
            if (_questInfos.count == _iActivityInfo.confs.count) {
                [WLHUDView showHUDWithStr:@"下单中..." dim:NO];
                [WeLianClient orderActiveWithID:_iActivityInfo.activeid
                                        Tickets:_orderTickets
                                          Confs:_questInfos
                                        Success:^(id resultInfo) {
                                            [WLHUDView hiddenHud];
                                            self.payInfo = [IActivityOrderResultModel objectWithDict:resultInfo];;
                                            
                                            //金额为0 直接修改订单状态
                                            [self updateOrderSucess];
                                        } Failed:^(NSError *error) {
                                            if (error) {
                                                [WLHUDView showErrorHUD:error.localizedDescription];
                                            }else{
                                                [WLHUDView showErrorHUD:@"下单失败，请重新尝试！"];
                                            }
                                        }];
            }
        }
    }
}

- (void)confirmAliPay
{
    if (_payInfo) {
        //订单已经存在，直接调用支付宝支付
        [self payByAlipay];
    }else{
        //未创建订单，先创建订单，在调用支付宝支付
        if (_questInfos.count == _iActivityInfo.confs.count) {
            [WLHUDView showHUDWithStr:@"下单中..." dim:NO];
            [WeLianClient orderActiveWithID:_iActivityInfo.activeid
                                    Tickets:_orderTickets
                                      Confs:_questInfos
                                    Success:^(id resultInfo) {
                                        [WLHUDView hiddenHud];
                                        self.payInfo = [IActivityOrderResultModel objectWithDict:resultInfo];
                                        
                                        [self payByAlipay];
                                    } Failed:^(NSError *error) {
                                        if (error) {
                                            [WLHUDView showErrorHUD:error.localizedDescription];
                                        }else{
                                            [WLHUDView showErrorHUD:@"下单失败，请重新尝试！"];
                                        }
                                    }];
        }
    }
}

//支付宝支付
- (void)payByAlipay
{
    if(_payInfo.orderid.length > 0){
        //订单号存在
        /*
         *商户的唯一的parnter和seller。
         *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
         */
        
        /*============================================================================*/
        /*=======================需要填写商户app申请的===================================*/
        /*============================================================================*/
        //如果partner和seller数据存于其他位置,请改写下面两行代码
        
        NSString *partner = _payInfo.alipay.partnerid;//PartnerID;//[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PartnerID"];
        NSString *seller = _payInfo.alipay.sellerid;//SellerID;//[[NSBundle mainBundle] objectForInfoDictionaryKey:@"SellerID"];
        NSString *privateKey = _payInfo.alipay.privkey;//PartnerPrivKey;//[[NSBundle mainBundle] objectForInfoDictionaryKey:@"RSA private key"];
        /*============================================================================*/
        /*============================================================================*/
        /*============================================================================*/
        
        //partner和seller获取失败,提示
        if ([partner length] == 0 || [seller length] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"缺少partner或者seller。"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        /*
         *生成订单信息及签名
         */
        //将商品信息赋予AlixPayOrder的成员变量
        Order *order = [[Order alloc] init];
        order.partner = partner;
        order.seller = seller;
        order.tradeNO = _payInfo.orderid;//_payInfo[@"orderid"]; //订单ID（由商家自行制定）
        order.productName = _iActivityInfo.name; //商品标题
        order.productDescription = [self displayOrderDetail]; //商品描述
        order.amount = [NSString stringWithFormat:@"%.2f",_payInfo.amount.floatValue];//[NSString stringWithFormat:@"%.2f",[_payInfo[@"amount"] floatValue]]; //商品价格
        order.notifyURL = _payInfo.alipay.callbackurl;//kAlipayNotifyURL; //回调URL
        
        order.service = @"mobile.securitypay.pay";
        order.paymentType = @"1";
        order.inputCharset = @"utf-8";
        order.itBPay = @"30m";
        order.showUrl = @"m.alipay.com";
        
        //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
        NSString *appScheme = @"AlipayWeLian";
        
        //将商品信息拼接成字符串
        NSString *orderSpec = [order description];
        DLog(@"orderSpec = %@",orderSpec);
        
        //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
        id<DataSigner> signer = CreateRSADataSigner(privateKey);
        NSString *signedString = [signer signString:orderSpec];
        
        //将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = nil;
        if (signedString != nil) {
            orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                           orderSpec, signedString, @"RSA"];
            
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                NSInteger resultStatus = [resultDic[@"resultStatus"] integerValue];
                if (resultStatus == 9000) {
                    //支付成功
                    [KNSNotification postNotificationName:kAlipayPaySuccess object:nil];
                }else{
                    if ([resultDic[@"memo"] length] > 0) {
                        [UIAlertView showWithTitle:nil message:resultDic[@"memo"]];
                    }
                }
                DLog(@"支付结果 result = %@", resultDic);
            }];
        }
    }
}


//支付说明
- (void)payAboutBtnClicked:(UIButton *)sender
{
    
}

- (void)updateOrderSucess
{
    if(_payInfo.orderid.length > 0){
        [WLHUDView showHUDWithStr:@"更新订单状态中..." dim:YES];
        //    NSDictionary *param = @{@"orderid":_payInfo[@"orderid"]};
        [WeLianClient updateActiveOrderStatusWithID:_payInfo.orderid
                                            Success:^(id resultInfo) {
                                                [WLHUDView hiddenHud];
                                                
                                                //刷新详情页面
                                                [KNSNotification postNotificationName:kNeedReloadActivityUI object:nil];
                                                [UIAlertView bk_showAlertViewWithTitle:@""
                                                                               message:@"恭喜您，活动报名成功！"
                                                                     cancelButtonTitle:@"确定"
                                                                     otherButtonTitles:nil
                                                                               handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                                   [self.navigationController popViewControllerAnimated:YES];
                                                                               }];
                                            } Failed:^(NSError *error) {
                                                [WLHUDView hiddenHud];
                                                
                                                [UIAlertView bk_showAlertViewWithTitle:@""
                                                                               message:[NSString stringWithFormat:@"订单状态修改失败，请联系客服：%@",kTelNumber]
                                                                     cancelButtonTitle:@"取消"
                                                                     otherButtonTitles:@[@"呼叫"]
                                                                               handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                                   if(buttonIndex == 0){
                                                                                       return ;
                                                                                   }else{
                                                                                       [self telToWeLian];
                                                                                   }
                                                                               }];
                                            }];
    }
}

- (void)checkInfoWith:(BOOL)canJoin QuestInfos:(NSArray *)questInfos
{
    self.questInfos = questInfos;
    [self checkConfirmBtnEnable:canJoin];
}

- (void)checkConfirmBtnEnable:(BOOL)enable
{
    _payBtn.enabled = enable;
    
    _payBtn.backgroundColor = _payBtn.enabled == NO ? KBgGrayColor : KBlueTextColor;
    _payBtn.layer.borderColor = _payBtn.enabled == NO ? KBgGrayColor.CGColor : KBlueTextColor.CGColor;
    [_payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

//拨打电话
- (void)telToWeLian
{
    //拨打电话
    [ACETelPrompt callPhoneNumber:kTelNumber
                             call:^(NSTimeInterval duration) {
                                 DLog(@"User made a call of \(%f) seconds",duration);
                             } cancel:^{
                                 DLog(@"User cancelled the call");
                             }];
}

//获取表格头部内容的高度
- (CGFloat)configureTableHeaderHeight
{
    CGSize titleSize = [_iActivityInfo.name calculateSize:CGSizeMake(self.view.width - kMarginLeft * 2.f, FLT_MAX) font:kNormalBlod16Font];
    CGSize timeSize = [[_iActivityInfo displayStartTimeInfo] calculateSize:CGSizeMake(self.view.width - kMarginLeft * 2.f, FLT_MAX) font:kNormal12Font];
    return titleSize.height + timeSize.height + kMarginLeft + kMarginEdge;
}

//获取表格的高度
- (CGFloat)configureTableViewHeight
{
    return [self configureTableHeaderHeight] + 3 * kTableViewCellHeight + kTableViewBottomHeight;
}

@end
