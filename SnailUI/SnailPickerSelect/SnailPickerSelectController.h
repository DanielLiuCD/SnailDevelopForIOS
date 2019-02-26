//
//  SnailPickerSelectController.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/20.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailAlertAnimationController.h"

@interface SnailPickerSelectController : SnailAlertAnimationController

kSPrCopy(NSArray<NSNumber *> *firstSelectedRows) //只会使用一次,使用完成后被释放

kSPrStrong(NSInteger(^numberOfComponentsBlock)(void))
kSPrStrong(NSInteger(^numberOfRowsInComponentBlock)(NSInteger component))
kSPrStrong(CGFloat(^rowHeightForComponentBlock)(NSInteger component))
kSPrStrong(NSString *(^titleForRowBlock)(NSInteger row,NSInteger component))
kSPrStrong(NSDictionary *(^titleAttributesForRowBlock)(NSInteger row,NSInteger component))
kSPrStrong(void(^didSelectRow)(NSInteger row,NSInteger compont))

kSPrStrong(void(^doneBlock)(NSArray<NSNumber *> *selectedIndexs))

- (instancetype)initWithPickerHeight:(CGFloat)pickerHeight;

- (void)reload;

- (void)reloadCompont:(NSInteger)compont;

- (void)selectedRow:(NSInteger)row Compont:(NSInteger)compont;

- (NSInteger)takeSelectedRowInCompont:(NSInteger)compont;

@end
