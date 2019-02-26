//
//  SnailDateSectionSelectedController.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/11/30.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailAlertAnimationController.h"

@interface SnailDateSectionSelectedController : SnailAlertAnimationController

@property (nonatomic ,strong) void(^block)(NSDate *startDate ,NSDate *endDate);
@property (nonatomic) UIDatePickerMode startDateMode;
@property (nonatomic) UIDatePickerMode endDateMode;
@property (nonatomic ,copy) NSDate *startDate;
@property (nonatomic ,copy) NSDate *endDate;
@property (nonatomic) BOOL errorCorrection; //default is yes

@end
