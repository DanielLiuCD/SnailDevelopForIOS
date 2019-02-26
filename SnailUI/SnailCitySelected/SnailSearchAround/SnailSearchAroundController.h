//
//  SnailSearchAroundController.h
//  QianXun
//
//  Created by JobNewMac1 on 2018/11/14.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@protocol SnailSearchAroundDataProtocol<NSObject>

@property (nonatomic ,copy) NSString *title;
@property (nonatomic ,copy) NSString *address;
@property (nonatomic) CLLocationCoordinate2D coor;
@property (nonatomic) CGFloat rowHeight;

@end

@interface SnailSearchAroundUIController : NSObject

@property (nonatomic ,copy) UIColor *backgroundColor;
@property (nonatomic ,copy) UIColor *cellBackgroundColor;

@property (nonatomic ,copy) NSString *searchPlaceholder;
@property (nonatomic ,copy) NSAttributedString *searchPlaceholderAttributeString;
@property (nonatomic ,copy) UIColor *searchBackgroundColor;

@property (nonatomic ,copy) NSDictionary *titleAttribute;
@property (nonatomic ,copy) NSDictionary *addressAttribute;

@property (nonatomic ,copy) UIColor *seperateColor;
@property (nonatomic) UIEdgeInsets seperateInsets;
@property (nonatomic) CGFloat seperateHeight;

@property (nonatomic) CGFloat rowHeight; //0 = autoSizeFit
@property (nonatomic) CGFloat titleSpaceing; // default is 5

@end

@interface SnailSearchAroundDataController : NSObject

@property (nonatomic) BOOL enableImmediatelySearch;

@property (nonatomic ,copy) void(^preparedBlock)(void(^completeBlock)(BOOL success));

@property (nonatomic ,copy) void(^datasBlock)(void(^completeBlock)(NSArray<id<SnailSearchAroundDataProtocol>> *results));
@property (nonatomic ,copy) void(^searchBlock)(NSString *text ,void(^completeBlock)(NSArray<id<SnailSearchAroundDataProtocol>> *results));
@property (nonatomic ,copy) void(^nextPageBlock)(void(^completeBlock)(NSArray<id<SnailSearchAroundDataProtocol>> *results));

@end

@interface SnailSearchAroundController : UIViewController

@property (nonatomic ,strong) SnailSearchAroundUIController *uiController;
@property (nonatomic ,strong) SnailSearchAroundDataController *dataController;

@property (nonatomic ,copy) void(^selectedBlock)(id<SnailSearchAroundDataProtocol> data);

@end
