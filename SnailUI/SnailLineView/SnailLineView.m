//
//  SnailLineView.m
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2018/12/29.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailLineView.h"

@interface SnailLineView()

@property (nonatomic ,strong) UIView *sna_left_line;
@property (nonatomic ,strong) UIView *sna_right_line;
@property (nonatomic ,strong) UIView *sna_top_line;
@property (nonatomic ,strong) UIView *sna_bottom_line;

@end

@implementation SnailLineView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.lineWidth = 1.0;
        self.lineColor = [UIColor groupTableViewBackgroundColor];
        
        self.sna_top_line = [UIView new];
        self.sna_left_line = [UIView new];
        self.sna_right_line = [UIView new];
        self.sna_bottom_line = [UIView new];
        
        [self addSubview:self.sna_top_line];
        [self addSubview:self.sna_left_line];
        [self addSubview:self.sna_right_line];
        [self addSubview:self.sna_bottom_line];
        
        [self.sna_top_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.leading.top.equalTo(self);
            make.height.mas_equalTo(1);
        }];
        [self.sna_bottom_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.leading.bottom.equalTo(self);
            make.height.mas_equalTo(1);
        }];
        [self.sna_left_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.leading.top.equalTo(self);
            make.width.mas_equalTo(1);
        }];
        [self.sna_right_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.trailing.top.equalTo(self);
            make.width.mas_equalTo(1);
        }];
        
        [self refesh];
        
    }
    return self;
}

- (void)refesh {
    
    if (self.lineType & SnailLineViewTypeTop) {
        self.sna_top_line.hidden = false;
        self.sna_top_line.backgroundColor = self.lineColor;
        [self.sna_top_line mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.lineWidth);
        }];
    }
    else {
        self.sna_top_line.hidden = true;
    }
    
    if (self.lineType & SnailLineViewTypeBottom) {
        self.sna_bottom_line.hidden = false;
        self.sna_bottom_line.backgroundColor = self.lineColor;
        [self.sna_bottom_line mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.lineWidth);
        }];
    }
    else {
        self.sna_bottom_line.hidden = true;
    }
    
    if (self.lineType & SnailLineViewTypeLeft) {
        self.sna_left_line.hidden = false;
        self.sna_left_line.backgroundColor = self.lineColor;
        [self.sna_left_line mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.lineWidth);
        }];
    }
    else {
        self.sna_left_line.hidden = true;
    }
    
    if (self.lineType & SnailLineViewTypeRight) {
        self.sna_right_line.hidden = false;
        self.sna_right_line.backgroundColor = self.lineColor;
        [self.sna_right_line mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.lineWidth);
        }];
    }
    else {
        self.sna_right_line.hidden = true;
    }
    
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [self refesh];
}

- (void)setLineType:(SnailLineViewType)lineType {
    _lineType = lineType;
    [self refesh];
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
    [self refesh];
}

@end
