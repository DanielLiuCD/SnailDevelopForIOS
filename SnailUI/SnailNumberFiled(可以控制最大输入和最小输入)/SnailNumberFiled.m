//
//  SnailNumberFiled.m
//  KuaiYiTou
//
//  Created by JobNewMac1 on 2018/12/21.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import "SnailNumberFiled.h"

@interface SnailNumberFiled()

@property (nonatomic ,strong) UITextField *filed;

@property (nonatomic) NSInteger lastInteger;

@end

@implementation SnailNumberFiled

@dynamic textColor,font;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.filed = [UITextField new];
        self.filed.text = @"0";
        self.filed.textAlignment = NSTextAlignmentCenter;
        self.filed.keyboardType = UIKeyboardTypeNumberPad;
        [self.filed addTarget:self action:@selector(textChange) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:self.filed];
        [self.filed mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordDidHidden) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (BOOL)becomeFirstResponder {
    return [self.filed becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [self.filed resignFirstResponder];
}

- (BOOL)isFirstResponder {
    return self.filed.isFirstResponder;
}

- (void)keybordDidHidden {
    if (self.isFirstResponder) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.numberChangeBlock(_num,true);
        });
    }
}

- (void)textChange {
    NSInteger integer = self.filed.text.integerValue;
    self.num = integer;
}

- (void)fixNum {
    if (_num < _minNum) _num = _minNum;
    if (_num > _maxNum) _num = _maxNum;
    self.filed.text = [NSString stringWithFormat:@"%ld",_num];
    if (self.numberChangeBlock && self.lastInteger != _num) {
        self.numberChangeBlock(_num,false);
    }
    self.lastInteger = _num;
}

- (void)setNum:(NSInteger)num {
    if (_num != num) {
        _num = num;
        [self fixNum];
    }
    if (self.filed.text.length == 0) {
        self.filed.text = [NSString stringWithFormat:@"%ld",_num];
    }
}

- (void)setMinNum:(NSInteger)minNum {
    if (_minNum != minNum) {
        _minNum = minNum;
        if (_minNum > _maxNum) _maxNum = minNum;
        [self fixNum];
    }
}

- (void)setMaxNum:(NSInteger)maxNum {
    if (_maxNum != maxNum) {
        _maxNum = maxNum;
        if (_minNum > _maxNum) _maxNum = _minNum;
        [self fixNum];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    self.filed.textColor = textColor;
}

- (UIColor *)textColor {
    return self.filed.textColor;
}

- (void)setFont:(UIFont *)font {
    self.filed.font = font;
}

- (UIFont *)font {
    return self.filed.font;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
