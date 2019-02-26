//
//  SnailLanguageSwitch.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailLanguageSwitch : NSObject

+ (NSString *)currentLanguage;

+ (void)changeToLanguage:(NSString *)language;

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath;

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext;

@end
