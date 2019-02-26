//
//  UIView+SnailViewShow.m
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/25.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "UIView+SnailViewShow.h"

@interface SnailViewShowUIModel()

@property (nonatomic ,weak) UIView *view;

@end

@implementation SnailViewShowUIModel

- (void)defineUIForView:(UIView *)view {
    self.view = view;
}

- (void)SnailViewShowModelConfigureWithModel:(id)model {
    
}

- (void)clearScreen {
    
}

- (void)removeUI {
    
}

- (NSString *)identifer {
    return NSStringFromClass(self.class);
}

@end

static char SNAILVIEWSHOWUIMODEL;

@interface UIView()

@property (nonatomic ,strong) SnailViewShowUIModel *SnailUIModel;

@end

@implementation UIView (SnailViewShow)

- (SnailViewShowUIModel *)SnailCheckUIForIdentifer:(NSString *)identifer Block:(SnailViewShowUIModel *(^)(UIView *, NSString *))block {
    
    NSString *tmpIdentifer;
    if (self.SnailUIModel) {
        tmpIdentifer = self.SnailUIModel.identifer;
    }
    if (![tmpIdentifer isEqualToString:identifer]) {
        if (self.SnailUIModel) [self.SnailUIModel removeUI];
        self.SnailUIModel = block(self,identifer);
    }
    return self.SnailUIModel;
    
}

- (void)SnailUIClearScreen {
    [self.SnailUIModel clearScreen];
}

- (void)setSnailUIModel:(SnailViewShowUIModel *)SnailUIModel {
    objc_setAssociatedObject(self, &SNAILVIEWSHOWUIMODEL, SnailUIModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SnailViewShowUIModel *)SnailUIModel {
    return objc_getAssociatedObject(self, &SNAILVIEWSHOWUIMODEL);
}

@end
