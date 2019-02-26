//
//  SnailUtil.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/15.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

extern NSString * const kSUCSIEText;
extern NSString * const kSUCSIEError;

@interface SnailUtil : NSObject

+ (UIViewController *)takeVCOfView:(UIView *)view;

///字典的key为 kSUCSIEText kSUCSIEError
+ (NSString *)checkStringIsEmpty:(NSArray<NSDictionary<NSString *,NSString *> *> *)targets;

///获取最顶层的viewcontroller
+ (UIViewController *)takeTopController;

///获取货币符号
+ (NSString *)takeCurrencySymbol;

///获取圆形遮罩
+ (UIImage *)takeCycleMaskImage:(CGSize)size :(UIColor *)cycleColor :(UIColor *)otherColor;

@end

