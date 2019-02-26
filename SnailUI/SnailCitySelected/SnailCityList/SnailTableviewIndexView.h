//
//  SnailTableviewIndexView.h
//  QianXun
//
//  Created by liu on 2018/10/15.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailTableviewIndexView : UIView

@property (nonatomic ,strong) NSArray<NSString *> *characters;
@property (nonatomic ,strong) UIFont *font;
@property (nonatomic ,strong) UIColor *color;
@property (nonatomic ,strong) UIColor *indicatorColor;
@property (nonatomic ,strong) UIColor *indicatorBackgroundColor;
@property (nonatomic) BOOL left;

@property (nonatomic ,copy) void(^selectedBlock)(NSInteger index,NSString *character);

@end

@interface SnailTableviewIndexView()

- (void)removeIndicator;

@end
