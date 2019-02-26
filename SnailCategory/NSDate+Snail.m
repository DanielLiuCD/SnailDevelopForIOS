//
//  NSDate+Snail.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/2.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "NSDate+Snail.h"

@implementation NSDate (Snail)

- (NSString *)snail_date_string:(NSString *)formater {
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:formater];
    df.locale = [NSLocale currentLocale];
    return [df stringFromDate:self];
}

@end
