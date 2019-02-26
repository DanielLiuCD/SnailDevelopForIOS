//
//  UITextField+Snail.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "UITextField+Snail.h"

@implementation UITextField (Snail)

- (instancetype(^)(NSString *placeHolder,UIColor *color))snail_placeHolder {
    return ^id(NSString *placeHolder,UIColor *color){
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:placeHolder attributes:@{NSForegroundColorAttributeName:color}];
        self.attributedPlaceholder = attr;
        return self;
    };
}

- (UIView *)_create_icon_view:(id)icon :(UIEdgeInsets)inset :(CGSize)size {
    
    UIView *tmp = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if ([icon isKindOfClass:[UIImage class]]) {
        UIImage *icon_img = (UIImage *)icon;
        UIView *icon_view = [UIView new];
        icon_view.layer.contents = (__bridge id _Nullable)(icon_img.CGImage);
        icon_view.layer.contentsGravity = kCAGravityCenter;
        icon_view.layer.contentsScale = UIScreen.mainScreen.scale;
        icon_view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        icon_view.frame = CGRectMake(0, 0, size.width, size.height);
        icon_view.center = CGPointMake(tmp.center.x + inset.left - inset.right, tmp.center.y + inset.top - inset.bottom);
        [tmp addSubview:icon_view];
    }
    else if ([icon isKindOfClass:[UIView class]]) {
        UIView *icon_view = (UIView *)icon;
        icon_view.center = CGPointMake(tmp.center.x + inset.left - inset.right, tmp.center.y + inset.top - inset.bottom);
        [tmp addSubview:icon_view];
    }
    return tmp;
    
}

- (instancetype (^)(id, UIEdgeInsets, CGSize))snail_icon {
    return ^id(id icon,UIEdgeInsets inset,CGSize size) {
        self.leftView = [self _create_icon_view:icon :inset :size];
        self.leftViewMode = UITextFieldViewModeAlways;
        return self;
    };
}

- (instancetype (^)(id, UIEdgeInsets, CGSize))snail_rightIcon {
    return ^id(id icon,UIEdgeInsets inset,CGSize size) {
        self.rightView = [self _create_icon_view:icon :inset :size];
        self.rightViewMode = UITextFieldViewModeAlways;
        return self;
    };
}

@end
