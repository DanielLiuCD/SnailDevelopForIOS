//
//  UIView+Snail.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "UIView+Snail.h"

@implementation UIView (Snail)

- (instancetype(^)(CGFloat corner))snail_corner {
    return ^id(CGFloat corner) {
        self.layer.cornerRadius = corner;
        self.layer.masksToBounds = true;
        return self;
    };
}

- (instancetype(^)(CGFloat width,UIColor *color))snail_border {
    return ^id(CGFloat width,UIColor *color) {
        self.layer.borderWidth = width;
        self.layer.borderColor = color.CGColor;
        return self;
    };
}

- (void)snail_addSubviews:(NSArray<UIView *> *)views {
    for (UIView *view in views) {
        [self addSubview:view];
    }
}

- (void)snail_addLayoutGuides:(NSArray<UILayoutGuide *> *)guides {
    for (UILayoutGuide *guide in guides) {
        [self addLayoutGuide:guide];
    }
}

- (UITapGestureRecognizer *)snail_addTapGes:(id)target Action:(SEL)selector {
    __unused UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    [self addGestureRecognizer:tap];
    return tap;
}

@end
