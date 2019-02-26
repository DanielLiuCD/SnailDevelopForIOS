//
//  SnailPostManCategory.h
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/12/11.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (SnailPostMan)

- (NSString *)SnailPostManInsertSeparator:(NSString *)separator;

@end

@interface NSDictionary (SnaiPostMan)

- (NSString *)SnailPostManHttpParmaString;

- (NSString *)SnailPostManSortParamsString;

@end

@interface NSString (SnailPostMan)

- (NSString *)SnailPostManMD5;

- (NSString *)SnailPostManFilterJsonSpace;

@end
