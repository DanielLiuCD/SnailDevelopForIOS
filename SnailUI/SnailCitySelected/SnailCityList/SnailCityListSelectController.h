//
//  SnailCityListSelectController.h
//  FishNation
//
//  Created by JobNewMac1 on 2018/10/9.
//  Copyright © 2018年 MT. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -

@protocol SnailCityListItemProtocol<NSObject>

kSPrStrong(NSString *snailCityListName)
kSPr(CLLocationCoordinate2D coor)

@end

#pragma mark -

@interface SnailCityListUIController : NSObject

kSPr(BOOL showLocationCity) //是否显示定位
kSPr(BOOL showAroundSearch) //是否显示搜索框
kSPr(BOOL showCommonCity)   //是否显示常用
kSPr(BOOL showRightCharacterIndex)   //是否显示显示右边的字母列表

kSPrCopy(UIImage *locationPinImage)

kSPrCopy(NSString *searchPlaceHolder)
kSPrCopy(NSString *locationPlaceHolder)

kSPr(CGFloat borderWidth)

kSPrCopy(UIColor *backgroundColor)
kSPrCopy(UIColor *separatorLineColor)
kSPrCopy(UIColor *borderColor)
kSPrCopy(UIColor *characterIndexFontColor;)

kSPrCopy(UIColor *searchBackgrooundColor)

kSPrStrong(UIFont *headerNameFont)
kSPrCopy(UIColor *headerBackgroundColor)
kSPrCopy(UIColor *headerNameColor)
kSPrCopy(UIColor *headerNameBackgroundColor)

kSPrStrong(UIFont *cityNameFont)
kSPrCopy(UIColor *cityNameColor)
kSPrCopy(UIColor *cityBackgroundColor)

@end

#pragma mark -

@interface SnailCityListDataController : NSObject

kSPrCopy(void(^prepareBlock)(void(^prepareSuccessBlock)(void)))
kSPrCopy(void(^searchBlock)(NSString *searchText,void(^searchResultBlock)(NSDictionary *results,NSArray<NSString *> *resultFirstCharacters)))
kSPrCopy(void(^locationBlock)(void(^locationResultBlock)(id<SnailCityListItemProtocol> results)))
kSPrCopy(void(^commonBlock)(void(^commonResultBlock)(NSArray<id<SnailCityListItemProtocol>> *result)))
kSPrCopy(void(^dataBlock)(void(^dataResultBlock)(NSDictionary *results,NSArray<NSString *> *resultFirstCharacters)))
kSPrCopy(void(^selectedBlock)(id<SnailCityListItemProtocol> item))

@end

#pragma mark -

@interface SnailCityListSelectController : UIViewController

kSPrStrong(SnailCityListUIController *uiController)
kSPrStrong(SnailCityListDataController *dataController)
kSPr(BOOL geocodeAddress) //default is false

kSPrCopy(void(^selectedCityBlock)(id<SnailCityListItemProtocol> item))

- (void)reload;

@end
