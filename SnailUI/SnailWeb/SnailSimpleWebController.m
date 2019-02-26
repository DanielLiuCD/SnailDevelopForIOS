//
//  SnailSimpleWebController.m
//  lesan
//
//  Created by JobNewMac1 on 2018/8/20.
//  Copyright © 2018年 ning. All rights reserved.
//

#import "SnailSimpleWebController.h"
@import WebKit;

@interface SnailSimpleWebController ()

kSPrStrong(WKWebView *web)
kSPrStrong(UIProgressView *pres)

@end

@implementation SnailSimpleWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)snailConfigureUI {
    
    self.web = [WKWebView new];
    [self.web addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    self.pres = [UIProgressView new];
    
    [self.view addSubview:self.web];
    [self.view addSubview:self.pres];
    [self.web mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.pres mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.leading.equalTo(self.view);
        if (@available(iOS 11.0,*))  make.top.equalTo(self.mas_topLayoutGuide);
        else make.top.equalTo(self.view);
    }];
    
}

- (void)snailFirstAction {
    
    [self.web loadRequest:[NSURLRequest requestWithURL:self.url]];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqual:@"estimatedProgress"] && object == self.web) {
        [self.pres setAlpha:1.0f];
        [self.pres setProgress:self.web.estimatedProgress animated:YES];
        if (self.web.estimatedProgress  >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.pres setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.pres setProgress:0.0f animated:YES];
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc{
    [self.web removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
