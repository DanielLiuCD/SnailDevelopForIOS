//
//  SnailCalendarView.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/12/6.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailGregoranCalendarView.h"

#define DecorateIndexsKey @"DecorateIndexsKey"
#define DecorateDatasKey @"DecorateDatasKey"

@interface SnailGregoranCalendarDateInfo()

@property (nonatomic) NSInteger month;
@property (nonatomic) NSInteger year;
@property (nonatomic) NSInteger day;
@property (nonatomic ) NSInteger weak;
@property (nonatomic ,copy) NSDate *date;
@property (nonatomic ,copy) NSString *weakString;
@property (nonatomic ,copy) NSString *dateString;

@end

@implementation SnailGregoranCalendarDateInfo

@end

@interface _SnailGregoranCalendarMonthInfo : NSObject

@property (nonatomic) uint8_t month;
@property (nonatomic) unsigned long year;
@property (nonatomic) uint8_t firstDayWeakOfMonth; //这个月的第一天是周几
@property (nonatomic) uint8_t dayC;

@end

@implementation _SnailGregoranCalendarMonthInfo

@end

@interface SnailGregoranCalendarView()

@property (nonatomic ,strong) CALayer *titleLayer;
@property (nonatomic ,strong) UIScrollView *scro;
@property (nonatomic ,strong) CALayer *infoLayer;
@property (nonatomic ,strong) CAShapeLayer *decorateLayer;

@property (nonatomic ,strong) NSDate *currentDate;
@property (nonatomic ,strong) NSCalendar *calendar;
@property (nonatomic ,strong) SnailGregoranCalendarDateInfo *currentInfo;

@property (nonatomic ,strong) NSMutableArray *mothInfos;

@property (nonatomic ,strong) NSMutableArray *rects;

@property (nonatomic ,strong) NSLock *lock;

@property (nonatomic ,strong) UITapGestureRecognizer *tapGes;

@property (nonatomic ,strong) NSMutableArray *pselectedDates;
@property (nonatomic ,strong) NSMutableDictionary *_selectedDateIndexDic;

@property (nonatomic ,strong) NSMutableDictionary<NSString *,NSMutableDictionary *> *decorates;

@end

@implementation SnailGregoranCalendarView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.normaleColor = [UIColor blueColor];
        self.normaleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        self.selectedColor = [UIColor whiteColor];
        self.selectedFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        self.disableColor = [UIColor grayColor];
        self.disableFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        self.titleColor = [UIColor blackColor];
        self.titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        self.titleBackgroundColor = [UIColor groupTableViewBackgroundColor];
        
        self.decorateFillColor = [UIColor blueColor];
        self.decorateStrokeColor = [UIColor redColor];
        
        self.titleLayer = [CALayer new];
        self.titleLayer.contentsScale = UIScreen.mainScreen.scale;
        
        self.scro = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scro.pagingEnabled = true;
        self.scro.showsHorizontalScrollIndicator = false;
        self.scro.showsVerticalScrollIndicator = false;
        self.scro.scrollEnabled = false;
        
        self.infoLayer = [CALayer new];
        self.infoLayer.contentsScale = UIScreen.mainScreen.scale;
        
        self.decorateLayer = [CAShapeLayer layer];
        self.decorateLayer.lineWidth = 1.0;
        
        [self.layer addSublayer:self.titleLayer];
        [self addSubview:self.scro];
        [self.scro.layer addSublayer:self.decorateLayer];
        [self.scro.layer addSublayer:self.infoLayer];

        [self go:[NSDate date]];
        
        self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:self.tapGes];
    
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    
    self.titleLayer.frame = CGRectMake(0, 0, frame.size.width, 25);
    
    self.scro.frame = CGRectMake(0, 25 + 15, frame.size.width, frame.size.height - 25 - 15 - 15);
    self.scro.contentSize = CGSizeMake(frame.size.width * 3, frame.size.height - 25 - 15 - 15);
    [self.scro setContentOffset:CGPointMake(frame.size.width, 0) animated:false];
    
    self.infoLayer.frame = CGRectMake(0, 0, frame.size.width * 3, self.scro.frame.size.height);
    
    [self refeshTitleLayer];
    [self goRefesh];
    
}

- (void)tapAction:(UITapGestureRecognizer *)ges {
    
    NSInteger selectedMonth = -1;
    NSInteger selectedArea = -1;
    NSInteger selectedDay = -1;
    CGRect selectedRect = CGRectZero;
    
    BOOL selected = false;
    
    CGPoint point = [ges locationInView:self.scro];
    for (int i = 0; i < self.rects.count; i++) {
        NSArray *array = self.rects[i];
        for (int j = 0; j < 3; j++) {
            NSArray *tmp = array[j];
            for (int k = 0; k < tmp.count; k++) {
                CGRect rect = [tmp[k] CGRectValue];
                if (CGRectContainsPoint(rect, point)) {
                    selectedMonth = i;
                    selectedArea = j;
                    selectedDay = k;
                    selected = true;
                    selectedRect = rect;
                    break;
                }
            }
        }
        
    }
    
    if (selected) {
        if (selectedArea == 0 || selectedArea == 2) {
            if (self.didSelectedDisableBlock) {
                SnailGregoranCalendarAViewArea area = SnailGregoranCalendarAViewArea_Previous;
                if (selectedArea == 0) area = SnailGregoranCalendarAViewArea_Previous;
                else if (selectedArea == 2) area = SnailGregoranCalendarAViewArea_Next;
                self.didSelectedDisableBlock(area);
            }
        }
        else if (selectedArea == 1) {
            
            _SnailGregoranCalendarMonthInfo *month = self.mothInfos[selectedMonth];
            
            NSInteger year = month.year;
            NSInteger monthI = month.month;
            NSInteger day = selectedDay + 1;
            
            NSString *key = [NSString stringWithFormat:@"%ld-%ld-%ld",year,monthI,day];
            NSString *decoratekey = [NSString stringWithFormat:@"%ld-%ld",year,monthI];
            
            NSMutableDictionary *decorateInfo = [self takeDecorateInfo:decoratekey];
            NSMutableDictionary *decorateIndexInfo = decorateInfo[DecorateIndexsKey];
            if (!decorateIndexInfo) {
                decorateIndexInfo = [NSMutableDictionary new];
                decorateInfo[DecorateIndexsKey] = decorateIndexInfo;
            }
            NSMutableArray *decorateDatas = decorateInfo[DecorateDatasKey];
            if (!decorateDatas) {
                decorateDatas = [NSMutableArray new];
                decorateInfo[DecorateDatasKey] = decorateDatas;
            }
            
            if (self._selectedDateIndexDic[key]) {
                [self.lock lock];
                SnailGregoranCalendarDateInfo *dateInfo = self._selectedDateIndexDic[key];
                NSValue *value = decorateIndexInfo[key];
                [self.pselectedDates removeObject:dateInfo];
                [decorateDatas removeObject:value];
                self._selectedDateIndexDic[key] = nil;
                decorateIndexInfo[key] = nil;
                [self.lock unlock];
                if (self.didDeselectedBlock) self.didDeselectedBlock(dateInfo);
                [self goRefesh];
            }
            else {
                
                SnailGregoranCalendarDateInfo *dateInfo = [SnailGregoranCalendarDateInfo new];
                dateInfo.year = year;
                dateInfo.month = monthI;
                dateInfo.day = day;
                
                NSDateComponents *datecomponts = [NSDateComponents new];
                datecomponts.year = year;
                datecomponts.month = monthI;
                datecomponts.day = day;
                
                dateInfo.date = [self.calendar dateFromComponents:datecomponts];
                
                NSDateComponents *tmpcomponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:dateInfo.date];
                NSInteger weekDay = [tmpcomponents weekday] - 1;
                
                dateInfo.weak = weekDay;
                dateInfo.weakString = [NSLocalizedString(@"日,一,二,三,四,五,六", nil) componentsSeparatedByString:@","][weekDay];
                
                NSDateFormatter *dataFormant = [[NSDateFormatter alloc] init];
                [dataFormant setDateFormat: @"yyyy-MM-dd"];
                
                dateInfo.dateString = [dataFormant stringFromDate:dateInfo.date];
                
                BOOL shouldSelected = true;
                if (self.shouldSelectedBlock) shouldSelected = self.shouldSelectedBlock(dateInfo);
                
                if (shouldSelected) {
                    [self.lock lock];
                    
                    CGPoint point = CGPointMake(CGRectGetMidX(selectedRect), CGRectGetMidY(selectedRect));
                    NSValue *pvalue = [NSValue valueWithCGPoint:point];
                    
                    self._selectedDateIndexDic[key] = dateInfo;
                    [self.pselectedDates addObject:dateInfo];
                    
                    decorateIndexInfo[key] = pvalue;
                    [decorateDatas addObject:pvalue];
                    
                    [self.lock unlock];
                    
                    if (self.didSelectedBlock) self.didSelectedBlock(dateInfo);
                    
                    [self goRefesh];
                }
                
            }
        }
    }
    
}

- (void)refeshTitleLayer {
    
    CGSize size = self.titleLayer.bounds.size;
    UIGraphicsBeginImageContextWithOptions(self.titleLayer.bounds.size, false, UIScreen.mainScreen.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.titleBackgroundColor setFill];
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    
    NSMutableParagraphStyle *paty = [NSMutableParagraphStyle new];
    paty.alignment = NSTextAlignmentCenter;
    
    NSDictionary *normalAttri = @{NSFontAttributeName:self.titleFont,NSForegroundColorAttributeName:self.titleColor,NSParagraphStyleAttributeName:paty};
    
    CGFloat height = self.titleFont.lineHeight;
    CGFloat y = (25 - height) * .5;
    CGFloat width = size.width / 7.0;
    [[NSLocalizedString(@"日,一,二,三,四,五,六", nil) componentsSeparatedByString:@","] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj drawInRect:CGRectMake(idx * width, y, width, height) withAttributes:normalAttri];
    }];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    self.titleLayer.contents = (__bridge id _Nullable)img.CGImage;
    
    UIGraphicsEndImageContext();
    
}

- (void)go:(NSDate *)date {
    if (![self.currentDate isEqualToDate:date]) {
        
        self.currentDate = date;
        
        _SnailGregoranCalendarMonthInfo *now = [self takeMonthInfo:date];
        
        NSDateComponents *datecompents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
        
        datecompents.month -= 1;
        NSDate *lastDate = [self.calendar dateFromComponents:datecompents];
        _SnailGregoranCalendarMonthInfo *previous = [self takeMonthInfo:lastDate];
        
        datecompents.month += 2;
        NSDate *nextDate = [self.calendar dateFromComponents:datecompents];
        _SnailGregoranCalendarMonthInfo *next = [self takeMonthInfo:nextDate];
        
        self.mothInfos[0] = previous;
        self.mothInfos[1] = now;
        self.mothInfos[2] = next;
        
        [self goRefesh];
    }
}

- (void)goRefesh {
    NSValue *value = [NSValue valueWithCGRect:self.scro.bounds];
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(refeshInfo:) object:nil];
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(refeshDecorate:) object:nil];
    [NSThread detachNewThreadSelector:@selector(refeshInfo:) toTarget:self withObject:value];
    [NSThread detachNewThreadSelector:@selector(refeshDecorate:) toTarget:self withObject:value];
}

- (void)refeshDecorate:(NSValue *)value {
    
    CGRect bounds = [value CGRectValue];
    
    CGFloat vSpaceing = 15;
    CGFloat height = (bounds.size.height - vSpaceing * 5) / 6.0;
    CGFloat radius = height * .5;
    
    NSString *decoratekey = [NSString stringWithFormat:@"%ld-%ld",self.currentInfo.year,self.currentInfo.month];
    
    NSMutableDictionary *decorateInfo = [self takeDecorateInfo:decoratekey];
    NSMutableArray *decorateDatas = decorateInfo[DecorateDatasKey];
    if (!decorateDatas) {
        decorateDatas = [NSMutableArray new];
        decorateInfo[DecorateDatasKey] = decorateDatas;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [decorateDatas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIBezierPath *tmp = [UIBezierPath bezierPath];
        CGPoint point = [obj CGPointValue];
        [tmp addArcWithCenter:point radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:false];
        [path appendPath:tmp];
    }];
    [self performSelectorOnMainThread:@selector(_refeshDecorate:) withObject:path waitUntilDone:false];
    
}

- (void)_refeshDecorate:(UIBezierPath *)path {
    self.decorateLayer.strokeColor = self.decorateStrokeColor.CGColor;
    self.decorateLayer.fillColor = self.decorateFillColor.CGColor;
    self.decorateLayer.path = path.CGPath;
}

- (void)refeshInfo:(NSValue *)value {
    
    CGRect bounds = [value CGRectValue];
    
    CGFloat vSpaceing = 15;
    CGFloat height = (bounds.size.height - vSpaceing * 5) / 6.0;
    CGFloat width = floor(bounds.size.width / 7.0);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(bounds.size.width * 3, bounds.size.height), false, UIScreen.mainScreen.scale);
    
    NSMutableParagraphStyle *paty = [NSMutableParagraphStyle new];
    paty.alignment = NSTextAlignmentCenter;
    
    NSDictionary *normalAttri = @{NSFontAttributeName:self.normaleFont,NSForegroundColorAttributeName:self.normaleColor,NSParagraphStyleAttributeName:paty};
    NSDictionary *selectedAttri = @{NSFontAttributeName:self.selectedFont,NSForegroundColorAttributeName:self.selectedColor,NSParagraphStyleAttributeName:paty};
    NSDictionary *disableAttri = @{NSFontAttributeName:self.disableFont,NSForegroundColorAttributeName:self.disableColor,NSParagraphStyleAttributeName:paty};
    
    NSMutableArray *tmpRects = [NSMutableArray new];
    
    NSInteger infoCount = self.mothInfos.count;
    for (int i = 0; i < infoCount; i++) {
        _SnailGregoranCalendarMonthInfo *previous = nil;
        _SnailGregoranCalendarMonthInfo *next = nil;
        if (i - 1 >= 0) {
            previous = self.mothInfos[i-1];
        }
        if (i + 1 < infoCount) {
            next = self.mothInfos[i+1];
        }
        NSArray *arrays = [self drawMonthInfo:self.mothInfos[i] :previous :next :i * bounds.size.width :width :height :vSpaceing :normalAttri :selectedAttri :disableAttri];
        [tmpRects addObject:arrays];
    }
    
    [self.lock lock];
    self.rects = tmpRects;
    [self.lock unlock];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self performSelectorOnMainThread:@selector(_refeshInfo:) withObject:img waitUntilDone:false];
}

- (void)_refeshInfo:(UIImage *)img {
    self.infoLayer.contents = (__bridge id _Nullable)img.CGImage;
}

- (NSArray *)drawMonthInfo:(_SnailGregoranCalendarMonthInfo *)info :(_SnailGregoranCalendarMonthInfo *)previous :(_SnailGregoranCalendarMonthInfo *)next :(CGFloat)startX :(CGFloat)width :(CGFloat)height :(CGFloat)vSpaceing :(NSDictionary *)normalAttri :(NSDictionary *)selectedAttri :(NSDictionary *)disableAttri {
    
    CGFloat x = .0f;
    CGFloat y = .0f;
    NSInteger firstDayWeak = info.firstDayWeakOfMonth;
    NSInteger totalDay = info.dayC;
    
    CGFloat normaleLineHeight = [normalAttri[NSFontAttributeName] lineHeight];
    CGFloat selectedLineHeight = [selectedAttri[NSFontAttributeName] lineHeight];
    CGFloat disableLineHeight = [disableAttri[NSFontAttributeName] lineHeight];
    
    NSInteger previousTotalDay = previous.dayC;
    
    NSMutableArray *tmpArys = [NSMutableArray new];
    NSMutableArray *previousDisableArys = [NSMutableArray new];
    NSMutableArray *nextDisableArys = [NSMutableArray new];
    
    for (int i = 0; i < 6; i++) {
        y = i * (height + vSpaceing);
        for (int j = 0; j < 7; j++) {
            int index = i * 7 + j;
            x = startX + j * width;
            CGRect rect = CGRectMake(x, y, width, height);
            if (index >= firstDayWeak && (index + 1) <= (totalDay + firstDayWeak)) {
                NSString *str = [NSString stringWithFormat:@"%ld",index + 1 - firstDayWeak];
                NSString *key = [NSString stringWithFormat:@"%ld-%hhu-%@",info.year,info.month,str];
                NSDictionary *attr = normalAttri;
                CGRect txRect = CGRectMake(rect.origin.x, y + (rect.size.height - normaleLineHeight) * .5, rect.size.width, normaleLineHeight);
                if (self._selectedDateIndexDic[key]) {
                    attr = selectedAttri;
                    txRect = CGRectMake(rect.origin.x, y + (rect.size.height - selectedLineHeight) * .5, rect.size.width, selectedLineHeight);
                }
                [str drawInRect:txRect withAttributes:attr];
                [tmpArys addObject:[NSValue valueWithCGRect:rect]];
            }
            else if (index < firstDayWeak && previous) {
                NSString *str = [NSString stringWithFormat:@"%ld",previousTotalDay - (firstDayWeak - index) + 1];
                CGRect txRect = CGRectMake(rect.origin.x, y + (rect.size.height - disableLineHeight) * .5, rect.size.width, disableLineHeight);
                [str drawInRect:txRect withAttributes:disableAttri];
                [previousDisableArys addObject:[NSValue valueWithCGRect:rect]];
            }
            else if ((index + 1) > (totalDay + firstDayWeak) && next) {
                NSString *str = [NSString stringWithFormat:@"%ld",index + 1 - (totalDay + firstDayWeak) ];
                CGRect txRect = CGRectMake(rect.origin.x, y + (rect.size.height - disableLineHeight) * .5, rect.size.width, disableLineHeight);
                [str drawInRect:txRect withAttributes:disableAttri];
                [nextDisableArys addObject:[NSValue valueWithCGRect:rect]];
            }
        }
    }
    
    return @[previousDisableArys.copy,tmpArys.copy,nextDisableArys.copy];
    
}

- (void)previousMonth {
    NSDateComponents *datecompents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self.currentDate];
    datecompents.month -= 2;
    NSDate *lastDate = [self.calendar dateFromComponents:datecompents];
    _SnailGregoranCalendarMonthInfo *previous = [self takeMonthInfo:lastDate];
    [self.mothInfos insertObject:previous atIndex:0];
    [self.mothInfos removeLastObject];
    
    NSDateComponents *tmpDatecompents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self.currentDate];
    tmpDatecompents.month -= 1;
    NSDate *currentDate = [self.calendar dateFromComponents:tmpDatecompents];
    
    self.currentDate = currentDate;
    [self goRefesh];
    if (self.monthChangedBlock) self.monthChangedBlock();
}

- (void)nextMonth {
    NSDateComponents *datecompents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self.currentDate];
    datecompents.month += 2;
    NSDate *nextDate = [self.calendar dateFromComponents:datecompents];
    _SnailGregoranCalendarMonthInfo *next = [self takeMonthInfo:nextDate];
    [self.mothInfos addObject:next];
    [self.mothInfos removeObjectAtIndex:0];
    
    NSDateComponents *tmpDatecompents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self.currentDate];
    tmpDatecompents.month += 1;
    NSDate *currentDate = [self.calendar dateFromComponents:tmpDatecompents];
    
    self.currentDate = currentDate;

    [self goRefesh];
    if (self.monthChangedBlock) self.monthChangedBlock();
}

- (void)previousYear {
    NSDateComponents *datecompents = [NSDateComponents new];
    datecompents.year = -1;
    NSDate *tmpDate = [self.calendar dateByAddingComponents:datecompents toDate:self.currentDate options:0];
    [self go:tmpDate];
}

- (void)nextYear {
    NSDateComponents *datecompents = [NSDateComponents new];
    datecompents.year = +1;
    NSDate *tmpDate = [self.calendar dateByAddingComponents:datecompents toDate:self.currentDate options:0];
    [self go:tmpDate];
}

- (_SnailGregoranCalendarMonthInfo *)takeMonthInfo:(NSDate *)date {
    
    NSDateComponents *datecompents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    _SnailGregoranCalendarMonthInfo *month = [_SnailGregoranCalendarMonthInfo new];
    month.year = datecompents.year;
    month.month = datecompents.month;
    month.dayC = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    
    datecompents.day = 1;
    NSDate *tmpDate = [self.calendar dateFromComponents:datecompents];
    NSDateComponents *tmpDatecompents = [self.calendar components:NSCalendarUnitWeekday fromDate:tmpDate];
    month.firstDayWeakOfMonth = tmpDatecompents.weekday - 1;
    
    return month;
}

- (NSMutableDictionary *)takeDecorateInfo:(NSString *)key {
    NSMutableDictionary *tmp = self.decorates[key];
    if (!tmp) {
        tmp = [NSMutableDictionary new];
        self.decorates[key] = tmp;
    }
    return tmp;
}

- (NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [_calendar setLocale:[NSLocale currentLocale]];
        [_calendar setTimeZone:[NSTimeZone systemTimeZone]];
    }
    return _calendar;
}

- (NSMutableArray *)mothInfos {
    if (!_mothInfos) {
        _mothInfos = [NSMutableArray new];
        for (int i = 0; i < 3; i++) {
            [_mothInfos addObject:[NSNull null]];
        }
    }
    return _mothInfos;
}

- (NSLock *)lock {
    if (!_lock) _lock = [NSLock new];
    return _lock;
}

- (NSMutableArray *)pselectedDates {
    if (!_pselectedDates) _pselectedDates = [NSMutableArray new];
    return _pselectedDates;
}

- (NSMutableDictionary *)_selectedDateIndexDic {
    if (!__selectedDateIndexDic) __selectedDateIndexDic = [NSMutableDictionary new];
    return __selectedDateIndexDic;
}

- (NSMutableDictionary *)decorates {
    if (!_decorates) _decorates = [NSMutableDictionary new];
    return _decorates;
}

- (NSArray<SnailGregoranCalendarDateInfo *> *)selectedDates {
    return self.pselectedDates.copy;
}

- (void)setCurrentDate:(NSDate *)currentDate {
    if (![_currentDate isEqualToDate:currentDate]) {
        _currentDate = currentDate;
        
        NSDateComponents *dateCommpents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:currentDate];
        NSInteger weekDay = [dateCommpents weekday] - 1;
        
        NSDateFormatter *dataFormant = [[NSDateFormatter alloc] init];
        [dataFormant setDateFormat: @"yyyy-MM-dd"];
        
        SnailGregoranCalendarDateInfo *dateInfo = [SnailGregoranCalendarDateInfo new];
        dateInfo.year = dateCommpents.year;
        dateInfo.month = dateCommpents.month;
        dateInfo.day = dateCommpents.day;
        dateInfo.date = currentDate;
        dateInfo.weak = weekDay;
        dateInfo.weakString = [NSLocalizedString(@"日,一,二,三,四,五,六", nil) componentsSeparatedByString:@","][weekDay];
        dateInfo.dateString = [dataFormant stringFromDate:dateInfo.date];
        
        self.currentInfo = dateInfo;
    }
}

@end

@implementation SnailGregoranCalendarView(SNAILACTION)

- (void)selectedWithStringDates:(NSArray<NSString *> *)dates {
    
    if (!dates.count) return;
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dates enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *seperts = [obj componentsSeparatedByString:@"-"];
        if (seperts.count == 3) {
            NSString *year = seperts[0];
            NSString *month = seperts[1];
            NSString *day = seperts[2];
            NSMutableDictionary *yearDic = dic[year];
            if (!yearDic) {
                yearDic = [NSMutableDictionary new];
                dic[year] = yearDic;
            }
            NSMutableSet *daySet = yearDic[month];
            if (!daySet) {
                daySet = [NSMutableSet new];
                yearDic[month] = daySet;
            }
            if (![daySet containsObject:day]) {
                [daySet addObject:day];
            }
        }
    }];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *year, NSMutableDictionary *monthDic, BOOL * _Nonnull stop) {
        [monthDic enumerateKeysAndObjectsUsingBlock:^(NSString *month, NSMutableSet *daySet, BOOL * _Nonnull stop) {
            
            NSDateComponents *comments = [NSDateComponents new];
            comments.year = year.integerValue;
            comments.month = month.integerValue;
            comments.day = 1;
            
            NSDate *date = [self.calendar dateFromComponents:comments];
            
            _SnailGregoranCalendarMonthInfo *monthInfo = [self takeMonthInfo:date];
            NSDictionary *rectDic = [self sna_takeMonthRects:monthInfo Days:daySet];
            
            NSString *decoratekey = [NSString stringWithFormat:@"%@-%@",year,month];
            
            [daySet enumerateObjectsUsingBlock:^(NSString *day, BOOL * _Nonnull stop) {
                NSString *key = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
                if (!self._selectedDateIndexDic[key]) {
            
                    NSMutableDictionary *decorateInfo = [self takeDecorateInfo:decoratekey];
                    NSMutableDictionary *decorateIndexInfo = decorateInfo[DecorateIndexsKey];
                    if (!decorateIndexInfo) {
                        decorateIndexInfo = [NSMutableDictionary new];
                        decorateInfo[DecorateIndexsKey] = decorateIndexInfo;
                    }
                    NSMutableArray *decorateDatas = decorateInfo[DecorateDatasKey];
                    if (!decorateDatas) {
                        decorateDatas = [NSMutableArray new];
                        decorateInfo[DecorateDatasKey] = decorateDatas;
                    }
                    
                    SnailGregoranCalendarDateInfo *dateInfo = [SnailGregoranCalendarDateInfo new];
                    dateInfo.year = year.integerValue;
                    dateInfo.month = month.integerValue;
                    dateInfo.day = day.integerValue;
                    
                    NSDateComponents *datecomponts = [NSDateComponents new];
                    datecomponts.year = dateInfo.year;
                    datecomponts.month = dateInfo.month;
                    datecomponts.day = dateInfo.day;
                    
                    dateInfo.date = [self.calendar dateFromComponents:datecomponts];
                    
                    NSDateComponents *tmpcomponents = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:dateInfo.date];
                    NSInteger weekDay = [tmpcomponents weekday] - 1;
                    
                    dateInfo.weak = weekDay;
                    dateInfo.weakString = [NSLocalizedString(@"日,一,二,三,四,五,六", nil) componentsSeparatedByString:@","][weekDay];
                    
                    NSDateFormatter *dataFormant = [[NSDateFormatter alloc] init];
                    [dataFormant setDateFormat: @"yyyy-MM-dd"];
                    
                    dateInfo.dateString = [dataFormant stringFromDate:dateInfo.date];
                    
                    BOOL shouldSelected = true;
                    if (self.shouldSelectedBlock) shouldSelected = self.shouldSelectedBlock(dateInfo);
                    
                    if (shouldSelected) {
                        [self.lock lock];
                        
                        CGRect selectedRect = [rectDic[key] CGRectValue];
                        
                        CGPoint point = CGPointMake(CGRectGetMidX(selectedRect), CGRectGetMidY(selectedRect));
                        NSValue *pvalue = [NSValue valueWithCGPoint:point];
                        
                        self._selectedDateIndexDic[key] = dateInfo;
                        [self.pselectedDates addObject:dateInfo];
                        
                        decorateIndexInfo[key] = pvalue;
                        [decorateDatas addObject:pvalue];
                        
                        [self.lock unlock];
                        
                        if (self.didSelectedBlock) self.didSelectedBlock(dateInfo);
                    
                    }
                }
            }];
            
        }];
    }];
    [self goRefesh];
    
}

- (NSDictionary *)sna_takeMonthRects:(_SnailGregoranCalendarMonthInfo *)info Days:(NSMutableSet *)days {
    
    NSMutableParagraphStyle *paty = [NSMutableParagraphStyle new];
    paty.alignment = NSTextAlignmentCenter;
    
    NSDictionary *normalAttri = @{NSFontAttributeName:self.normaleFont,NSForegroundColorAttributeName:self.normaleColor,NSParagraphStyleAttributeName:paty};
    NSDictionary *selectedAttri = @{NSFontAttributeName:self.selectedFont,NSForegroundColorAttributeName:self.selectedColor,NSParagraphStyleAttributeName:paty};
    
    CGRect bounds = self.scro.bounds;
    
    CGFloat vSpaceing = 15;
    CGFloat height = (bounds.size.height - vSpaceing * 5) / 6.0;
    CGFloat width = floor(bounds.size.width / 7.0);
    
    CGFloat startX = bounds.size.width;
    
    CGFloat x = .0f;
    CGFloat y = .0f;
    NSInteger firstDayWeak = info.firstDayWeakOfMonth;
    NSInteger totalDay = info.dayC;
    
    CGFloat normaleLineHeight = [normalAttri[NSFontAttributeName] lineHeight];
    CGFloat selectedLineHeight = [selectedAttri[NSFontAttributeName] lineHeight];

    NSMutableDictionary *tmpDics = [NSMutableDictionary new];

    for (int i = 0; i < 6; i++) {
        y = i * (height + vSpaceing);
        for (int j = 0; j < 7; j++) {
            int index = i * 7 + j;
            x = startX + j * width;
            CGRect rect = CGRectMake(x, y, width, height);
            if (index >= firstDayWeak && (index + 1) <= (totalDay + firstDayWeak)) {
                NSString *str = [NSString stringWithFormat:@"%ld",index + 1 - firstDayWeak];
                NSString *key = [NSString stringWithFormat:@"%ld-%hhu-%@",info.year,info.month,str];
                NSDictionary *attr = normalAttri;
                CGRect txRect = CGRectMake(rect.origin.x, y + (rect.size.height - normaleLineHeight) * .5, rect.size.width, normaleLineHeight);
                if ([days containsObject:str]) {
                    attr = selectedAttri;
                    txRect = CGRectMake(rect.origin.x, y + (rect.size.height - selectedLineHeight) * .5, rect.size.width, selectedLineHeight);
                }
                tmpDics[key] = [NSValue valueWithCGRect:txRect];
            }
        }
    }
    return tmpDics.copy;
    
}

@end
