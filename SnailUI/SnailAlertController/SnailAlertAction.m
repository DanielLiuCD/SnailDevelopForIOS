//
//  SnailAlertAction.m
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2019/1/4.
//  Copyright © 2019年 com.jonnew. All rights reserved.
//

#import "SnailAlertAction.h"

@interface SnailAlertAction()

@property (nonatomic ,strong) NSString *name;
@property (nonatomic ,copy) void(^block)(void);

@end

@implementation SnailAlertAction

+ (instancetype)Action:(NSString *)name Block:(void (^)(void))block {
    return [self Action:name Attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0 green:122 / 255.0 blue:1 alpha:1]} Block:block];
}

+ (instancetype)Action:(NSString *)name Attributes:(NSDictionary *)attributes Block:(void (^)(void))block {
    SnailAlertAction *action = [SnailAlertAction new];
    action.name = name;
    action.attribute = attributes;
    action.block = block;
    return action;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.seperator = true;
    }
    return self;
}

@end
