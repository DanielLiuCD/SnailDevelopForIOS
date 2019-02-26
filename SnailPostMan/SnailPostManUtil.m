//
//  SnailPostManUtil.m
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/6/12.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailPostManUtil.h"
#import "SnailPostManCategory.h"

@implementation SnailPostManUtil

+ (NSString *)createRequestIdentifer:(NSString *)path Header:(NSDictionary *)header Cookie:(NSDictionary *)cookie  Params:(NSDictionary *)params Tag:(NSInteger)tag {
    
    NSString *headerStr = [header SnailPostManSortParamsString]?:@"";
    NSString *cookieStr = [cookie SnailPostManSortParamsString]?:@"";
    NSString *paramsStr = [params SnailPostManSortParamsString]?:@"";
    
    NSString *tmpStr = [NSString stringWithFormat:@"%@-%@-%@-%@-%ld",path,headerStr,cookieStr,paramsStr,tag];
    
    return [tmpStr SnailPostManMD5];
    
}

@end
