//
//  SnailPageMenuBar.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/25.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailPageMenuBar.h"

@implementation SnailPageMenuItem

- (instancetype)init {
    self = [super init];
    if (self) {
        self.btn = [UIButton new];
        [self addSubview:self.btn];
        [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)configureWithConf:(SnailPageMenuBarItemConf *)conf {
    [self.btn setTitle:conf.text forState:UIControlStateNormal];
    [self.btn setTitleColor:conf.color forState:UIControlStateNormal];
    self.btn.titleLabel.font = conf.font;
}

@end

@interface SnailPageMenuBar()

@property (nonatomic ,strong) UIScrollView *scro;
@property (nonatomic ,strong) NSMutableArray<SnailPageMenuItem *> *items;
@property (nonatomic ,strong) CALayer *bottomLine;
@property (nonatomic ,strong) CALayer *indicator;

@end

@implementation SnailPageMenuBar

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.scro = [UIScrollView new];
        self.scro.showsVerticalScrollIndicator = false;
        self.scro.showsHorizontalScrollIndicator = false;
        [self addSubview:self.scro];
        [self.scro mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
    }
    return self;
}

- (void)defineUIWithConf:(SnailPageMenuBarConf *)conf {
    
    [self.items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.items removeAllObjects];
    [self.indicator removeFromSuperlayer];
    [self.bottomLine removeFromSuperlayer];
    
    SnailPageMenuItem *lastItem;
    for (NSInteger i = 0; i < conf.itemConfs.count; i++) {
        SnailPageMenuItem *item = [SnailPageMenuItem new];
        item.tag = i;
        [item configureWithConf:conf.itemConfs[i]];
        if (lastItem) {
            item.last = lastItem;
            lastItem.next = item;
        }
        [self.scro addSubview:item];
        lastItem = item;
    }
    
}

@end
