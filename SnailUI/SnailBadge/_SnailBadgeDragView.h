//
//  _SnailBadgeDragView.h
//  SnailBadge
//
//  Created by liu on 2018/10/18.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface _SnailBadgeDragView : UIView

@property (nonatomic) BOOL snailEnableDrag;
@property (nonatomic ,copy) void(^startBlock)(void);
@property (nonatomic ,copy) void(^stopBlock)(BOOL isBroken);

- (void)snailFilleColor:(UIColor *)color;

- (void)boom;

@end
