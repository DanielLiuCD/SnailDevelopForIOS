//
//  NSArray+Snail.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/12/17.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "NSArray+Snail.h"

@implementation NSArray (Snail)

- (NSString *)snail_json {
    NSString *str = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    return [str snail_filter_json_space_line];
}

@end
