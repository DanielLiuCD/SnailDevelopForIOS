//
//  LNTextView.m
//  SZHangKongIMIOS
//
//  Created by JobNewMac1 on 2017/12/11.
//  Copyright © 2017年 com.jobnew. All rights reserved.
//

#import "SnailTextView.h"

@interface SnailTextView()

@end

@implementation SnailTextView

-(instancetype)init {
    self = [super init];
    if (self) {
        self.placeHolderColor = [UIColor colorWithRed:172 / 255.0 green:172 / 255.0 blue:172 / 255.0 alpha:1];
        self.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        self.placeLeadingSpaceing = 8.0;
        self.placeTopSpaceing = 8.0;
        [[NSNotificationCenter defaultCenter]  addObserver:self
                                                selector:@selector(textChanged:)
                                                    name:UITextViewTextDidChangeNotification
                                                    object:self];
    }
    return self;
}

-(void)drawRect:(CGRect)rect {
    if (self.placeHolder && self.text.length == 0) {
        [self.placeHolder drawInRect:CGRectMake(self.placeLeadingSpaceing, self.placeTopSpaceing, rect.size.width - self.placeLeadingSpaceing * 2, rect.size.height - self.placeTopSpaceing * 2.0) withAttributes:@{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.placeHolderColor}];
    }
}

-(void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    _placeHolder = placeHolder;
    [self setNeedsDisplay];
}

-(void)textChanged:(NSNotification *)notify {
    if (self.sadelegate && [self.sadelegate respondsToSelector:@selector(SnailTextViewTextChange:)]) {
        [self.sadelegate SnailTextViewTextChange:self.text];
    }
    [self setNeedsDisplay];
}

- (void)setPlaceLeadingSpaceing:(CGFloat)placeLeadingSpaceing {
    _placeLeadingSpaceing = placeLeadingSpaceing;
    [self setNeedsDisplay];
}

- (void)setPlaceTopSpaceing:(CGFloat)placeTopSpaceing {
    _placeTopSpaceing = placeTopSpaceing;
    [self setNeedsDisplay];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
