//
//  SnailDateSelectedController.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/2.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailAlertAnimationController.h"

@interface SnailDateSelectedController : SnailAlertAnimationController

@property (nonatomic ,strong) void(^block)(NSDate *date);
@property (nonatomic) UIDatePickerMode dateMode;
@property (nonatomic ,copy) NSDate *date;
@property (nonatomic ,copy) NSDate *minDate;
@property (nonatomic ,copy) NSDate *maxDate;
@property (nonatomic ,strong) NSLocale *locale;

@end
