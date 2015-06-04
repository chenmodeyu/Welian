//
//  ShaiXuanView.m
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ShaiXuanView.h"
#import "ShaiXuanCell.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "ShaiXuanHeaderView.h"

#define KleftW 50

@interface ShaiXuanView() <UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSIndexPath *_oneIndex;
    NSIndexPath *_twoIndex;
    NSIndexPath *_threeIndex;
    
    ShaiXuanType _type;
}

@property (nonatomic,strong) NSArray *industrys;
@property (nonatomic,strong) NSArray *citys;
@property (nonatomic,strong) NSArray *stages;

@property (nonatomic, strong) UIButton *confirmBut;
@property (nonatomic, strong) UILabel *titleLabel;

@end

static NSString *shaixuanCellid = @"shaixuanCellid";
static NSString *shaixuanHeaderid = @"ShaiXuanHeaderView";

@implementation ShaiXuanView

//获取领域
- (NSArray *)industrys
{
    if (_industrys == nil) {
        _industrys = [NSArray arrayWithContentsOfFile:[[ResManager documentPath] stringByAppendingString:@"/Industrys.plist"]];
    }
    return _industrys;
}
//融资阶段 0:种子轮投资  1:天使轮投资  2:pre-A轮投资 3:A轮投资 4:B轮投资  5:C轮投资
- (NSArray *)stages
{
    if (_stages == nil) {
        _stages = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"FinancingStagePlist" withExtension:@"plist"]];
    }
    return _stages;
}

//获取城市
- (NSArray *)citys
{
    if (_citys == nil) {
        _citys = [NSArray arrayWithContentsOfFile:[[ResManager documentPath] stringByAppendingString:@"/ProjectCitys.plist"]];
    }
    return _citys;
}

- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
        layout.minimumLineSpacing = 8;
        layout.minimumInteritemSpacing = 8;
        [layout setHeaderReferenceSize:CGSizeMake(SuperSize.width-KleftW, 40)];
        [layout setSectionInset:UIEdgeInsetsMake(10, 10, 20, 10)];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.allowsMultipleSelection = YES;
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        [_collectionView registerClass:[ShaiXuanCell class] forCellWithReuseIdentifier:shaixuanCellid];
        [_collectionView registerNib:[UINib nibWithNibName:@"ShaiXuanHeaderView" bundle:nil]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                 withReuseIdentifier:shaixuanHeaderid];
    }
    return _collectionView;
}


- (void)loadUI
{
    CGSize size = SuperSize;
    UIView *tapGestureView = [[UIView alloc] initWithFrame:self.bounds];
    tapGestureView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.7];
    [self addSubview:tapGestureView];
    UITapGestureRecognizer* singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(desmisSelfVC)];
    //点击的次数
    singleRecognizer.numberOfTapsRequired = 1;
    [tapGestureView addGestureRecognizer:singleRecognizer];
    
    UIView *backgView = [[UIView alloc] initWithFrame:CGRectMake(KleftW, 0, size.width-KleftW, size.height)];
    [backgView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:backgView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, size.width-KleftW, 44)];
    [titleLabel setText:self.titleText];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor blackColor]];
    [backgView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIButton *desmisBut = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 60, 44)];
    [desmisBut setTitle:@"取消" forState:UIControlStateNormal];
    [desmisBut setTitleColor:KBlueTextColor forState:UIControlStateNormal];
    [desmisBut addTarget:self action:@selector(desmisSelfVC) forControlEvents:UIControlEventTouchUpInside];
    [backgView addSubview:desmisBut];
    
    UIButton *confirmBut = [[UIButton alloc] initWithFrame:CGRectMake(size.width-KleftW-60, 20, 60, 44)];
    [confirmBut setTitle:@"确认" forState:UIControlStateNormal];
    [confirmBut setTitleColor:KBlueTextColor forState:UIControlStateNormal];
    [confirmBut setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [confirmBut addTarget:self action:@selector(confirmButClick) forControlEvents:UIControlEventTouchUpInside];
    [backgView addSubview:confirmBut];
    [confirmBut setEnabled:NO];
    self.confirmBut = confirmBut;
    [self.collectionView setFrame:CGRectMake(0, 64, size.width-KleftW, size.height-64)];
    [backgView addSubview:self.collectionView];
    
    if (_oneIndex||_twoIndex||_threeIndex) {
        [confirmBut setEnabled:YES];
        if (_oneIndex) {
            [self.collectionView selectItemAtIndexPath:_oneIndex animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
        if (_twoIndex) {
            [self.collectionView selectItemAtIndexPath:_twoIndex animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
        if (_threeIndex) {
            [self.collectionView selectItemAtIndexPath:_threeIndex animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
}


- (instancetype)initWithShaiXuanType:(ShaiXuanType)type
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _type = type;
        LogInUser *loginUser = [LogInUser getCurrentLoginUser];
        NSDictionary *searchIndustryinfo;
        NSDictionary *searchCity;
        NSDictionary *searchStage;
        if (type == ShaiXuanTypeProject) {
            //项目 领域搜索条件
            searchIndustryinfo = [UserDefaults objectForKey:[NSString stringWithFormat:kProjectSearchIndustryKey,loginUser.uid]];
            //项目 地区条件
            searchCity = [UserDefaults objectForKey:[NSString stringWithFormat:kProjectSearchCityKey,loginUser.uid]];
            //项目 投资阶段条件
            searchStage = [UserDefaults objectForKey:[NSString stringWithFormat:kProjectSearchStageKey,loginUser.uid]];
        }else if (type == ShaiXuanTypeInvestorUser){
            //投资人领域搜索条件
            searchIndustryinfo = [UserDefaults objectForKey:[NSString stringWithFormat:kInvestorSearchIndustryKey,loginUser.uid]];
            //投资人 投资阶段条件
            searchStage = [UserDefaults objectForKey:[NSString stringWithFormat:kInvestorSearchStageKey,loginUser.uid]];
            //投资人 地区条件
            searchCity = [UserDefaults objectForKey:[NSString stringWithFormat:kInvestorSearchCityKey,loginUser.uid]];
        }
        if (searchIndustryinfo) {
            NSInteger industInt = [self.industrys indexOfObject:searchIndustryinfo];
            _oneIndex = [NSIndexPath indexPathForItem:industInt inSection:0];
        }
        if (searchStage) {
            NSInteger stageInt = [self.stages indexOfObject:searchStage];
            _twoIndex = [NSIndexPath indexPathForItem:stageInt inSection:1];
        }
        if (searchCity) {
            NSInteger cityInt = [self.citys indexOfObject:searchCity];
            _threeIndex = [NSIndexPath indexPathForItem:cityInt inSection:2];
        }
        [self loadUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel setText:self.titleText];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titStr = @"";
    switch (indexPath.section) {
        case 0:
            titStr = [self.industrys[indexPath.row] objectForKey:@"industryname"];
            break;
        case 1:
            titStr = [self.stages[indexPath.row] objectForKey:@"stagename"];
            break;
        case 2:
            titStr = [self.citys[indexPath.row] objectForKey:@"name"];
            break;
        default:
            break;
    }
   CGSize titSize = [titStr sizeWithCustomFont:WLFONT(15) constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
    return CGSizeMake(titSize.width+15, 32);
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.industrys.count;
            break;
        case 1:
            return self.stages.count;
            break;
        case 2:
            return self.citys.count;
            break;
        default:
            break;
    }
    return 0;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShaiXuanCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:shaixuanCellid forIndexPath:indexPath];
    NSString *titStr = @"";
    switch (indexPath.section) {
        case 0:
            titStr = [self.industrys[indexPath.row] objectForKey:@"industryname"];
            break;
        case 1:
            titStr = [self.stages[indexPath.row] objectForKey:@"stagename"];
            break;
        case 2:
            titStr = [self.citys[indexPath.row] objectForKey:@"name"];
            break;
        default:
            break;
    }
    [cell.titeButton setTitle:titStr forState:UIControlStateNormal];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqual:UICollectionElementKindSectionHeader]) {
        ShaiXuanHeaderView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:shaixuanHeaderid forIndexPath:indexPath];
        NSString *headerStr = @"";
        switch (indexPath.section) {
            case 0:
                headerStr = _type==ShaiXuanTypeProject?@"项目领域":@"投资领域";
                break;
            case 1:
                headerStr = _type==ShaiXuanTypeProject?@"投资阶段":@"投资阶段";
                break;
            case 2:
                headerStr = _type==ShaiXuanTypeProject?@"项目地区":@"投资地区";
                break;
            default:
                break;
        }
        [headerView.titLabel setText:headerStr];
        return headerView;
    }
    return nil;
}


#pragma mark - 代理方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            if (_oneIndex) {
                [collectionView deselectItemAtIndexPath:_oneIndex animated:NO];
            }
            _oneIndex = indexPath;
            break;
        case 1:
            if (_twoIndex) {
                [collectionView deselectItemAtIndexPath:_twoIndex animated:NO];
            }
            _twoIndex = indexPath;
            break;
        case 2:
            if (_threeIndex) {
                [collectionView deselectItemAtIndexPath:_threeIndex animated:NO];
            }
            _threeIndex = indexPath;
            break;
        default:
            break;
    }
    if (_oneIndex||_twoIndex||_threeIndex) {
        [self.confirmBut setEnabled:YES];
    }else{
        [self.confirmBut setEnabled:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            _oneIndex = nil;
            break;
        case 1:
            _twoIndex = nil;
            break;
        case 2:
            _threeIndex = nil;
            break;
        default:
            break;
    }
    if (_oneIndex||_twoIndex||_threeIndex) {
        [self.confirmBut setEnabled:YES];
    }else{
        [self.confirmBut setEnabled:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    NSLog(@"performAction");
}

- (void)confirmButClick
{
    LogInUser *loginUser = [LogInUser getCurrentLoginUser];
    if (!loginUser) {
        return;
    }
    if (_type == ShaiXuanTypeProject) {
        if (_oneIndex) {
            //项目 领域搜索条件
            [NSUserDefaults setObject:self.industrys[_oneIndex.row] forKey:[NSString stringWithFormat:kProjectSearchIndustryKey,loginUser.uid]];
        }else{
            [NSUserDefaults setObject:nil forKey:[NSString stringWithFormat:kProjectSearchIndustryKey,loginUser.uid]];
        }
        if (_twoIndex) {
            //项目 投资阶段条件
            [NSUserDefaults setObject:self.stages[_twoIndex.row] forKey:[NSString stringWithFormat:kProjectSearchStageKey,loginUser.uid]];
        }else{
            [NSUserDefaults setObject:nil forKey:[NSString stringWithFormat:kProjectSearchStageKey,loginUser.uid]];
        }
        
        if (_threeIndex) {
            //项目 地区条件
            [NSUserDefaults setObject:self.citys[_threeIndex.row] forKey:[NSString stringWithFormat:kProjectSearchCityKey,loginUser.uid]];
        }else{
            [NSUserDefaults setObject:nil forKey:[NSString stringWithFormat:kProjectSearchCityKey,loginUser.uid]];
        }
    }else if (_type == ShaiXuanTypeInvestorUser){
        if (_oneIndex) {
            //项目 领域搜索条件
            [NSUserDefaults setObject:self.industrys[_oneIndex.row] forKey:[NSString stringWithFormat:kInvestorSearchIndustryKey,loginUser.uid]];
        }else{
            [NSUserDefaults setObject:nil forKey:[NSString stringWithFormat:kInvestorSearchIndustryKey,loginUser.uid]];
        }
        if (_twoIndex) {
            //项目 投资阶段条件
            [NSUserDefaults setObject:self.stages[_twoIndex.row] forKey:[NSString stringWithFormat:kInvestorSearchStageKey,loginUser.uid]];
        }else{
            [NSUserDefaults setObject:nil forKey:[NSString stringWithFormat:kInvestorSearchStageKey,loginUser.uid]];
        }
        
        if (_threeIndex) {
            //项目 地区条件
            [NSUserDefaults setObject:self.citys[_threeIndex.row] forKey:[NSString stringWithFormat:kInvestorSearchCityKey,loginUser.uid]];
        }else{
            [NSUserDefaults setObject:nil forKey:[NSString stringWithFormat:kInvestorSearchCityKey,loginUser.uid]];
        }
    }
    
    if (self.shaixuanBlock) {
        self.shaixuanBlock();
    }
    [self removeFromSuperview];
}

- (void)desmisSelfVC
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    [self removeFromSuperview];
}

- (void)showVC
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}



@end
