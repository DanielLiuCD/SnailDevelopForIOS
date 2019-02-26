//
//  SnailShortcut.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/11/15.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SNASLS(key) NSLocalizedString(@#key, nil)   //语言

#define SNAS_SYS_FONT(size) [UIFont systemFontOfSize:size] //系统字体

#define SNA_STAND_USER_DEFAULTS [NSUserDefaults standardUserDefaults]

#define SNA_NOTIFE_CENTER [NSNotificationCenter defaultCenter]

#define SNA_HEX_COLOR(HEX) [UIColor colorWithRed:((float)((HEX & 0xFF0000) >> 16))/255.0 green:((float)((HEX & 0xFF00) >> 8))/255.0 blue:((float)(HEX & 0xFF))/255.0 alpha:1.0]  //16进制颜色
#define SNA_RGBA_COLOR(R,G,B,A) [UIColor colorWithRed:R / 255.0 green:G / 255.0 blue:B / 255.0 alpha:A]

#define SNA_WHITE_COLOR [UIColor whiteColor]
#define SNA_GTB_COLOR [UIColor groupTableViewBackgroundColor]
#define SNA_CLEAR_COLOR [UIColor clearColor]
#define SNA_RED_COLOR [UIColor redColor]
#define SNA_ORANGE_COLOR [UIColor orangeColor]
#define SNA_LIGHTGRAY_COLOR [UIColor lightGrayColor]
#define SNA_BLACK_COLOR [UIColor blackColor]
#define SNA_GRAY_COLOR [UIColor grayColor]
#define SNA_BLUE_COLOR [UIColor blueColor]

#define SNA_IMAGE_NAME(NAME) [UIImage imageNamed:@#NAME]
#define SNA_IMAGE_VIEW_NAME(NAME) [[UIImageView alloc] initWithImage:SNA_IMAGE_NAME(NAME)]

#define SNA_NAVGATION_CONTROLLER(VC) [[UINavigationController alloc] initWithRootViewController:VC]

#define SNA_DISPATCH_MAIN_THREAD(BLOCK) dispatch_async(dispatch_get_main_queue(), BLOCK);

#define kSPr(...) @property (nonatomic) __VA_ARGS__;
#define kSPrStrong(...) @property (nonatomic ,strong) __VA_ARGS__;
#define kSPrCopy(...) @property (nonatomic ,copy) __VA_ARGS__;
#define kSPrWeak(...) @property (nonatomic ,weak) __VA_ARGS__;
#define kSPrReadonly(...) @property (nonatomic ,readonly) __VA_ARGS__;

#define SNA_SCREEN_WIDTH     UIScreen.mainScreen.bounds.size.width
#define SNA_SCREEN_HEIGHT    UIScreen.mainScreen.bounds.size.height
#define SNA_MIN_WH  MIN(SNA_SCREEN_WIDTH, SNA_SCREEN_HEIGHT)
#define SNA_MAX_WH  MAX(SNA_SCREEN_WIDTH, SNA_SCREEN_HEIGHT)
#define SNA_AVG_FLOAT(LEADING,TRAILING,SPACEING,COUNT,VALUE) floor(((VALUE - LEADING - TRAILING) - (COUNT - 1) * SPACEING) * 1.0 / COUNT)

#define SNA_END_EDIT [UIApplication.sharedApplication.keyWindow endEditing:true];

#define SNA_KEYWINDOW  [UIApplication sharedApplication].keyWindow

#define SNA_DOCUMENT_PATH NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject
#define SNA_CACHE_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define SNA_TEMP_PATH NSTemporaryDirectory()
#define SNA_APP_PATH [[NSBundle mainBundle] bundlePath]
#define SNA_APPLICATION_SUPPORT_PATH NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,   NSUserDomainMask, YES).firstObject
#define SNA_HOME_PATH NSHomeDirectory()

#define SNA_DYNAMIC_FONT(TYPE) [UIFont preferredFontForTextStyle:TYPE]

#define SNA_DYNAMIC_LARGE_FONT SNA_DYNAMIC_FONT(UIFontTextStyleLargeTitle)
#define SNA_DYNAMIC_TITLE1_FONT SNA_DYNAMIC_FONT(UIFontTextStyleTitle1)
#define SNA_DYNAMIC_TITLE2_FONT SNA_DYNAMIC_FONT(UIFontTextStyleTitle2)
#define SNA_DYNAMIC_TITLE3_FONT SNA_DYNAMIC_FONT(UIFontTextStyleTitle3)
#define SNA_DYNAMIC_HEAD_LINE_FONT SNA_DYNAMIC_FONT(UIFontTextStyleHeadline)
#define SNA_DYNAMIC_SUB_HEAD_LINE_FONT SNA_DYNAMIC_FONT(UIFontTextStyleSubheadline)
#define SNA_DYNAMIC_BODY_FONT SNA_DYNAMIC_FONT(UIFontTextStyleBody)
#define SNA_DYNAMIC_CALLOUT_FONT SNA_DYNAMIC_FONT(UIFontTextStyleCallout)
#define SNA_DYNAMIC_FOOTNOTE_FONT SNA_DYNAMIC_FONT(UIFontTextStyleFootnote)
#define SNA_DYNAMIC_CAPTION1_FONT SNA_DYNAMIC_FONT(UIFontTextStyleCaption1)
#define SNA_DYNAMIC_CAPTION2_FONT SNA_DYNAMIC_FONT(UIFontTextStyleCaption2)

#define SNA_NSCODING_DEFINE -(void)encodeWithCoder:(NSCoder *)aCoder{ \
unsigned int count = 0;\
Ivar *ivarLists = class_copyIvarList([self class], &count);\
for (int i = 0; i < count; i++) {\
const char* name = ivar_getName(ivarLists[i]);\
NSString* strName = [NSString stringWithUTF8String:name];\
[aCoder encodeObject:[self valueForKey:strName] forKey:strName];\
}\
free(ivarLists);  \
}\
\
-(instancetype)initWithCoder:(NSCoder *)aDecoder{\
if (self = [super init]) {\
unsigned int count = 0;\
Ivar *ivarLists = class_copyIvarList([self class], &count);\
for (int i = 0; i < count; i++) {\
const char* name = ivar_getName(ivarLists[i]);\
NSString* strName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];\
id value = [aDecoder decodeObjectForKey:strName];\
[self setValue:value forKey:strName];\
}\
free(ivarLists);\
}\
return self;\
}

#define SNA_BEGIN_INIT_WITH_FRAME  - (instancetype)initWithFrame:(CGRect)frame {\
self = [super initWithFrame:frame];\
if (self) {

#define SNA_END_INIT_WITH_FRAME     }\
return self;\
}
