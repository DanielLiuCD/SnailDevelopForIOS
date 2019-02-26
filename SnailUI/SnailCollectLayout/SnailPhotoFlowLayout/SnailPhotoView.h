//
//  SnailPhotoView.h
//  lesan
//
//  Created by liu on 2018/7/22.
//  Copyright © 2018年 ning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailPhotoView : UIView

kSPrStrong(NSInteger(^itemCountBlock)(void))
kSPrStrong(void(^configureImageBlock)(UIImageView *imageView,NSInteger index))
kSPrStrong(void(^clickBlock)(NSInteger clickIndex))

- (void)reload;

@end
