//
//  SnailSimpleGuideController.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/12/17.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailSimpleGuideController : UIViewController

@property (nonatomic ,copy) NSInteger (^numberOfImageBlock)(void);
@property (nonatomic ,copy) UIView *(^viewForIndexBlock)(NSInteger index);
@property (nonatomic ,copy) void(^didSelectedBlock)(NSInteger index);

- (void)reload;

- (void)next;
- (void)previous;

@end
