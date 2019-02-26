//
//  SnailPostManUtil.h
//  SnailPostMan
//
//  Created by JobNewMac1 on 2018/6/12.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailPostManUtil : NSObject

+ (NSString *)createRequestIdentifer:(NSString *)path Header:(NSDictionary *)header Cookie:(NSDictionary *)cookie  Params:(NSDictionary *)params Tag:(NSInteger)tag;

@end
