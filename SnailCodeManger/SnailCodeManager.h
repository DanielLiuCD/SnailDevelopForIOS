//
//  SnailCodeManager.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>

///用于管理发送验证码后的倒计时

@interface SnailCodeManager : NSObject

@property (nonatomic ,strong) void (^block)(NSInteger value,NSDictionary *otherInfo);

- (void)recordWithIdentifer:(NSString *)identifer MaxValue:(NSInteger)value OtherInfo:(NSDictionary *)otherInfo;
- (void)loadWithIdentifer:(NSString *)identifer;

- (void)stop;

@end
