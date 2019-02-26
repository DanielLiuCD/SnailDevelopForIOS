//
//  SnailUtil.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/21.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailUtil.h"

NSString * const kSUCSIEText = @"SnailUtilCheckStringIsEmptyText";
NSString * const kSUCSIEError = @"SnailUtilCheckStringIsEmptyError";

@implementation SnailUtil

+ (UIViewController *)takeVCOfView:(UIView *)view {
    
    UIViewController *vc;
    UIResponder *respon;
    while ((respon = [view nextResponder])) {
        if ([respon isKindOfClass:[UIViewController class]]) {
            vc = (UIViewController *)respon;
            break;
        };
    }
    return vc;
    
}

+ (NSString *)checkStringIsEmpty:(NSArray<NSDictionary<NSString *,NSString *> *> *)targets {

    for (NSDictionary *dic in targets) {
        if ([dic[kSUCSIEText] length] == 0) {
            return dic[kSUCSIEError];
        }
    }
    return nil;
    
}

+(UIViewController *)takeTopController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

+ (NSString *)takeCurrencySymbol {
    NSLocale *locale = [NSLocale currentLocale];
    return [locale objectForKey:NSLocaleCurrencySymbol];
}

+ (UIImage *)takeCycleMaskImage:(CGSize)size :(UIColor *)cycleColor :(UIColor *)otherColor {
    
    if (cycleColor == nil) {
        cycleColor = SNA_CLEAR_COLOR;
    }
    if (otherColor == nil) {
        otherColor = SNA_CLEAR_COLOR;
    }
    
    NSString *name = [NSString stringWithFormat:@"圆形遮罩%@%@%@",NSStringFromCGSize(size),cycleColor.snail_ColorToHexString,otherColor.snail_ColorToHexString];
    
    UIImage *tmp = [SnailSimpleCIMManager takeCIM:name Cache:true Size:^CGSize{
        return size;
    } Block:^(CGContextRef ctx, CGRect rect, CGFloat scale) {
        
        [cycleColor setFill];
        CGContextFillRect(ctx, rect);
        
        UIBezierPath *path0 = [UIBezierPath bezierPathWithRect:rect];
        CGContextAddPath(ctx, path0.CGPath);
        
        UIBezierPath *path1 = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.height * .5];
        CGContextAddPath(ctx, path1.CGPath);
        
        [otherColor setFill];
        CGContextEOFillPath(ctx);
        
    }];
    
    return tmp;
    
}

@end
