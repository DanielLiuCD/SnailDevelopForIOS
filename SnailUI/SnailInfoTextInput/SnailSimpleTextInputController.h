//
//  SnailSimpleTextInputController.h
//  lesan
//
//  Created by JobNewMac1 on 2018/7/26.
//  Copyright © 2018年 ning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailSimpleTextInputController : UIViewController

+ (void)showFromeVc:(UIViewController *)vc Text:(NSString *)texted PlaceHolder:(NSString *)holder Block:(void(^)(NSString *text))block;

@end
