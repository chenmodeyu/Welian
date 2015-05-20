//
//  ProjectBPViewCell.m
//  Welian
//
//  Created by weLian on 15/5/20.
//  Copyright (c) 2015年 chuansongmen. All rights reserved.
//

#import "ProjectBPViewCell.h"

#define kMarginLeft 15.f
#define kMarginEdge 10.f
#define kButtonWidth 60.f
#define kButtonHeight 30.f

@interface ProjectBPViewCell ()

@property (assign,nonatomic) UIImageView *iconImageView;
@property (assign,nonatomic) UILabel *fileNameLabel;
@property (assign,nonatomic) UIButton *getFileBtn;

@end

@implementation ProjectBPViewCell

- (void)dealloc
{
    _block = nil;
    _fineName = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setFineName:(NSString *)fineName
{
    [super willChangeValueForKey:@"fineName"];
    _fineName = fineName;
    [super didChangeValueForKey:@"fineName"];
    _fileNameLabel.text = _fineName;
}

- (void)setShowGetBPBtn:(BOOL)showGetBPBtn
{
    _showGetBPBtn = showGetBPBtn;
    _getFileBtn.hidden = !_showGetBPBtn;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_iconImageView sizeToFit];
    _iconImageView.left = kMarginLeft;
    _iconImageView.centerY = self.height / 2.f;
    
    _fileNameLabel.width = self.width - (_showGetBPBtn ? kButtonWidth + kMarginEdge : 0.f) - _iconImageView.right - kMarginLeft - kMarginEdge;
    [_fileNameLabel sizeToFit];
    _fileNameLabel.left = _iconImageView.right + kMarginEdge;
    _fileNameLabel.centerY = self.height / 2.f;
    
    _getFileBtn.size = CGSizeMake(kButtonWidth, kButtonHeight);
    _getFileBtn.right = self.width - kMarginLeft;
    _getFileBtn.centerY = self.height / 2.f;
    
    
}

#pragma mark - Private
- (void)setup
{
    //图标
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xiangmu_pdf"]];
    iconImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:iconImageView];
    self.iconImageView = iconImageView;
    
    //文件名字
    UILabel *fileNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    fileNameLabel.backgroundColor = [UIColor clearColor];
    fileNameLabel.font = kNormal14Font;
    fileNameLabel.textColor = KBlueTextColor;
    fileNameLabel.numberOfLines = 0.f;
    [self addSubview:fileNameLabel];
    self.fileNameLabel = fileNameLabel;
    
    //索要按钮
    UIButton *getFileBtn = [UIView getBtnWithTitle:@"我想查看" image:nil];
    [getFileBtn setTitleColor:KBlueTextColor forState:UIControlStateNormal];
    getFileBtn.backgroundColor = RGB(247.f, 247.f, 247.f);
    getFileBtn.layer.borderColor = kNormalLineColor.CGColor;
    getFileBtn.layer.borderWidth = 0.5f;
    [getFileBtn addTarget:self action:@selector(getFileBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    getFileBtn.hidden = YES;
    [self addSubview:getFileBtn];
    self.getFileBtn = getFileBtn;
}

- (void)getFileBtnClicked:(UIButton *)sender
{
    if (_block) {
        _block();
    }
}

@end
