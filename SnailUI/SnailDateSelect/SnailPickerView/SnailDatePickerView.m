//
//  SnailDatePickerView.m
//  YingKeBao
//
//  Created by 罗大侠 on 2019/1/22.
//  Copyright © 2019年 com.jonnew. All rights reserved.
//

#import "SnailDatePickerView.h"

@interface SnailDatePickerView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic ,strong) UIPickerView *picker;

@property (nonatomic ,strong) NSDateFormatter *dateForamator;

@property (nonatomic ,strong) NSDictionary *disableAttrbute;
@property (nonatomic ,strong) NSDictionary *enableAttrbute;

@property (nonatomic ,strong) NSMutableArray *dates;
@property (nonatomic ,strong) NSMutableArray<NSAttributedString *> *dateAttributes;
@property (nonatomic ,strong) NSMutableArray<NSValue *> *dateEnables;

@property (nonatomic) NSInteger minDateRow;
@property (nonatomic) NSInteger maxDateRow;

@end

@implementation SnailDatePickerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.picker = [UIPickerView new];
        self.picker.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.picker.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.picker.delegate = self;
        self.picker.dataSource = self;
        
        [self addSubview:self.picker];
        
        _locale = [NSLocale currentLocale];
        _calendar = [NSCalendar currentCalendar];
        _date = [NSDate date];
        _formatorString = @"yyyy-MM-dd";
        
        self.disableAttrbute = @{
                                 NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleCallout],
                                 NSForegroundColorAttributeName:[UIColor grayColor]
                                 };
        
        self.enabled = @{
                                 NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleCallout],
                                 NSForegroundColorAttributeName:[UIColor blackColor]
                                 };
        
        self.dateForamator = [NSDateFormatter new];
        self.dateForamator.locale = _locale;
        self.dateForamator.calendar = _calendar;
        self.dateForamator.dateFormat = _formatorString;
        
        [self refeshDates];
        
    }
    return self;
}

- (void)refeshDates {
    
    self.minDateRow = -1;
    self.maxDateRow = -1;
    
    [self.dates removeAllObjects];
    [self.dateAttributes removeAllObjects];
    [self.dateEnables removeAllObjects];
    
    NSTimeInterval oneDayTime = 24 * 60 * 60;
    for (int i = 0; i < 10000; i++) {
        
        NSDate *newDate = [self.date dateByAddingTimeInterval:oneDayTime * (-5000 + i)];
        NSString *str = [self.dateForamator stringFromDate:newDate];
        
        NSDictionary *attr = self.enableAttrbute;
        BOOL enable = true;
        
        NSTimeInterval miniTimeOffset = 0;
        NSTimeInterval maxTimeOffset = 0;
        
        if (self.minDate) {
            miniTimeOffset = (NSInteger)[self.minDate timeIntervalSinceDate:newDate];
            if (miniTimeOffset < 0) {
                attr = self.disableAttrbute;
                enable = false;
            }
            else if (miniTimeOffset == 0) {
                self.minDateRow = i;
            }
        }
        if (self.maxDate) {
            maxTimeOffset = (NSInteger)[newDate timeIntervalSinceDate:self.maxDate];
            if (maxTimeOffset > 0) {
                attr = self.disableAttrbute;
                enable = false;
            }
            else if (maxTimeOffset == 0) {
                self.maxDateRow = i;
            }
        }
        
        NSAttributedString *attriString = [[NSAttributedString alloc] initWithString:str attributes:attr];
        
        [self.dates addObject:newDate];
        [self.dateAttributes addObject:attriString];
        [self.dateEnables addObject:@(enable)];
        
    }
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.picker selectRow:5000 inComponent:0 animated:false];
    }];
    [self.picker reloadAllComponents];
    [CATransaction commit];
    
}

- (NSString *)dateString {
    return [self.dateAttributes[[self.picker selectedRowInComponent:0]] string];
}

- (NSMutableArray *)dates {
    if (!_dates) {
        _dates = [NSMutableArray new];
    }
    return _dates;
}

- (NSMutableArray<NSAttributedString *> *)dateAttributes {
    if (!_dateAttributes) {
        _dateAttributes = [NSMutableArray new];
    }
    return _dateAttributes;
}

- (NSMutableArray<NSValue *> *)dateEnables {
    if (!_dateEnables) {
        _dateEnables = [NSMutableArray new];
    }
    return _dateEnables;
}

- (void)setDate:(NSDate *)date {
    if (![_date isEqualToDate:date]) {
        _date = date;
        [self refeshDates];
    }
}

- (void)setMaxDate:(NSDate *)maxDate {
    if (![_maxDate isEqualToDate:maxDate]) {
        _maxDate = maxDate;
        [self refeshDates];
    }
}

- (void)setMinDate:(NSDate *)minDate {
    if (![_minDate isEqualToDate:minDate]) {
        _minDate = minDate;
        [self refeshDates];
    }
}

- (void)setLocale:(NSLocale *)locale {
    _locale = locale;
    self.dateForamator.locale = locale;
    [self refeshDates];
}

- (void)setCalendar:(NSCalendar *)calendar {
    _calendar = calendar;
    self.dateForamator.calendar = calendar;
    [self refeshDates];
}

- (void)setFormatorString:(NSString *)formatorString {
    _formatorString = formatorString;
    self.dateForamator.dateFormat = formatorString;
    [self refeshDates];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 45.f;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dates.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.dateAttributes[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    [CATransaction begin];
    
    if (self.minDateRow > 0 && row < self.minDateRow) {
        [self.picker selectRow:self.minDateRow inComponent:0 animated:true];
    }
    else if (self.maxDateRow > 0 && row > self.maxDateRow) {
        [self.picker selectRow:self.maxDateRow inComponent:0 animated:true];
    }
    
    [CATransaction setCompletionBlock:^{
        self->_date = [self.dates objectAtIndex:row];
    }];
    
    [CATransaction commit];
    
}

@end
