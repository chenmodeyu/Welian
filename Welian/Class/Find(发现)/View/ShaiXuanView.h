//
//  ShaiXuanView.h
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ShaiXuanType) {
    ShaiXuanTypeProject,                  // 项目
    ShaiXuanTypeInvestorUser                // 投资人
};

typedef void (^CancelBlock)(void);
typedef void (^ShaiXuanBlock)(void);

@interface ShaiXuanView : UIView

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSString *titleText;

@property (nonatomic, copy) CancelBlock cancelBlock;

@property (nonatomic, copy) ShaiXuanBlock shaixuanBlock;

- (instancetype)initWithShaiXuanType:(ShaiXuanType)type;


- (void)showVC;

@end


//@protocol ShaiXuanViewDataSource <NSObject>
//
////- (NSIndexPath *)selectIndexPath:(NSInteger)section;
//// 多少组
//- (NSInteger)numberOfSections;
//// 每组多少个
//- (NSInteger)numberOfItemsInSection:(NSInteger)section;
//// 每组组头文字
//- (NSString *)titleWithSectionsTextatIndexPath:(NSIndexPath *)indexPath;
//
//- (NSString *)textCellForItemAtIndexPath:(NSIndexPath *)indexPath;
//
//@end
