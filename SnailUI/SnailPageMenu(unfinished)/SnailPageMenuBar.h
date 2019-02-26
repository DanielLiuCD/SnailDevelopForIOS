//
//  SnailPageMenuBar.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/25.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnailPageMenuUtil.h"

@interface SnailPageMenuItem : UIView

@property (nonatomic ,strong) UIButton *btn;
@property (nonatomic ,weak) SnailPageMenuItem *last;
@property (nonatomic ,weak) SnailPageMenuItem *next;

@end

@interface SnailPageMenuBar : UIView

- (void)defineUIWithConf:(SnailPageMenuBarConf *)conf;

@end
