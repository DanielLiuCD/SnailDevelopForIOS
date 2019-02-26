//
//  UIResponder+Snail.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/4.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (Snail)

- (void)snailResponderChain:(NSString *)event Extend:(id)extend;

@end
