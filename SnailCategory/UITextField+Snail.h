//
//  UITextField+Snail.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Snail)

- (instancetype(^)(NSString *placeHolder,UIColor *color))snail_placeHolder;

///icon 可为view 或 image
- (instancetype(^)(id icon,UIEdgeInsets inset,CGSize size))snail_icon;
- (instancetype(^)(id icon,UIEdgeInsets inset,CGSize size))snail_rightIcon;

@end
