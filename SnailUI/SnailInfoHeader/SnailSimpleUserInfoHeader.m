//
//  SnailSimpleUserInfoHeader.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/21.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailSimpleUserInfoHeader.h"

@interface SnailSimpleUserInfoHeader()

@property (nonatomic ,strong) UIImageView *bc;
@property (nonatomic ,strong) UIImageView *head;
@property (nonatomic ,strong) UILabel *name;

@end

@implementation SnailSimpleUserInfoHeader

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.bc = [UIImageView new];
        
        self.head = [UIImageView new];
        self.head.userInteractionEnabled = true;
        
        self.name = [UILabel new];
        self.name.textAlignment = NSTextAlignmentCenter;
        self.name.font = SNAS_SYS_FONT(17);
        self.name.textColor = SNA_HEX_COLOR(0x1b1b1b);
        self.name.numberOfLines = 0;
        
        [self snail_addSubviews:@[self.bc,self.head,self.name]];
        
        [self.bc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.head mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-7.5);
            make.size.mas_equalTo(CGSizeMake(0, 0));
        }];
        
        [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.leading.equalTo(self).offset(15);
            make.top.equalTo(self.head.mas_bottom).offset(15);
        }];
        
        self.headWidth = 100;
        
    }
    return self;
}

- (void)setHeadWidth:(CGFloat)headWidth {
    _headWidth = headWidth;
    self.head.snail_corner(headWidth / 2.0);
    [self.head mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(headWidth, headWidth));
        make.centerY.equalTo(self).offset(- headWidth / 2.0 + 15);
    }];
}

@end
