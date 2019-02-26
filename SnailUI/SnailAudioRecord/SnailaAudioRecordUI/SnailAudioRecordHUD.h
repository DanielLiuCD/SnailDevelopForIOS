//
//  SnailAudioRecordHUD.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/10.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnailAudioHeader.h"

@interface SnailAudioRecordHUD : UIView

- (void)showOnView:(UIView *)view;
- (void)showLevel:(SnailAudioRecordLevel)level Text:(NSString *)text;
- (void)showWaraing:(NSString *)text;

- (void)showCancle:(NSString *)text;

/* 下面两个必须成对调用 begin 锁定UI变化 end 解开锁定*/
- (void)beginLockUI;
- (void)endLockUI;

- (void)hidden;
- (void)hiddenDelay:(NSTimeInterval)time;

@end
