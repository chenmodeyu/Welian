//
//  UserCardController.m
//  Welian
//
//  Created by dong on 14-9-17.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import "UserCardController.h"
#import "UIImageView+WebCache.h"
#import "WeixinActivity.h"

@interface UserCardController () <UIActionSheetDelegate>
{
    NSArray *activity;
}

@end

@implementation UserCardController

- (void)setdatainfo:(UserInfoModel *)userinfoM
{
    [_iconImageV sd_setImageWithURL:[NSURL URLWithString:userinfoM.avatar] placeholderImage:[UIImage imageNamed:@""] options:SDWebImageRetryFailed|SDWebImageLowPriority];
    
    [_nameLabel setText:userinfoM.name];

    [_companyLabel setText:userinfoM.company];
    [_positionLabel setText:userinfoM.position];
    [_mobileLabel setText:userinfoM.mobile];
    [_emilLabel setText:userinfoM.email];
    
    if (userinfoM.provincename || userinfoM.cityname || userinfoM.address) {
        
        [_addresLabel setText:[NSString stringWithFormat:@"%@-%@%@",userinfoM.provincename,userinfoM.cityname,userinfoM.address]];
    }
    
    NSInteger investint = [userinfoM.investorauth integerValue];
    [_investerImage setHidden:!investint];
    
    NSInteger startint = [userinfoM.startupauth integerValue];
    [_entrepreneurImage setHidden:!startint];
    
    
    NSInteger relint = [userinfoM.friendship integerValue];
    switch (relint) {
        case 0:  // 没关系
            [_addBut setTitle:@"加好友" forState:UIControlStateNormal];
            break;
        case 1:  // 朋友
            [_addBut setTitle:@"发消息" forState:UIControlStateNormal];
            break;
        case 2:  // 朋友的朋友
            [_addBut setTitle:@"加好友" forState:UIControlStateNormal];
            break;
        case -1:  // 自己
            [_addBut setHidden:YES];
            break;
        default:
            break;
    }
    
    
    
    [self.scrollView setContentSize:CGSizeMake(0, self.view.bounds.size.height-60)];
}

- (void)shares
{
    activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init]];

    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:@"%@的名片,%@,%@",self.userinfoM.name,self.userinfoM.position,self.userinfoM.company], self.iconImageV.image, [NSURL URLWithString:[NSString stringWithFormat:@"%@",self.userinfoM.shareurl]]] applicationActivities:activity];
    
    //    activityView.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint];
    [self presentViewController:activityView animated:YES completion:nil];


}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_more"] style:UIBarButtonItemStyleBordered target:self action:@selector(shares)];

    [_iconImageV.layer setCornerRadius:self.iconImageV.bounds.size.width*0.5];
    [_iconImageV.layer setMasksToBounds:YES];
    [_iconImageV.layer setBorderWidth:4];
    [_iconImageV.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    [self.bageView.layer setCornerRadius:5.0];
    [self.bageView.layer setMasksToBounds:YES];
    [self setdatainfo:_userinfoM];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)butCick:(id)sender {
    
    
    
}
@end
