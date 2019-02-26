//
//  SnailCardShowView.m
//  SnailTanTanCard
//
//  Created by JobNewMac1 on 2018/7/18.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailCardShowView.h"

@implementation SnailCardShowCell

- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentView = [UIView new];
        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

@end
