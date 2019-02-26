//
//  SnailMapping.h
//  SnailMapping
//
//  Created by JobNewMac1 on 2018/3/12.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject(SnailMapping)

+ (NSDictionary<NSString *,Class> *)snailMappingKeyMap; //返回容器的里面的model,key-model 对应

+ (NSDictionary<NSString *,NSString *> *)snailMappingKeyConvert;  //对应key的转换 如 id -> mid

+ (NSDictionary *)snailMappingCustomeKeys; //返回需要自定义转换过程的key的字典 @{key:@""}

+ (void)snailMapingCustomeMap:(NSString *)propery Value:(id)value Target:(id)target; //自定义某个key的转换

+ (NSString *)snailMappingAnalyzeDateFormatter;

@end

@interface SnailMapping : NSObject

+ (id)mappingWithSource:(id)source Target:(Class)cls; //json -> model

+ (id)mappingAnalyzeWithSource:(id)source; //model -> json

@end
