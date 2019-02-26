//
//  SnailLineView.h
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2018/12/29.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger ,SnailLineViewType) {
    SnailLineViewTypeNone = 1,
    SnailLineViewTypeLeft = SnailLineViewTypeNone << 1,
    SnailLineViewTypeRight = SnailLineViewTypeNone << 2,
    SnailLineViewTypeTop = SnailLineViewTypeNone << 3,
    SnailLineViewTypeBottom = SnailLineViewTypeNone << 4,
};

@interface SnailLineView : UIView

@property (nonatomic) SnailLineViewType lineType;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic ,strong) UIColor *lineColor;

@end
