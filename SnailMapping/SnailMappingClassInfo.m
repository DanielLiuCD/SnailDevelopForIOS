//
//  SnailMappingClassInfo.m
//  SnailMapping
//
//  Created by JobNewMac1 on 2018/3/9.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailMappingClassInfo.h"
#import <objc/runtime.h>

static SnailMappingType takeTypeFromeEncoding(const char *encoding) {
    
    SnailMappingType type = SnailMappingTypeUnKnow;
    
    if (strlen(encoding) == 0) return type;
    
    switch (encoding[0]) {
        case 'c': type = SnailMappingTypeChar;              break;
        case 'i': type = SnailMappingTypeInt;               break;
        case 's': type = SnailMappingTypeShort;             break;
        case 'l': type = SnailMappingTypeLong;              break;
        case 'q': type = SnailMappingTypeLongLong;          break;
        case 'C': type = SnailMappingTypeUnSignedChar;      break;
        case 'I': type = SnailMappingTypeUnSignedInt;       break;
        case 'S': type = SnailMappingTypeUnSignedShort;     break;
        case 'L': type = SnailMappingTypeUnSignedLong;      break;
        case 'Q': type = SnailMappingTypeUnsignedLongLong;  break;
        case 'f': type = SnailMappingTypeFloat;             break;
        case 'd': type = SnailMappingTypeDouble;            break;
        case 'B': type = SnailMappingTypeBool;              break;
        case 'v': type = SnailMappingTypeVoid;              break;
        case '*': type = SnailMappingTypeCharString;        break;
        case '@': type = SnailMappingTypeObject;            break;
        case '#': type = SnailMappingTypeClass;             break;
        case ':': type = SnailMappingTypeSEL;               break;
        case '[': type = SnailMappingTypeArray;             break;
        case '{': type = SnailMappingTypeStruct;            break;
        case '(': type = SnailMappingTypeUnion;             break;
        case 'b': type = SnailMappingTypeBNum;              break;
        case '^': type = SnailMappingTypePointerType;       break;
        case '?': type = SnailMappingTypeUnKnow;            break;
        default: break;
    }
    
    return type;
    
}

static SnailMappingType takeQualifiersTypeFromeEncoding(const char *encoding) {
    
    SnailMappingType type = SnailMappingTypeUnKnow;
    
    size_t len = strlen(encoding);
    if (len == 0) return type;
    
    for (int i = 0; i < len; i++) {
        
        char tmp = encoding[i];
        switch (tmp) {
            case 'r': type |= SnailMappingQualifiersTypeConst;   break;
            case 'n': type |= SnailMappingQualifiersTypeIn;      break;
            case 'N': type |= SnailMappingQualifiersTypeInOut;   break;
            case 'o': type |= SnailMappingQualifiersTypeOut;     break;
            case 'O': type |= SnailMappingQualifiersTypeByCopy;  break;
            case 'R': type |= SnailMappingQualifiersTypeByRef;   break;
            case 'V': type |= SnailMappingQualifiersTypeOneWay;  break;
            default: break;
        }
        
    }
    
    return type;
}

static NSLock *snailMappingLock() {
    static NSLock *lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [NSLock new];
    });
    return lock;
}

static NSMutableDictionary *snailMappingClassCacheDictionary() {
    
    static NSMutableDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = [NSMutableDictionary new];
    });
    return dic;
    
}

@implementation SnailMappingVarInfo

- (instancetype)initWithIVar:(Ivar)ivar {
    
    self = [super init];
    if (self) {
        
        _name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        const char *tmpEncodingType = ivar_getTypeEncoding(ivar);
        _encodeType = [NSString stringWithUTF8String:tmpEncodingType];
        
        _dataType = takeTypeFromeEncoding(tmpEncodingType);
        
        if (_dataType == SnailMappingTypeObject && _encodeType.length > 3) {
            
            NSString *tmpValue = [NSString stringWithUTF8String:tmpEncodingType];
            NSString *tmpClsStr = [tmpValue substringWithRange:NSMakeRange(2, tmpValue.length - 3)];
            
            Class cls = NSClassFromString(tmpClsStr);
            _classInfo = [SnailMappingClassInfo createWithClass:cls];
            
        }
        
    }
    return self;
    
}

@end

@implementation SnailMappingPropertyInfo

- (instancetype)initWithPropertyT:(objc_property_t)property {
    
    self = [super init];
    if (self) {
        
        _name = [NSString stringWithUTF8String:property_getName(property)];
        _typeEncoding = [NSString stringWithUTF8String:property_getAttributes(property)];
        
        unsigned int count;
        objc_property_attribute_t *attributes = property_copyAttributeList(property,&count);
        
        SnailMappingPropertyType tmp = SnailMappingPropertyTypeUnKnow;
        
        for (int i = 0; i < count; i++) {
            
            objc_property_attribute_t attribute =  attributes[i];
            
            switch (attribute.name[0]) {
                case 'T':
                {
                    
                    _dataType =  takeTypeFromeEncoding(attribute.value);
                    
                    if (_dataType == SnailMappingTypeObject &&  strlen(attribute.value) > 3) {
                        
                        NSString *tmpValue = [NSString stringWithUTF8String:attribute.value];
                        NSString *tmpClsStr = [tmpValue substringWithRange:NSMakeRange(2, tmpValue.length - 3)];
                        
                        Class cls = NSClassFromString(tmpClsStr);
                        _classInfo = [SnailMappingClassInfo createWithClass:cls];
                        
                    }
                    
                }
                    break;
                case 'R': tmp |= SnailMappingPropertyTypeReadonly;  break;
                case 'N': tmp |= SnailMappingPropertyTypeNonatomic;  break;
                case 'D': tmp |= SnailMappingPropertyTypeDynamic;  break;
                case 'W': tmp |= SnailMappingPropertyTypeWeak;  break;
                case '&': tmp |= SnailMappingPropertyTypeRetain; break;
                case 'C': tmp |= SnailMappingPropertyTypeCopy; break;
                case 'G':
                {
                    _getterName = [NSString stringWithUTF8String:attribute.value];
                }
                    break;
                case 'S':
                {
                    _setterName = [NSString stringWithUTF8String:attribute.value];
                }
                    break;
                case 'V':
                {
                    _variableName = [NSString stringWithUTF8String:attribute.value];
                }
                    break;
                default:
                    break;
            }
            
          //  printf("name = %s\n",attribute.name);
          //  printf("value = %s\n",attribute.value);
            
        }
        
        free(attributes);
        
        if (_setterName == nil) {
            
            char tmpChar = [_name characterAtIndex:0] - 32;
            _setterName = [NSString stringWithFormat:@"set%@:",[_name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%c",tmpChar]]];
            
        }
        
        if (_getterName == nil) _getterName = _name.copy;
        
        _setterSEL = NSSelectorFromString(_setterName);
        _getterSEL = NSSelectorFromString(_getterName);
        
        _propertyType = tmp;
        
    }
    return self;
    
}

@end

@interface SnailMappingMethodArgumentInfo : NSObject

@property (nonatomic ,strong) NSString *encodingType;
@property (nonatomic ,assign) SnailMappingType dataType;

@end

@implementation SnailMappingMethodArgumentInfo

@end

@implementation SnailMappingMethodInfo
{
    NSMutableArray *_cacheParams;
}

- (instancetype)initWithMethod:(Method)method {
    
    self = [super init];
    if (self) {
        
        _sel = method_getName(method);
        _name = NSStringFromSelector(_sel);
        _imp = method_getImplementation(method);
        _encodingType = [NSString stringWithUTF8String:method_getTypeEncoding(method)];
        
        _cacheParams = [NSMutableArray new];
        
        unsigned int num = method_getNumberOfArguments(method);
        
        char argName[512] = {};
        
        for (int i = 0; i < num; i++) {
            method_getArgumentType(method, i, argName, 512);
            
            SnailMappingMethodArgumentInfo *argu = [SnailMappingMethodArgumentInfo new];
            argu.encodingType = [NSString stringWithUTF8String:argName];
            argu.dataType = takeTypeFromeEncoding(argName);
            
            [_cacheParams addObject:argu];
            memset(argName, '\0', strlen(argName));
        }
        
        method_getReturnType(method, argName, 512);
        
        SnailMappingMethodArgumentInfo *argu = [SnailMappingMethodArgumentInfo new];
        argu.encodingType = [NSString stringWithUTF8String:argName];
        argu.dataType = takeTypeFromeEncoding(argName);
        
        _returnArgu = argu;
        
    }
    return self;
    
}

- (NSArray *)giveMeParams {
    return _cacheParams;
}

@end

@interface SnailMappingMethodDescption: NSObject

@property (nonatomic ,strong) NSString *name;
@property (nonatomic ,strong) NSString *value;

@end

@implementation SnailMappingMethodDescption

@end

@implementation SnailMappingProtocolInfo
{
    NSMutableArray *_cacheRequardInstanceMethods;
    NSMutableArray *_cacheRequardMethods;
    NSMutableArray *_cacheOptionInstanceMethods;
    NSMutableArray *_cacheOptionMethods;
}

- (instancetype)initWithProtocol:(Protocol *)protocol {
    
    self = [super init];
    if (self) {
        
        _name = [NSString stringWithUTF8String:protocol_getName(protocol)];
        
        unsigned int count;
        
        struct objc_method_description *temps = protocol_copyMethodDescriptionList(protocol, true, true, &count);
        
        for (unsigned int i = 0; i < count; i++) {
            @autoreleasepool {
                if (_cacheRequardInstanceMethods == nil) _cacheRequardInstanceMethods = [NSMutableArray new];
                [_cacheRequardInstanceMethods addObject:[self takeInfoFromeMethodDescption:temps[i]]];
            }
        }
        
        free(temps);
        
        temps = protocol_copyMethodDescriptionList(protocol, true, false, &count);
        
        for (unsigned int i = 0; i < count; i++) {
            @autoreleasepool {
                if (_cacheRequardMethods == nil) _cacheRequardMethods = [NSMutableArray new];
                [_cacheRequardMethods addObject:[self takeInfoFromeMethodDescption:temps[i]]];
            }
        }
        
        free(temps);
        
        temps = protocol_copyMethodDescriptionList(protocol, false, true, &count);
        
        for (unsigned int i = 0; i < count; i++) {
            @autoreleasepool {
                if (_cacheOptionInstanceMethods == nil) _cacheOptionInstanceMethods = [NSMutableArray new];
                [_cacheOptionInstanceMethods addObject:[self takeInfoFromeMethodDescption:temps[i]]];
            }
        }
        
        free(temps);
        
        temps = protocol_copyMethodDescriptionList(protocol, false, false, &count);
        
        for (unsigned int i = 0; i < count; i++) {
            @autoreleasepool {
                if (_cacheOptionMethods == nil) _cacheOptionMethods = [NSMutableArray new];
                [_cacheOptionMethods addObject:[self takeInfoFromeMethodDescption:temps[i]]];
            }
        }
        
        free(temps);
        
        
    }
    return self;
    
}

- (SnailMappingMethodDescption *)takeInfoFromeMethodDescption:(struct objc_method_description)descption {
    
    SnailMappingMethodDescption *info = [SnailMappingMethodDescption new];
    info.name = NSStringFromSelector(descption.name);
    info.value = [NSString stringWithUTF8String:descption.types];
    
    return info;
    
}

@end

@implementation SnailMappingClassInfo
{
    NSMutableArray *_cacheIvars;
    NSMutableArray *_cachePropertys;
    NSMutableArray *_cacheMethods;
    NSMutableArray *_cacheProtocols;
    
    NSMutableDictionary *_recently_Propertys;
    
}

+ (instancetype)createWithClass:(Class)cls {
    
    NSMutableDictionary *dic = snailMappingClassCacheDictionary();
    NSString *tmp = [[NSString alloc] initWithUTF8String:class_getName(cls)];
    if (dic[tmp]) return dic[tmp];
    return [[SnailMappingClassInfo alloc] initWithClass:cls];
    
}

- (instancetype)initWithClass:(Class)cls {
    
    self = [super init];
    if (self) {
        if (cls) {
            
            self.isMeta = class_isMetaClass(cls);

            [self takeInfoFromeClass:cls];
            
            NSMutableDictionary *dic = snailMappingClassCacheDictionary();
            dic[self.name.copy] = self;
            
            [self takeIVarsFromeClass:cls];
            [self takePropertysFromeClass:cls];
            [self takeMethodsFromeClass:cls];
            [self takeProtocolsFromeClass:cls];
            if (cls != [NSObject class]) {
                [self takeClassSupperInfoFromeClass:cls];
                [self takeMetaClassInfoFromeClass:cls];
            }
            
        }
    }
    return self;
    
}

- (void)takeInfoFromeClass:(Class)cls {
    _cls = cls;
    _name = [NSString stringWithUTF8String:class_getName(cls)];
    
}

- (void)takeIVarsFromeClass:(Class)cls {

    unsigned int count;
    Ivar *tmpIvars = class_copyIvarList(cls, &count);
    
    for (unsigned int i = 0; i < count; i++) {
        
        @autoreleasepool {
            SnailMappingVarInfo *ivarInfo = [[SnailMappingVarInfo alloc] initWithIVar:tmpIvars[i]];
            if (_cacheIvars == nil) _cacheIvars = [NSMutableArray new];
            [_cacheIvars addObject:ivarInfo];
        }
        
    }
    
    free(tmpIvars);
    
}

- (void)takePropertysFromeClass:(Class)cls {
    
    unsigned int count;
    objc_property_t *tmpPropertys = class_copyPropertyList(cls, &count);
    
    for (unsigned int i = 0; i < count; i++) {
        
        @autoreleasepool {
            SnailMappingPropertyInfo *propertyInfo = [[SnailMappingPropertyInfo alloc] initWithPropertyT:tmpPropertys[i]];
            if (_cachePropertys == nil) _cachePropertys = [NSMutableArray new];
            [_cachePropertys addObject:propertyInfo];
        }
        
    }
    
    free(tmpPropertys);
    
}


- (void)takeMethodsFromeClass:(Class)cls {
    
    unsigned int count;
    Method *methods = class_copyMethodList(cls, &count);
    for (unsigned int i = 0; i < count; i++) {
        @autoreleasepool {
            SnailMappingMethodInfo *me = [[SnailMappingMethodInfo alloc] initWithMethod:methods[i]];
            if (_cacheMethods == nil) _cacheMethods = [NSMutableArray new];
            [_cacheMethods addObject:me];
        }
    }
    
    free(methods);
}

- (void)takeProtocolsFromeClass:(Class)cls {
    
    unsigned int count;
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList(cls, &count);
    for (unsigned int i = 0; i < count; i++) {
        @autoreleasepool {
            SnailMappingProtocolInfo *me = [[SnailMappingProtocolInfo alloc] initWithProtocol:protocols[i]];
            if (_cacheProtocols == nil) _cacheProtocols = [NSMutableArray new];
            [_cacheProtocols addObject:me];
        }
    }
    
    free(protocols);
}

- (void)takeClassSupperInfoFromeClass:(Class)cls {
    
    Class tmp = class_getSuperclass(cls);
    if (tmp) _supperInfo = [SnailMappingClassInfo createWithClass:tmp];
    
}

- (void)takeMetaClassInfoFromeClass:(Class)cls {
    
    if (!self.isMeta) {
        Class metaCls = objc_getMetaClass(class_getName(cls));
        if (metaCls) _metaInfo = [SnailMappingClassInfo createWithClass:metaCls];
    }
    
}

- (SnailMappingPropertyInfo *)takePropertyFromeName:(NSString *)propertyName {
    
    if (propertyName == nil) return nil;
    
    if (_recently_Propertys[propertyName]) return _recently_Propertys[propertyName];
    
    for (SnailMappingPropertyInfo *p in _cachePropertys ) {
        if ([p.name isEqualToString:propertyName]) {
            if (_recently_Propertys == nil) _recently_Propertys = [NSMutableDictionary new];
            _recently_Propertys[propertyName] = p;
            return p;
        }
    }
    
    return [_supperInfo takePropertyFromeName:propertyName];
    
}

- (NSArray<SnailMappingVarInfo *> *)ivars {
    return _cacheIvars;
}

- (NSArray<SnailMappingPropertyInfo *> *)propers {
    return _cachePropertys;
}

- (NSArray<SnailMappingMethodInfo *> *)methods {
    return _cacheMethods;
}

- (NSArray<SnailMappingMethodInfo *> *)protocols {
    return _cacheProtocols;
}

@end
