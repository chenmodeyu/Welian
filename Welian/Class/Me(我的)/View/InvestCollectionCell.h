//
//  InvestCollectionCell.h
//  Welian
//
//  Created by dong on 14/12/27.
//  Copyright (c) 2014年 chuansongmen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvestCollectionCell : UICollectionViewCell
{
     BOOL			m_checked;
}
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UILabel *titeLabel;

- (void)setChecked:(BOOL)checked;

@end
