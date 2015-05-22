//
//  ShaiXuanView.h
//  Welian
//
//  Created by dong on 15/5/22.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShaiXuanViewDataSource;


typedef void (^CancelBlock)(void);
typedef void (^ShaiXuanBlock)(NSInteger i);

@interface ShaiXuanView : UIView <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, weak) id<ShaiXuanViewDataSource> dataSource;

@property (nonatomic, strong) NSString *titleText;

@property (nonatomic, copy) CancelBlock cancelBlock;

@property (nonatomic, copy) ShaiXuanBlock shaixuanBlock;

@property (nonatomic, strong) NSArray *selectArray;

@property (nonatomic, strong) NSArray *dataArray;

- (void)showVC;

@end


@protocol ShaiXuanViewDataSource <NSObject>

- (NSIndexPath *)selectIndexPath:(NSInteger)section;
// 多少组
- (NSInteger)numberOfSections;
// 每组多少个
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
// 每组组头文字
- (NSString *)titleWithSectionsTextatIndexPath:(NSIndexPath *)indexPath;

- (NSString *)textCellForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
