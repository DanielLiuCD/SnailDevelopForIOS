//
//  UIView+Snail.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Snail)

- (instancetype(^)(CGFloat conur))snail_corner;
- (instancetype(^)(CGFloat width,UIColor *color))snail_border;

- (void)snail_addSubviews:(NSArray<UIView *> *)views;

- (void)snail_addLayoutGuides:(NSArray<UILayoutGuide *> *)guides;

- (UITapGestureRecognizer *)snail_addTapGes:(id)target Action:(SEL)selector;

@end
