//
//  SnailCardContainerView.h
//  SnailTanTanCard
//
//  Created by JobNewMac1 on 2018/7/18.
//  Copyright © 2018年 com.jonnew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnailCardShowView.h"

#pragma mark -

typedef NS_ENUM(NSInteger ,SnailCardContainerAreaType) {
    SnailCardContainerArea_Center,
    SnailCardContainerArea_Top,
    SnailCardContainerArea_Bottom,
    SnailCardContainerArea_Left,
    SnailCardContainerArea_Right,
};

#pragma mark -

@interface SnailCardContainerDataSource : NSObject

kSPrStrong(NSInteger (^countBlock)(void)) //数据总数
kSPrStrong(SnailCardShowCell *(^createShowCellBlock)(NSInteger showIndex)) //获取展示的cell 注意这里的index不是针对总数的,而是针对展示个数的
kSPrStrong(void(^configureShowCellBlock)(SnailCardShowCell *cell, NSInteger index)) //填充数据 注意这里的index是针对总数的
kSPrStrong(void(^showCellBlock)(SnailCardShowCell *cell, NSInteger index)) //cell显示完成
kSPrStrong(CGSize(^showCellSizeBlock)(void)) //注意这里的index是针对总数的

@end

#pragma mark -

@interface SnailCardContainerViewDelegate : NSObject

kSPrStrong(void(^becomeAreaBlock)(SnailCardShowCell *cell, NSInteger index ,SnailCardContainerAreaType area))

kSPrStrong(void(^resginAreaBlock)(SnailCardShowCell *cell, NSInteger index ,SnailCardContainerAreaType area))

kSPrStrong(void(^didSelectedBlock)(SnailCardShowCell *cell, NSInteger index))

kSPrStrong(void(^didAreaBlock)(SnailCardShowCell *cell, NSInteger index ,SnailCardContainerAreaType area))

@end

#pragma mark -

@interface SnailCardContainerView : UIView

kSPrStrong(SnailCardContainerDataSource *dataSource)
kSPrStrong(SnailCardContainerViewDelegate *delegate)

- (void)reloadData;

- (void)next;

- (NSInteger)takeCurrentIndex;

@end
