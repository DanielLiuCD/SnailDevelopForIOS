//
//  SnailDatePickerView.h
//  YingKeBao
//
//  Created by 罗大侠 on 2019/1/22.
//  Copyright © 2019年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

#warning 现在只能选择日期

@interface SnailDatePickerView : UIControl

@property (nonatomic ,strong) NSDate *date;
@property (nonatomic ,strong) NSDate *maxDate;
@property (nonatomic ,strong) NSDate *minDate;

@property (nonatomic ,strong) NSLocale *locale;
@property (nonatomic ,strong) NSCalendar *calendar;

@property (nonatomic ,strong) NSString *formatorString;
@property (nonatomic ,readonly) NSString *dateString;

@end
