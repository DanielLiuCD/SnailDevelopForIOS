//
//  SnailMultipleChooseController.h
//  lesan
//
//  Created by liu on 2018/8/17.
//  Copyright © 2018年 ning. All rights reserved.
//

#import "SnailAlertAnimationController.h"

@interface SnailMultipleChooseController : SnailAlertAnimationController

kSPrStrong(UIFont *(^titleFontBlock)(void))
kSPrStrong(UIColor *(^borderColorBlock)(void))
kSPrStrong(UIColor *(^unSelectTitleColorBlock)(void))
kSPrStrong(UIColor *(^selectTitleColorBlock)(void))
kSPrStrong(UIColor *(^unSelectBckgroundColorBlock)(void))
kSPrStrong(UIColor *(^selectBckgroundColorBlock)(void))
kSPrStrong(NSInteger(^totalCountBlock)(void))
kSPrStrong(NSString *(^titleBlock)(NSInteger index))
kSPrStrong(BOOL(^titleIsSelectedBlock)(NSString *ti,NSInteger index))
kSPrStrong(void(^doneBlock)(NSArray<NSNumber *> *selectIndexs))

- (void)reload;

@end
