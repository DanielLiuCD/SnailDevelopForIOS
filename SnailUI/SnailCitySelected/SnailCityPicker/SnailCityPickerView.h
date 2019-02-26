//
//  SnailCityPickerView.h
//  QianXun
//
//  Created by JobNewMac1 on 2018/9/14.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SnailCityPickerView : UIView

- (void)takeSelectedInfo:(void(^)(NSDictionary *province,NSDictionary *city,NSDictionary *area))block;

@end
