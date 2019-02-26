//
//  UITabBarController+Snail.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/19.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "UITabBarController+Snail.h"

@implementation UITabBarController (Snail)

- (UITabBarItem *)addVc:(UIViewController *)vc Title:(NSString *)title Attribute:(NSDictionary *)attribute SelectedAttribute:(NSDictionary *)selAttribute Image:(UIImage *)image SelectedImage:(UIImage *)selImage; {
    
    [self addChildViewController:vc];
    
    UITabBarItem *item = vc.tabBarItem;
    [item setTitle:title];
    if (attribute) [item setTitleTextAttributes:attribute forState:UIControlStateNormal];
    if (selAttribute) [item setTitleTextAttributes:selAttribute forState:UIControlStateSelected];
    [item setImage:image];
    [item setSelectedImage:selImage];
    
    return item;
    
}

- (UITabBarItem *)addNavVc:(UIViewController *)vc Title:(NSString *)title Attribute:(NSDictionary *)attribute SelectedAttribute:(NSDictionary *)selAttribute Image:(UIImage *)image SelectedImage:(UIImage *)selImage {
    
    return [self addVc:[[UINavigationController alloc] initWithRootViewController:vc] Title:title Attribute:attribute SelectedAttribute:selAttribute Image:image SelectedImage:selImage];
    
}

@end
