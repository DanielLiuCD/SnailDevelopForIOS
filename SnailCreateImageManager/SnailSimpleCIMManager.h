//
//  SnailSimpleCIMManager.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/25.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailSimpleCIMManager : NSObject

+ (void)customeLanguage:(NSString *)languageCode;

+ (UIImage *)takeCIM:(NSString *)name Cache:(BOOL)shouleCache Size:(CGSize(^)(void))sizeBlock Block:(void(^)(CGContextRef ctx, CGRect rect, CGFloat scale))block;

+ (UIImage *)takeNoAlphaCIM:(NSString *)name Cache:(BOOL)shouleCache Size:(CGSize(^)(void))sizeBlock Block:(void(^)(CGContextRef ctx, CGRect rect, CGFloat scale))block;

@end
