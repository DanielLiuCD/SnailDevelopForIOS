//
//  SnailCalendarView.h
//  QianXun
//
//  Created by JobNewMac1 on 2018/12/6.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailGregoranCalendarDateInfo : NSObject

@property (nonatomic ,readonly) NSInteger month;
@property (nonatomic ,readonly) NSInteger year;
@property (nonatomic ,readonly) NSInteger day;
@property (nonatomic ,readonly) NSInteger weak;
@property (nonatomic ,copy ,readonly) NSDate *date;
@property (nonatomic ,copy ,readonly) NSString *weakString;
@property (nonatomic ,copy ,readonly) NSString *dateString;

@end

typedef NS_ENUM(NSInteger ,SnailGregoranCalendarAViewArea) {
    SnailGregoranCalendarAViewArea_Previous,
    SnailGregoranCalendarAViewArea_Current,
    SnailGregoranCalendarAViewArea_Next,
};

@interface SnailGregoranCalendarView : UIView

@property (nonatomic ,strong ,readonly) SnailGregoranCalendarDateInfo *currentInfo;
@property (nonatomic ,strong ,readonly) NSArray<SnailGregoranCalendarDateInfo *> *selectedDates;

@property (nonatomic ,strong) UIColor *disableColor;
@property (nonatomic ,strong) UIFont *disableFont;

@property (nonatomic ,strong) UIColor *normaleColor;
@property (nonatomic ,strong) UIFont *normaleFont;

@property (nonatomic ,strong) UIColor *selectedColor;
@property (nonatomic ,strong) UIFont *selectedFont;

@property (nonatomic ,strong) UIColor *titleBackgroundColor;
@property (nonatomic ,strong) UIColor *titleColor;
@property (nonatomic ,strong) UIFont *titleFont;

@property (nonatomic ,strong) UIColor *decorateFillColor;
@property (nonatomic ,strong) UIColor *decorateStrokeColor;

@property (nonatomic ,copy) BOOL (^shouldSelectedBlock)(SnailGregoranCalendarDateInfo *selectedDate);
@property (nonatomic ,copy) void(^didSelectedBlock)(SnailGregoranCalendarDateInfo *selectedDate);
@property (nonatomic ,copy) void(^didDeselectedBlock)(SnailGregoranCalendarDateInfo *selectedDate);
@property (nonatomic ,copy) void(^didSelectedDisableBlock)(SnailGregoranCalendarAViewArea area);
@property (nonatomic ,copy) void(^monthChangedBlock)(void);

- (void)go:(NSDate *)date;
- (void)nextMonth;
- (void)nextYear;
- (void)previousMonth;
- (void)previousYear;

@end

@interface SnailGregoranCalendarView(SNAILACTION)

///选择日期 用 yyyy-MM-dd 字符串的数组
- (void)selectedWithStringDates:(NSArray<NSString *> *)dates;

@end
