//
//  SnailLanguageSwitch.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailLanguageSwitch.h"
#import <objc/runtime.h>

#define SnailLanguageUserDefaults [NSUserDefaults standardUserDefaults]
#define SnailLanguageKey    @"SnailLanguageSwitchCurrentLanguage"

@interface SnailLanguageBundle : NSBundle

+ (NSBundle *)snailMainBundle;

@end

@interface NSBundle(SnailLanguage)

@end

@implementation NSBundle(SnailLanguage)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([NSBundle mainBundle], [SnailLanguageBundle class]);
    });
}

@end

@interface SnailLanguageSwitch()

@property (nonatomic ,strong) NSString *curLanguage;

@end

@implementation SnailLanguageSwitch

+ (instancetype)shared {
    static SnailLanguageSwitch *language;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        language = [SnailLanguageSwitch new];
    });
    return language;
}

+ (NSString *)currentLanguage {
    return [SnailLanguageSwitch shared].curLanguage;
}

+ (void)changeToLanguage:(NSString *)language {
    if (language == nil) {
        [SnailLanguageUserDefaults removeObjectForKey:SnailLanguageKey];
        [SnailLanguageUserDefaults setValue:nil forKey:@"AppleLanguages"];
    }
    else {
        [SnailLanguageUserDefaults setObject:language forKey:SnailLanguageKey];
    };
    [SnailLanguageSwitch shared].curLanguage = language;
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath {
    NSBundle *bundle = [SnailLanguageBundle snailMainBundle];
    if (!bundle) bundle = [NSBundle mainBundle];
    return [bundle pathForResource:name ofType:ext inDirectory:subpath];
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext {
    NSBundle *bundle = [SnailLanguageBundle snailMainBundle];
    if (!bundle) bundle = [NSBundle mainBundle];
    return [bundle pathForResource:name ofType:ext];
}

- (NSString *)curLanguage {
    if (!_curLanguage) {
        NSString *tmp = [SnailLanguageUserDefaults objectForKey:SnailLanguageKey];
        if (tmp) _curLanguage = tmp;
        else _curLanguage = [NSLocale preferredLanguages].firstObject;
    }
    return _curLanguage;
}

@end

@implementation SnailLanguageBundle

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle *bundle = [SnailLanguageBundle snailMainBundle];
    if (bundle) return [bundle localizedStringForKey:key value:value table:tableName];
    return [super localizedStringForKey:key value:value table:tableName];
}

+ (NSBundle *)snailMainBundle {
    
    NSString *cur = [SnailLanguageSwitch currentLanguage];
    if (cur) {
        NSString *path = [[NSBundle mainBundle] pathForResource:cur ofType:@"lproj"];
        if (path) return [NSBundle bundleWithPath:path];
    }
    return nil;
}

@end

#undef SnailLanguageUserDefaults
#undef SnailLanguageKey
