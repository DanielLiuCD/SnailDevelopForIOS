//
//  SnailCoreLocationManager.m
//  lesan
//
//  Created by JobNewMac1 on 2018/7/25.
//  Copyright © 2018年 ning. All rights reserved.
//

#import "SnailCoreLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface SnailCoreLocationManager()<CLLocationManagerDelegate>

kSPrStrong(NSLock *lock)
kSPrStrong(CLLocationManager *locationManager)
kSPrStrong(CLGeocoder *geo)
kSPr(BOOL justLocationOnce)
kSPr(NSInteger tag)

@end

@implementation SnailCoreLocationManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tag = -1;
    }
    return self;
}

#pragma mark -

- (void)requestPermission {
    
    if ([self checkPermission]) return;
    
    if (@available(iOS 9.0, *)) {
        _locationManager.allowsBackgroundLocationUpdates = YES;
    } else {
        
    }
    [self.locationManager requestWhenInUseAuthorization];
    
}

- (BOOL)checkPermission {
    
    if ([CLLocationManager locationServicesEnabled]) {
        switch ([CLLocationManager authorizationStatus]) {
            case kCLAuthorizationStatusNotDetermined:
                NSLog(@"用户尚未进行选择");
                break;
            case kCLAuthorizationStatusRestricted:
                NSLog(@"定位权限被限制");
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                NSLog(@"用户允许定位");
                return YES;
                break;
            case kCLAuthorizationStatusDenied:
                NSLog(@"用户不允许定位");
                break;
            default: break;
        }
    }
    return NO;
    
}

- (void)location:(NSInteger)tag {
    
    if (![self checkPermission]) return;
    if (self.tag != -1) return;  //正在定位
    [self.lock lock];
    self.tag = tag;
    self.justLocationOnce = false;
    [self.locationManager startUpdatingLocation];
    [self.lock unlock];
    
}

- (void)locationOnce:(NSInteger)tag {
    
    if (![self checkPermission]) return;
    if (self.tag != -1) return;  //正在定位
    [self.lock lock];
    self.tag = tag;
    self.justLocationOnce = true;
    [self.locationManager startUpdatingLocation];
    [self.lock unlock];
    
}

- (void)stopLocation {
    
    [self _stopLocation];
    
}

- (void)_stopLocation {
    
    [self.lock lock];
    self.tag = -1;
    self.justLocationOnce = false;
    [self.locationManager stopUpdatingLocation];
    [self clearBlock];
    [self clearGeoBlock];
    [self.lock unlock];
    
}

- (void)stopWithOutClearGeoBlock {
    
    [self.lock lock];
    self.tag = -1;
    self.justLocationOnce = false;
    [self.locationManager stopUpdatingLocation];
    [self clearBlock];
    [self.lock unlock];
    
}

- (void)clearBlock {
    if (self.locationBlock) self.locationBlock = nil;
    if (self.locationOnceBlock) self.locationOnceBlock = nil;
    if (self.locationWithGeoBlock) self.locationWithGeoBlock = nil;
}

- (void)clearGeoBlock {
    
    if (self.locationOnceWithGeoBlock) self.locationOnceWithGeoBlock = nil;
    
}

#pragma mark -

- (void)geocodeAddressString:(NSString *)addressString completionHandler:(CLGeocodeCompletionHandler)completionHandler {
    [self.geo geocodeAddressString:addressString completionHandler:completionHandler];
}

- (void)searchAround:(NSString *)key Coor:(CLLocationCoordinate2D)coor Distance:(CGFloat)distance Block:(MKLocalSearchCompletionHandler)completionHandler {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coor, distance, distance);
    MKLocalSearchRequest *req = [MKLocalSearchRequest new];
    req.region = region;
    req.naturalLanguageQuery = key;
    MKLocalSearch *ser = [[MKLocalSearch alloc] initWithRequest:req];
    [ser startWithCompletionHandler:completionHandler];
}

#pragma mark -

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    BOOL isAllowed = false;
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"用户尚未进行选择");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"定位权限被限制");
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"用户允许定位");
            isAllowed = true;
        }
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"用户不允许定位");
            break;
        default: break;
    }
    
    if (self.locationAuthStatusChangeBlock) {
        self.locationAuthStatusChangeBlock(isAllowed);
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count > 0) {
        CLLocation *location = locations.lastObject;
        
        if (self.justLocationOnce) {
            if (self.locationOnceBlock) {
                self.locationOnceBlock(location.coordinate,self.tag);
                [self _stopLocation];
            }
            if (self.locationOnceWithGeoBlock) {
                [self.geo reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                    if (self.locationOnceWithGeoBlock) self.locationOnceWithGeoBlock(location.coordinate, self.tag, placemarks.count>0?placemarks.firstObject:nil);
                    [self clearGeoBlock];
                }];
                [self stopWithOutClearGeoBlock];
            }
        }
        else {
            if (self.locationBlock) self.locationBlock(location.coordinate,self.tag);
            if (self.locationWithGeoBlock) {
                [self.geo reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                    if (self.locationWithGeoBlock) self.locationWithGeoBlock(location.coordinate, self.tag, placemarks.count>0?placemarks.firstObject:nil);
                }];
            }
        }
        
    }
}

#pragma mark -

- (NSLock *)lock {
    if (!_lock) {
        _lock = [NSLock new];
    }
    return _lock;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    return _locationManager;
}

- (CLGeocoder *)geo {
    if (!_geo) {
        _geo = [CLGeocoder new];
    }
    return _geo;
}

- (void)dealloc {
    [self _stopLocation];
}

@end
