//
//  LNTextView.h
//  SZHangKongIMIOS
//
//  Created by JobNewMac1 on 2017/12/11.
//  Copyright © 2017年 com.jobnew. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SnailTextViewDelegate <NSObject>

@optional
- (void)SnailTextViewTextChange:(NSString *)text;

@end

/**
    @class     LNTextView
    @brief     具有PlaceHolder的TextView.
    @details   一个具有PlaceHolder的TextView.
 */
@interface SnailTextView : UITextView
///占位字符
@property (nonatomic ,strong) NSString *placeHolder;
///占位字符的颜色
@property (nonatomic ,strong) UIColor *placeHolderColor;

@property (nonatomic) CGFloat placeLeadingSpaceing;
@property (nonatomic) CGFloat placeTopSpaceing;

@property (nonatomic ,weak) id<SnailTextViewDelegate> sadelegate;

@end
