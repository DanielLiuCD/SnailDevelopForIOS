//
//  SnailImageShowController.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/23.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailImageShowController : UIViewController

+ (void)showFromeVc:(UIViewController *)vc View:(id)view Count:(NSInteger)totalCount ShowBlock:(void(^)(UIImageView *imageView,NSInteger index))showBlock;

@end
