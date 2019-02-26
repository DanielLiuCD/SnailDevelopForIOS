//
//  NSString+Snail.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/7/6.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Snail)

- (CGFloat)snail_calculate_height:(CGSize)size attributes:(NSDictionary *)attributes;

- (CGFloat)snail_calculate_width:(CGSize)size attributes:(NSDictionary *)attributes;

- (CGSize)snail_calculate_size:(CGSize)size attributes:(NSDictionary *)attributes;

- (CGFloat)snail_calculate_width_ForUILabel:(CGSize)size attributes:(NSDictionary *)attributes;

- (NSString *)snail_unix_time_to_human:(NSString *)dateFormater;

- (NSString *)snail_url_encode;

- (NSString *)snail_url_decode;

///过滤系统的json字符串里面的空格和换行
- (NSString *)snail_filter_json_space_line;

///判断数字字母下划线
- (BOOL)snail_check_num_char_under;

///判断email
- (BOOL)snail_check_email;

///限制系统键盘的emoji
- (BOOL)snail_contains_emoji;

///限制第三方键盘的emoji和表情
- (BOOL)snail_has_emoji;

///是不是9宫格
- (BOOL)snail_is_nine_keybord;

///MD5
- (NSString *)snail_md5:(BOOL)isLower;

@end
