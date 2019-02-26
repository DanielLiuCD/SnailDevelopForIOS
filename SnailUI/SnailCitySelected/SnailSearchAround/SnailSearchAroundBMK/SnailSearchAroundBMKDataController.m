//
//  SnialSearchAroundBMKDataController.m
//  Advertisement
//
//  Created by JobNewMac1 on 2018/11/15.
//  Copyright © 2018年 com.jobnew.advertisement. All rights reserved.
//

#import "SnailSearchAroundBMKDataController.h"
#import <BMKLocationKit/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@implementation SnailSearchAroundBMKData
@synthesize title,address,coor,rowHeight;

@end

@interface SnailSearchAroundBMKDataController()<BMKPoiSearchDelegate,BMKLocationManagerDelegate>

@property (nonatomic) BOOL isLocation;
@property (nonatomic) CLLocationCoordinate2D coor;
@property (nonatomic ,strong) BMKPoiSearch *ser;

@property (nonatomic ,copy) void (^completeBlock)(NSArray<id<SnailSearchAroundDataProtocol>> *results);

@property (nonatomic) BOOL isDefaultData;

@property (nonatomic) NSInteger defaultPage;
@property (nonatomic) NSInteger searchPage;
@property (nonatomic) NSString *tmpSearchText;

@property(nonatomic, strong) BMKLocationManager *locationManager;

@end

@implementation SnailSearchAroundBMKDataController

- (instancetype)init {
    self = [super init];
    if (self) {
        
        __weak typeof(self) self_weak_ = self;
        self.datasBlock = ^(void (^completeBlock)(NSArray<id<SnailSearchAroundDataProtocol>> *results)) {
            self_weak_.isDefaultData = true;
            self_weak_.defaultPage = 0;
            self_weak_.completeBlock = completeBlock;
            self_weak_.tmpSearchText = nil;
            [self_weak_ defaultSearch];
        };
        self.searchBlock = ^(NSString *text, void (^completeBlock)(NSArray<id<SnailSearchAroundDataProtocol>> *results)) {
            self_weak_.isDefaultData = false;
            self_weak_.searchPage = 0;
            self_weak_.completeBlock = completeBlock;
            self_weak_.tmpSearchText = text;
            [self_weak_ searchText:@[text]];
        };
        self.nextPageBlock = ^(void (^completeBlock)(NSArray<id<SnailSearchAroundDataProtocol>> *results)) {
            self_weak_.completeBlock = completeBlock;
            if (self_weak_.isDefaultData) self_weak_.defaultPage++;
            else if (self_weak_.tmpSearchText) self_weak_.searchPage++;
            if (self_weak_.isDefaultData) [self_weak_ defaultSearch];
            else if (self_weak_.tmpSearchText) [self_weak_ searchText:@[self_weak_.tmpSearchText]];
        };
        self.preparedBlock = ^(void (^completeBlock)(BOOL success)) {
            
            self_weak_.isLocation = true;
            [self_weak_.locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:^(BMKLocation * _Nullable location, BMKLocationNetworkState state, NSError * _Nullable error) {
                //获取经纬度和该定位点对应的位置信息
                self_weak_.isLocation = false;
                if (!error) {
                    self_weak_.coor = location.location.coordinate;
                    completeBlock(true);
                }
            }];
            
        };
        
    }
    return self;
}

- (void)defaultSearch {
    [self searchText:@[@"道路附属设施",@"地名地址信息",@"公共设施",@"事件活动",@"室内设施",@"通行设施",@"公司企业",@"汽车服务",@"餐饮服务",@"购物服务",@"生活服务",@"体育休闲服务",@"医疗保健服务",@"风景名胜",@"商务住宅",@"政府机构及社会团体",@"科教文化服务",@"交通设施服务",@"金融保险服务"]];
}

- (void)searchText:(NSArray *)keys {
    
    BMKPOINearbySearchOption *option = [[BMKPOINearbySearchOption alloc]init];
    option.pageIndex = self.isDefaultData?self.defaultPage:self.searchPage;
    option.pageSize = 20;
    option.location = self.coor;
    option.radius = 5000000;
    option.keywords = keys;
    [self.ser poiSearchNearBy:option];
    
}

- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPOISearchResult *)poiResult errorCode:(BMKSearchErrorCode)errorCode {
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        
        NSMutableArray *tmps = [NSMutableArray new];
    
        for (BMKPoiInfo *info in poiResult.poiInfoList) {
            SnailSearchAroundBMKData *data = [SnailSearchAroundBMKData new];
            data.title = info.name;
            data.address = info.address;
            data.coor = info.pt;
            [tmps addObject:data];
        }
        
        if (tmps.count == 0) {
            if (self.isDefaultData) {
                if (self.defaultPage > 0) self.defaultPage--;
            }
            else if (self.searchPage > 0) self.searchPage--;
        }
        
        if (self.completeBlock) {
            self.completeBlock(tmps.copy);
            self.completeBlock = nil;
        }
    }
    else  if (self.completeBlock) {
        self.completeBlock(@[]);
        self.completeBlock = nil;
    }
}

- (BMKPoiSearch *)ser {
    if (!_ser) {
        _ser = [BMKPoiSearch new];
        _ser.delegate = self;
    }
    return _ser;
}

- (BMKLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[BMKLocationManager alloc] init];
        
        _locationManager.delegate = self;
        
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _locationManager.allowsBackgroundLocationUpdates = false;
        _locationManager.locationTimeout = 10;
        _locationManager.reGeocodeTimeout = 10;
    
    }
    return _locationManager;
}

@end
