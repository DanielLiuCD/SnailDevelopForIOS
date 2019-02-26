//
//  SnailPageMenuUtil.h
//  YingKeBao
//
//  Created by JobNewMac1 on 2018/6/25.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger ,SnailPageMenuItemState) {
    SnailPageMenuItemStateNormal,
    SnailPageMenuItemStateSelected,
};

@interface SnailPageMenuBarItemConf : NSObject

@property (nonatomic ,copy) UIColor *color;
@property (nonatomic ,copy) UIFont *font;
@property (nonatomic ,copy) NSString *text;
@property (nonatomic) CGFloat textWidth;
@property (nonatomic ,strong) void(^didSelectedBlock)(UIButton *btn);
@property (nonatomic ,strong) void(^desSelectedBlock)(UIButton *btn);

@end

@interface SnailPageMenuBarIndicatorConf : NSObject

@property (nonatomic) CGFloat indicatorWidth;
@property (nonatomic) CGFloat indicatorColor;
@property (nonatomic) BOOL indicatorAutoWidth; //是否更具item的文字自动计算宽度
@property (nonatomic) CGFloat indicatorHeight;

@end

@interface SnailPageMenuBarBottomLineConf : NSObject

@property (nonatomic) CGFloat color;
@property (nonatomic) CGFloat height;
@property (nonatomic) BOOL show;

@end

@interface SnailPageMenuBarSpaceingConf : NSObject

@property (nonatomic) CGFloat leading;
@property (nonatomic) CGFloat trailing;
@property (nonatomic) CGFloat spaceing;

@end

@interface SnailPageMenuBarTileConf : NSObject

@property (nonatomic) NSInteger onePageTileCount; //如果进行平铺,那么一页平铺的数量
@property (nonatomic) BOOL isTile;

@end

@interface SnailPageMenuBarConf : NSObject

@property (nonatomic ,strong) NSArray<SnailPageMenuBarItemConf *> *itemConfs;
@property (nonatomic ,strong) SnailPageMenuBarIndicatorConf *indicator;
@property (nonatomic ,strong) SnailPageMenuBarBottomLineConf *bottomLine;
@property (nonatomic ,strong) SnailPageMenuBarSpaceingConf *space;
@property (nonatomic ,strong) SnailPageMenuBarTileConf *tile;

@end
