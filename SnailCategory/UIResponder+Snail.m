//
//  UIResponder+Snail.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/4.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "UIResponder+Snail.h"

@implementation UIResponder (Snail)

- (void)snailResponderChain:(NSString *)event Extend:(id)extend {
    [self.nextResponder snailResponderChain:event Extend:extend];
}

@end
