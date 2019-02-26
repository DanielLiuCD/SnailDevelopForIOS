//
//  SnailCoreLocationManager.h
//  lesan
//
//  Created by JobNewMac1 on 2018/7/25.
//  Copyright © 2018年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnailCoreLocationManager : NSObject

kSPrStrong(void(^locationOnceBlock)(CLLocationCoordinate2D coor ,NSInteger tag)) //需要在每次定位前设置,会在定位完成后释放
kSPrStrong(void(^locationBlock)(CLLocationCoordinate2D coor ,NSInteger tag)) //同上
kSPrStrong(void(^locationOnceWithGeoBlock)(CLLocationCoordinate2D coor ,NSInteger tag ,CLPlacemark *placeMark)) //同上
kSPrStrong(void(^locationWithGeoBlock)(CLLocationCoordinate2D coor ,NSInteger tag ,CLPlacemark *placeMark)) //同上
kSPrStrong(void(^locationAuthStatusChangeBlock)(BOOL isAllowed)); //需要自己手动清除,block

- (void)requestPermission; //申请权限

- (void)locationOnce:(NSInteger)tag;

- (void)location:(NSInteger)tag;

- (void)stopLocation;

- (void)geocodeAddressString:(NSString *)addressString completionHandler:(CLGeocodeCompletionHandler)completionHandler;

- (void)searchAround:(NSString *)key Coor:(CLLocationCoordinate2D)coor Distance:(CGFloat)distance Block:(MKLocalSearchCompletionHandler)completionHandler;

@end
