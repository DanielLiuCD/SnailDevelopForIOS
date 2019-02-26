//
//  SnailMappingClassInfo.h
//  SnailMapping
//
//  Created by JobNewMac1 on 2018/3/9.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, SnailMappingType) {
    
    SnailMappingTypeUnKnow           = 0,
    SnailMappingTypeChar             = 1 << 1,
    SnailMappingTypeInt              = 1 << 2,
    SnailMappingTypeShort            = 1 << 3,
    SnailMappingTypeLong             = 1 << 4,
    SnailMappingTypeLongLong         = 1 << 5,
    SnailMappingTypeUnSignedChar     = 1 << 6,
    SnailMappingTypeUnSignedInt      = 1 << 7,
    SnailMappingTypeUnSignedShort    = 1 << 8,
    SnailMappingTypeUnSignedLong     = 1 << 9,
    SnailMappingTypeUnsignedLongLong = 1 << 10,
    SnailMappingTypeFloat            = 1 << 11,
    SnailMappingTypeDouble           = 1 << 12,
    SnailMappingTypeBool             = 1 << 13,
    SnailMappingTypeVoid             = 1 << 14,
    SnailMappingTypeCharString       = 1 << 15,
    SnailMappingTypeObject           = 1 << 16,
    SnailMappingTypeClass            = 1 << 17,
    SnailMappingTypeSEL              = 1 << 18,
    SnailMappingTypeArray            = 1 << 19,
    SnailMappingTypeStruct           = 1 << 20,
    SnailMappingTypeUnion            = 1 << 21,
    SnailMappingTypeBNum             = 1 << 22,
    SnailMappingTypePointerType      = 1 << 23,
    
};

typedef NS_OPTIONS(NSInteger, SnailMappingPropertyType) {
    
    SnailMappingPropertyTypeUnKnow                 = 0,
    SnailMappingPropertyTypeReadonly                = 1 << 1,
    SnailMappingPropertyTypeCopy                    = 1 << 2,
    SnailMappingPropertyTypeRetain                  = 1 << 3,
    SnailMappingPropertyTypeNonatomic               = 1 << 4,
    SnailMappingPropertyTypeCustomGetter            = 1 << 5,
    SnailMappingPropertyTypeCustomSetter            = 1 << 6,
    SnailMappingPropertyTypeDynamic                 = 1 << 7,
    SnailMappingPropertyTypeWeak                    = 1 << 8,
    SnailMappingPropertyTypeGarbageCollection       = 1 << 9,
    SnailMappingPropertyTypeOldStyleEncoding        = 1 << 10,
    
};

typedef NS_OPTIONS(NSInteger, SnailMappingQualifiersType) {
    
    SnailMappingQualifiersTypeUnKnow            = 0,
    SnailMappingQualifiersTypeConst             = 1 << 1,
    SnailMappingQualifiersTypeIn                = 1 << 2,
    SnailMappingQualifiersTypeInOut             = 1 << 3,
    SnailMappingQualifiersTypeOut               = 1 << 4,
    SnailMappingQualifiersTypeByCopy            = 1 << 5,
    SnailMappingQualifiersTypeByRef             = 1 << 6,
    SnailMappingQualifiersTypeOneWay            = 1 << 7,
    
};

@class SnailMappingPropertyInfo,SnailMappingClassInfo;

@interface SnailMappingVarInfo : NSObject

@property (nonatomic ,readonly) NSString *name;
@property (nonatomic ,readonly) NSString *encodeType;

@property (nonatomic ,readonly) SnailMappingType dataType;

@property (nonatomic ,readonly) SnailMappingClassInfo *classInfo;

@end

@interface SnailMappingPropertyInfo : NSObject

@property (nonatomic ,readonly) NSString *name;
@property (nonatomic ,readonly) NSString *getterName;
@property (nonatomic ,readonly) NSString *setterName;
@property (nonatomic ,readonly) NSString *variableName;
@property (nonatomic ,readonly) NSString *typeEncoding;

@property (nonatomic ,readonly) SEL getterSEL;
@property (nonatomic ,readonly) SEL setterSEL;

@property (nonatomic ,readonly) SnailMappingType dataType;
@property (nonatomic ,readonly) SnailMappingPropertyType propertyType;

@property (nonatomic ,readonly) SnailMappingClassInfo *classInfo;

@end

@interface SnailMappingMethodInfo : NSObject

@property (nonatomic ,readonly) NSString *name;
@property (nonatomic ,readonly) IMP imp;
@property (nonatomic ,readonly) SEL sel;
@property (nonatomic ,readonly) NSString *encodingType;
@property (nonatomic ,readonly,getter=giveMeParams) NSArray *params;
@property (nonatomic ,readonly) id returnArgu;

@end

@interface SnailMappingProtocolInfo : NSObject

@property (nonatomic ,readonly) NSString *name;

@end

@interface SnailMappingClassInfo : NSObject

@property (nonatomic ,readonly) SnailMappingClassInfo *supperInfo;
@property (nonatomic ,readonly) SnailMappingClassInfo *metaInfo;
@property (nonatomic ,readonly) NSString *name;
@property (nonatomic ,readonly) NSArray<SnailMappingVarInfo *> *ivars;
@property (nonatomic ,readonly) NSArray<SnailMappingPropertyInfo *> *propers;
@property (nonatomic ,readonly) NSArray<SnailMappingMethodInfo *> *methods;
@property (nonatomic ,readonly) NSArray<SnailMappingMethodInfo *> *protocols;
@property (nonatomic ,readonly) Class cls;
@property (nonatomic ,assign) BOOL isMeta;

+ (instancetype)createWithClass:(Class)cls;

- (SnailMappingPropertyInfo *)takePropertyFromeName:(NSString *)propertyName;

@end
