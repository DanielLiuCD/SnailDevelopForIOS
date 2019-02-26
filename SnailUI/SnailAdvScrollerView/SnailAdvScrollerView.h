//
//  SnailAdvScrollerView.h
//  QianXun
//
//  Created by JobNewMac1 on 2018/9/13.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailAdvScrollerAdvShowView : UIView

kSPrStrong(UIImageView *imageView)

@end

@interface SnailAdvScrollerView : UIView

kSPrCopy(NSTimeInterval(^timeSpaceingBlock)(void))
kSPrCopy(NSInteger(^advCountBlock)(void))
kSPrCopy(void(^configureAdvBlock)(SnailAdvScrollerAdvShowView *cell ,NSInteger index))
kSPrCopy(void(^didSelectItemAtIndexBlock)(NSInteger index))
kSPrCopy(void(^pageChangedBlock)(NSInteger page))

- (void)reload;

- (void)pause;
- (void)resume;

@end
