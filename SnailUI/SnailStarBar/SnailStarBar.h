//
//  SnailStarBar.h
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2018/12/29.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailStarBar : UIView

@property (nonatomic ,strong) UIImage *starImage;
@property (nonatomic ,strong) UIImage *starForceImage;

@property (nonatomic) BOOL drag;
@property (nonatomic) BOOL present;

@property (nonatomic) NSInteger starCount;
@property (nonatomic) CGSize starSize;
@property (nonatomic) CGFloat starHSpaceing;

- (NSNumber *)takeSelectedCount;
- (void)setSelectedCount:(NSNumber *)count;

@end
