//
//  ShaiXuanView.m
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ShaiXuanView.h"
#import "BiaoqainCell.h"

#define KleftW 50

@interface ShaiXuanView()
{
    NSIndexPath *oneIndex;
    NSIndexPath *twoIndex;
    NSIndexPath *threeIndex;
}

@property (nonatomic, strong) UIButton *confirmBut;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ShaiXuanView
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setSectionInset:UIEdgeInsetsMake(20, 20, 10, 20)];
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.allowsMultipleSelection = YES;
        [_collectionView setDataSource:self];
        [_collectionView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
        [_collectionView setDelegate:self];
        [_collectionView registerClass:[BiaoqainCell class] forCellWithReuseIdentifier:@"cellid"];
    }
    return _collectionView;
}


- (void)loadUiWithFrame:(CGSize)size
{
    UIView *tapGestureView = [[UIView alloc] initWithFrame:self.bounds];
    tapGestureView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.7];
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
    
    UIButton *desmisBut = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 100, 44)];
    [desmisBut setTitle:@"取消" forState:UIControlStateNormal];
    [desmisBut setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [desmisBut addTarget:self action:@selector(desmisSelfVC) forControlEvents:UIControlEventTouchUpInside];
    [backgView addSubview:desmisBut];
    
    UIButton *confirmBut = [[UIButton alloc] initWithFrame:CGRectMake(size.width-KleftW-100, 20, 100, 44)];
    [confirmBut setTitle:@"确认" forState:UIControlStateNormal];
    [confirmBut setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [confirmBut setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [confirmBut addTarget:self action:@selector(confirmButClick) forControlEvents:UIControlEventTouchUpInside];
    [backgView addSubview:confirmBut];
    [confirmBut setEnabled:NO];
    self.confirmBut = confirmBut;
    [self.collectionView setFrame:CGRectMake(0, 64, size.width-KleftW, size.height-64)];
    [backgView addSubview:self.collectionView];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadUiWithFrame:frame.size];
    }
    return self;
}

- (void)setSelectArray:(NSArray *)selectArray
{
//    oneIndex = [self.dataSource selectIndexPath:0];
//    twoIndex = [self.dataSource selectIndexPath:1];
//    threeIndex = [self.dataSource selectIndexPath:2];
//    
//    if (oneIndex) {
//        [self.collectionView selectItemAtIndexPath:oneIndex animated:YES scrollPosition:UICollectionViewScrollPositionNone];
//    }
//    if (twoIndex) {
//        [self.collectionView selectItemAtIndexPath:twoIndex animated:YES scrollPosition:0];
//    }
//    //        if (threeIndex) {
//    [self.collectionView selectItemAtIndexPath:threeIndex animated:YES scrollPosition:0];
//    
//    if (oneIndex||twoIndex||threeIndex) {
//        [self.confirmBut setEnabled:YES];
//    }else{
//        [self.confirmBut setEnabled:NO];
//    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.titleLabel setText:self.titleText];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataSource numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dataSource numberOfItemsInSection:section];
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BiaoqainCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
//    [cell.titleLabel setText:[self.dataSource textCellForItemAtIndexPath:indexPath]];
    return cell;
}

#pragma mark - 代理方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath");
    switch (indexPath.section) {
        case 0:
            if (oneIndex) {
                [collectionView deselectItemAtIndexPath:oneIndex animated:NO];
            }
            oneIndex = indexPath;
            break;
        case 1:
            if (twoIndex) {
                [collectionView deselectItemAtIndexPath:twoIndex animated:NO];
            }
            twoIndex = indexPath;
            break;
        case 2:
            if (threeIndex) {
                [collectionView deselectItemAtIndexPath:threeIndex animated:NO];
            }
            threeIndex = indexPath;
            break;
        default:
            break;
    }
    if (oneIndex||twoIndex||threeIndex) {
        [self.confirmBut setEnabled:YES];
    }else{
        [self.confirmBut setEnabled:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didHighlightItemAtIndexPath");
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didDeselectItemAtIndexPath");
    switch (indexPath.section) {
        case 0:
            oneIndex = nil;
            break;
        case 1:
            twoIndex = nil;
            break;
        case 2:
            threeIndex = nil;
            break;
        default:
            break;
    }
    if (oneIndex||twoIndex||threeIndex) {
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
    if (self.shaixuanBlock) {
        self.shaixuanBlock(1);
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
