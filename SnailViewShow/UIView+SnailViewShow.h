//
//  UIView+SnailViewShow.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/25.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailViewShowUIModel : NSObject

@property (nonatomic ,weak ,readonly) UIView *view;
@property (nonatomic ,readonly) NSString *identifer;

- (void)defineUIForView:(UIView *)view;

- (void)SnailViewShowModelConfigureWithModel:(id)model;

- (void)clearScreen;

- (void)removeUI;

@end

@interface UIView (SnailViewShow)

@property (nonatomic ,readonly ,strong) SnailViewShowUIModel *SnailUIModel;

- (SnailViewShowUIModel *)SnailCheckUIForIdentifer:(NSString *)identifer Block:(SnailViewShowUIModel *(^)(UIView *view ,NSString *identifer))block;

- (void)SnailUIClearScreen;

@end
