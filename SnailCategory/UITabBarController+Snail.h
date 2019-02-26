//
//  UITabBarController+Snail.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/19.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (Snail)

- (UITabBarItem *)addVc:(UIViewController *)vc Title:(NSString *)title Attribute:(NSDictionary *)attribute SelectedAttribute:(NSDictionary *)selAttribute Image:(UIImage *)image SelectedImage:(UIImage *)selImage;

- (UITabBarItem *)addNavVc:(UIViewController *)vc Title:(NSString *)title Attribute:(NSDictionary *)attribute SelectedAttribute:(NSDictionary *)selAttribute Image:(UIImage *)image SelectedImage:(UIImage *)selImage;

@end
