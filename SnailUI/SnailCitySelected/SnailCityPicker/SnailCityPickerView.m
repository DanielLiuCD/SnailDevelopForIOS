//
//  SnailCityPickerView.m
//  QianXun
//
//  Created by JobNewMac1 on 2018/9/14.
//  Copyright © 2018年 com.jobnew. All rights reserved.
//

#import "SnailCityPickerView.h"

#define SnailCityPickerAreaName @"areaName"
#define SnailCityPickerId @"id"
#define SnailCityPickerList @"list"

@interface SnailCityPickerView()<UIPickerViewDataSource,UIPickerViewDelegate>

kSPrStrong(UIPickerView *pickerView)

kSPrStrong(NSMutableArray *provinceData)
kSPrStrong(NSMutableDictionary *cityData)
kSPrStrong(NSMutableDictionary *areaData)

kSPrStrong(NSString *selectedProvinceName)
kSPrStrong(NSString *selectedCityName)

@end

@implementation SnailCityPickerView

-(instancetype)init {
    self = [super init];
    if (self) {
        
        self.provinceData = [NSMutableArray new];
        self.cityData = [NSMutableDictionary new];
        self.areaData = [NSMutableDictionary new];
        
        self.pickerView = [UIPickerView new];
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        [self addSubview:self.pickerView];
        [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [NSThread detachNewThreadSelector:@selector(prepareData) toTarget:self withObject:nil];
        
    }
    return self;
}

- (void)prepareData {
    
    [self.provinceData removeAllObjects];
    [self.cityData removeAllObjects];
    [self.areaData removeAllObjects];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"json"];
    NSArray *city_datas = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableLeaves error:nil][@"data"];
    
    for (NSDictionary *dic in city_datas) {
        NSString *provinceName = dic[SnailCityPickerAreaName];
        if (![self.provinceData containsObject:provinceName]) {
            [self.provinceData addObject:@{SnailCityPickerAreaName:provinceName,SnailCityPickerId:dic[SnailCityPickerId]}];
            NSArray *cityList = dic[SnailCityPickerList];
            if (cityList.count > 0) {
                
                NSMutableArray *citys = self.cityData[provinceName];
                if (!citys) {
                    citys = [NSMutableArray new];
                    self.cityData[provinceName] = citys;
                }
                
                for (NSDictionary *city_dic in cityList) {
                    
                    NSString *cityName = city_dic[SnailCityPickerAreaName];
                    [citys addObject:@{SnailCityPickerAreaName:cityName,SnailCityPickerId:city_dic[SnailCityPickerId]}];
                    
                    NSArray *areaList = city_dic[SnailCityPickerList];
                    if (areaList.count > 0) {
                        NSMutableArray *areas = self.areaData[cityName];
                        if (!areas) {
                            areas = [NSMutableArray new];
                            self.areaData[cityName] = areas;
                        }
                        for (NSDictionary *area_dic in areaList) {
                            [areas addObject:@{SnailCityPickerAreaName:area_dic[SnailCityPickerAreaName],SnailCityPickerId:area_dic[SnailCityPickerId]}];
                        }
                        
                    }
                    
                }
                
            }
        }
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.selectedProvinceName = self.provinceData.firstObject[SnailCityPickerAreaName];
        self.selectedCityName = [self.cityData[self.selectedProvinceName] firstObject][SnailCityPickerAreaName];
        [self.pickerView reloadAllComponents];
        
    });
    
}

- (void)takeSelectedInfo:(void(^)(NSDictionary *province,NSDictionary *city,NSDictionary *area))block {
    if (block) {
        NSDictionary *province = self.provinceData[[self.pickerView selectedRowInComponent:0]];
        NSDictionary *city = self.cityData[province[SnailCityPickerAreaName]][[self.pickerView selectedRowInComponent:1]];
        NSDictionary *area = self.areaData[city[SnailCityPickerAreaName]][[self.pickerView selectedRowInComponent:2]];
        block(province,city,area);
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0: return self.provinceData.count;
            break;
        case 1: return [self.cityData[self.selectedProvinceName] count];
            break;
        case 2: return [self.areaData[self.selectedCityName] count];
            break;
        default: return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    switch (component) {
        case 0:
        {
            if (row < self.provinceData.count) {
                return self.provinceData[row][SnailCityPickerAreaName];
            }
        }
            break;
        case 1:
        {
            NSArray *tmp = self.cityData[self.selectedProvinceName];
            if (row < tmp.count) {
                return tmp[row][SnailCityPickerAreaName];
            }
        }
            break;
        case 2:
        {
            NSArray *tmp = self.areaData[self.selectedCityName];
            if (row < tmp.count) {
                return tmp[row][SnailCityPickerAreaName];
            }
        }
            break;
        default:  break;
    }
    return @"";
   
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
        {
            self.selectedProvinceName = self.provinceData[row][SnailCityPickerAreaName];
            NSArray *tmps = self.cityData[self.selectedProvinceName];
            if (tmps.count > 0) {
                self.selectedCityName = [tmps.firstObject objectForKey:SnailCityPickerAreaName];
            }
            else self.selectedCityName = nil;
            
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
        }
            break;
        case 1:
        {
            self.selectedCityName = self.cityData[self.selectedProvinceName][row][SnailCityPickerAreaName];
            [pickerView reloadComponent:2];
        }
            break;
        default:
            break;
    }
}

@end
