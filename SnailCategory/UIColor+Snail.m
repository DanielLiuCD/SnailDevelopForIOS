//
//  UIColor+Snail.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/10.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "UIColor+Snail.h"

@implementation UIColor (Snail)

- (NSString *)snail_ColorToHexString {
    
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
    
}

@end
