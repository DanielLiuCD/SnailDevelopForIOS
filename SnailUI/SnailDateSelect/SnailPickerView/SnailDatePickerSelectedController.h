//
//  SnailDatePickerSelectedController.h
//  YingKeBao
//
//  Created by 罗大侠 on 2019/1/22.
//  Copyright © 2019年 com.jonnew. All rights reserved.
//

#import "SnailAlertAnimationController.h"

#warning 现在只能选择日期

@interface SnailDatePickerSelectedController : SnailAlertAnimationController

@property (nonatomic ,strong) void(^block)(NSDate *date);
@property (nonatomic ,copy) NSDate *date;
@property (nonatomic ,copy) NSDate *maxDate;
@property (nonatomic ,copy) NSDate *minDate;
@property (nonatomic ,copy) NSString *formatorString;

@end
