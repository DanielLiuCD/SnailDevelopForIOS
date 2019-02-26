//
//  SnailAlertAction.h
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2019/1/4.
//  Copyright © 2019年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailAlertAction : NSObject

@property (nonatomic ,readonly) NSString *name;
@property (nonatomic ,readonly) void(^block)(void);
@property (nonatomic ,strong) NSDictionary *attribute;
@property (nonatomic) BOOL seperator;

+ (instancetype)Action:(NSString *)name Block:(void(^)(void))block;
+ (instancetype)Action:(NSString *)name Attributes:(NSDictionary *)attributes Block:(void(^)(void))block;

@end
