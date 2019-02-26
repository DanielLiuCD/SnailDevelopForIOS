//
//  SnailSimpleGuideController.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/12/17.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailSimpleGuideController.h"

@interface SnailSimpleGuideController ()<UIScrollViewDelegate>

@property (nonatomic ,strong) UIScrollView *scro;

@property (nonatomic) NSInteger count;
@property (nonatomic) NSInteger currentPage;

@end

@implementation SnailSimpleGuideController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scro = [UIScrollView new];
    self.scro.showsVerticalScrollIndicator = false;
    self.scro.showsHorizontalScrollIndicator = false;
    self.scro.bounces = false;
    if (@available(iOS 11.0 ,*)) self.scro.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    else self.automaticallyAdjustsScrollViewInsets = false;
    self.scro.frame = self.view.bounds;
    self.scro.pagingEnabled = true;
    self.scro.delegate = self;
    self.scro.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.scro];
    
    [self reload];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reload {
    
    [self.scro.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger count = self.numberOfImageBlock();
    self.count = count;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    for (int i = 0; i < count; i++) {
        x = i * width;
        UIView *vi = self.viewForIndexBlock(i);
        vi.frame = CGRectMake(x, y, width, height);
        vi.tag = i;
        [self.scro addSubview:vi];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        vi.userInteractionEnabled = true;
        [vi addGestureRecognizer:tap];
    }
    self.scro.contentSize = CGSizeMake(count * width, height);
    [self.scro setContentOffset:CGPointZero animated:false];
    
}

- (void)next {
    NSInteger index = self.currentPage + 1;
    if (index > self.count) return;
    [self.scro setContentOffset:CGPointMake(index * self.view.bounds.size.width, 0) animated:true];
}

- (void)previous {
    NSInteger index = self.currentPage - 1;
    if (index < 0) return;
    [self.scro setContentOffset:CGPointMake(index * self.view.bounds.size.width, 0) animated:true];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    self.didSelectedBlock(tap.view.tag);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / self.view.bounds.size.width;
    if (index != self.currentPage) {
        self.currentPage = index;
    }
}

@end
