//
//  SnailMapping.m
//  SnailMapping
//
//  Created by JobNewMac1 on 2018/3/12.
//  Copyright © 2018年 com.crazysnail. All rights reserved.
//

#import "SnailMapping.h"
#import "SnailMappingClassInfo.h"
#import <objc/message.h>

@implementation NSObject(SnailMapping)

+ (NSDictionary *)snailMappingKeyMap {
    return nil;
}

+ (NSDictionary<NSString *,NSString *> *)snailMappingKeyConvert {
    return nil;
}

+ (NSDictionary *)snailMappingCustomeKeys {
    return nil;
}

+ (void)snailMapingCustomeMap:(NSString *)propery Value:(id)value Target:(id)target {
    
}

+ (NSString *)snailMappingAnalyzeDateFormatter {
    return nil;
}

@end

@implementation SnailMapping

+ (id)mappingWithSource:(id)source Target:(Class)cls {
    
    SnailMappingClassInfo *clsInfo = [SnailMappingClassInfo createWithClass:cls];
    
    id target = nil;
    
    if ([source isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *temps = [NSMutableArray new];
        for (id value in source) {
            [temps addObject:[SnailMapping mappingWithSource:value Target:cls]];
        }
        target = temps;
        
    }
    else if ([source isKindOfClass:[NSDictionary class]]) {
        target = [self mappingDictionary:source ClsInfo:clsInfo];
    }
    else if ([source isKindOfClass:[NSString class]]) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[source dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        if (dic) {
            target = [SnailMapping mappingWithSource:dic Target:cls];
        }
        
    }
    else if ([source isKindOfClass:[NSData class]]) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:source options:NSJSONReadingMutableLeaves error:nil];
        if (dic) {
            target = [SnailMapping mappingWithSource:dic Target:cls];
        }
    }
    
    return target;
}

+ (id)mappingDictionary:(NSDictionary *)dic ClsInfo:(SnailMappingClassInfo *)info {
    
    id target = [info.cls new];
    
    NSDictionary *keyMapDic = [info.cls snailMappingKeyMap];
    NSDictionary *convertDic = [info.cls snailMappingKeyConvert];
    NSDictionary *customeDic = [info.cls snailMappingCustomeKeys];
    
    for (id key in dic) {
        if ([key isKindOfClass:[NSString class]]) {
            
            NSString *proKey = key;
            
            if (convertDic[key]) proKey = convertDic[key];
            
            SnailMappingPropertyInfo *property = [info takePropertyFromeName:proKey];
            if (property == nil) continue;
            
            id value = dic[key];
        
            if (customeDic[proKey]) {
                [info.cls snailMapingCustomeMap:proKey Value:value Target:target];
                continue;
            }
            
            if ([value isKindOfClass:[NSNumber class]]) { //NSNumber
                
                switch (property.dataType) {
                    case SnailMappingTypeChar:
                    case SnailMappingTypeInt:
                        ((void (*)(id,SEL,int))(void *)objc_msgSend)(target,property.setterSEL,[value charValue]);
                        break;
                    case SnailMappingTypeFloat:
                        ((void (*)(id,SEL,float))(void *)objc_msgSend)(target,property.setterSEL,[value floatValue]);
                        break;
                    case SnailMappingTypeShort:
                        ((void (*)(id,SEL,float))(void *)objc_msgSend)(target,property.setterSEL,[value shortValue]);
                        break;
                    case SnailMappingTypeLong:
                        ((void (*)(id,SEL,long))(void *)objc_msgSend)(target,property.setterSEL,[value longValue]);
                        break;
                    case SnailMappingTypeLongLong:
                        ((void (*)(id,SEL,long long))(void *)objc_msgSend)(target,property.setterSEL,[value longLongValue]);
                        break;
                    case SnailMappingTypeUnSignedChar:
                        ((void (*)(id,SEL,unsigned char))(void *)objc_msgSend)(target,property.setterSEL,[value unsignedCharValue]);
                        break;
                    case SnailMappingTypeUnSignedInt:
                        ((void (*)(id,SEL,unsigned int))(void *)objc_msgSend)(target,property.setterSEL,[value unsignedIntValue]);
                        break;
                    case SnailMappingTypeUnSignedShort:
                        ((void (*)(id,SEL,unsigned short))(void *)objc_msgSend)(target,property.setterSEL,[value unsignedShortValue]);
                        break;
                    case SnailMappingTypeUnSignedLong:
                        ((void (*)(id,SEL,unsigned long))(void *)objc_msgSend)(target,property.setterSEL,[value unsignedLongValue]);
                        break;
                    case SnailMappingTypeUnsignedLongLong:
                        ((void (*)(id,SEL,unsigned long long))(void *)objc_msgSend)(target,property.setterSEL,[value unsignedLongLongValue]);
                        break;
                    case SnailMappingTypeDouble:
                        ((void (*)(id,SEL,double))(void *)objc_msgSend)(target,property.setterSEL,[value doubleValue]);
                        break;
                    case SnailMappingTypeBool:
                        ((void (*)(id,SEL,BOOL))(void *)objc_msgSend)(target,property.setterSEL,[value boolValue]);
                        break;
                    case SnailMappingTypeCharString:
                        ((void (*)(id,SEL,const char *))(void *)objc_msgSend)(target,property.setterSEL,[value stringValue].UTF8String);
                        break;
                    case SnailMappingTypeObject:
                    {
                        if (property.classInfo.cls == [NSNumber class]) {
                            ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,value);
                            break;
                        }
                        else if (property.classInfo.cls == [NSString class]) {
                            ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,[value stringValue]);
                            break;
                        }
                    }
                        
                    default:
                        ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,nil);
                        break;
                }
                
            }
            else if ([value isKindOfClass:[NSString class]]) { //NSString
                
                switch (property.dataType) {
                    case SnailMappingTypeChar:
                    case SnailMappingTypeInt:
                    case SnailMappingTypeShort:
                    case SnailMappingTypeUnSignedChar:
                    case SnailMappingTypeUnSignedInt:
                    case SnailMappingTypeUnSignedShort:
                        ((void (*)(id,SEL,int))(void *)objc_msgSend)(target,property.setterSEL,[value intValue]);
                        break;
                    case SnailMappingTypeFloat:
                        ((void (*)(id,SEL,float))(void *)objc_msgSend)(target,property.setterSEL,[value floatValue]);
                        break;
                    case SnailMappingTypeLong:
                    case SnailMappingTypeUnSignedLong:
                    case SnailMappingTypeUnsignedLongLong:
                        ((void (*)(id,SEL,long))(void *)objc_msgSend)(target,property.setterSEL,[value integerValue]);
                        break;
                    case SnailMappingTypeLongLong:
                        ((void (*)(id,SEL,long long))(void *)objc_msgSend)(target,property.setterSEL,[value longLongValue]);
                        break;
                    case SnailMappingTypeDouble:
                        ((void (*)(id,SEL,double))(void *)objc_msgSend)(target,property.setterSEL,[value doubleValue]);
                        break;
                    case SnailMappingTypeBool:
                        ((void (*)(id,SEL,BOOL))(void *)objc_msgSend)(target,property.setterSEL,[value boolValue]);
                        break;
                    case SnailMappingTypeCharString:
                        ((void (*)(id,SEL,const char *))(void *)objc_msgSend)(target,property.setterSEL,[value UTF8String]);
                        break;
                    case SnailMappingTypeObject:
                    {
                        if (property.classInfo.cls == [NSNumber class]) {
                            ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,[NSNumber numberWithFloat:[value floatValue]]);
                            break;
                        }
                        else if (property.classInfo.cls == [NSString class]) {
                            ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,value);
                            break;
                        }
                    }
                        
                    default:
                        ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,nil);
                        break;
                }
                
            }
            else if ([value isKindOfClass:[NSArray class]]) { //NSArray
                
                switch (property.dataType) {
                    case SnailMappingTypeChar:
                    case SnailMappingTypeInt:
                    case SnailMappingTypeShort:
                    case SnailMappingTypeUnSignedChar:
                    case SnailMappingTypeUnSignedInt:
                    case SnailMappingTypeUnSignedShort:
                    case SnailMappingTypeFloat:
                    case SnailMappingTypeLong:
                    case SnailMappingTypeUnSignedLong:
                    case SnailMappingTypeUnsignedLongLong:
                    case SnailMappingTypeLongLong:
                    case SnailMappingTypeDouble:
                        ((void (*)(id,SEL,int))(void *)objc_msgSend)(target,property.setterSEL,0);
                        break;
                    case SnailMappingTypeCharString:
                        ((void (*)(id,SEL,char *))(void *)objc_msgSend)(target,property.setterSEL,"");
                        break;
                    case SnailMappingTypeObject:
                    {
                        if (property.classInfo.cls == [NSArray class] || property.classInfo.cls == [NSMutableArray class]) {
                            
                            if (keyMapDic[key]) {
                                
                                NSMutableArray *tempArrays = [NSMutableArray new];
                                for (id aryValue in value) {
                                    [tempArrays addObject:[SnailMapping mappingWithSource:aryValue Target:keyMapDic[key]]];
                                }
                                ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,tempArrays);
                                
                            }
                            else {
                                
                                ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,value);
                                
                            }
                            
                            break;
                        }
                    }
                    default:
                        ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,nil);
                        break;
                }
                
            }
            else if ([value isKindOfClass:[NSDictionary class]]) { //NSDictionary
                
                switch (property.dataType) {
                    case SnailMappingTypeChar:
                    case SnailMappingTypeInt:
                    case SnailMappingTypeShort:
                    case SnailMappingTypeUnSignedChar:
                    case SnailMappingTypeUnSignedInt:
                    case SnailMappingTypeUnSignedShort:
                    case SnailMappingTypeFloat:
                    case SnailMappingTypeLong:
                    case SnailMappingTypeUnSignedLong:
                    case SnailMappingTypeUnsignedLongLong:
                    case SnailMappingTypeLongLong:
                    case SnailMappingTypeDouble:
                        ((void (*)(id,SEL,int))(void *)objc_msgSend)(target,property.setterSEL,0);
                        break;
                    case SnailMappingTypeCharString:
                        ((void (*)(id,SEL,char *))(void *)objc_msgSend)(target,property.setterSEL,"");
                        break;
                    case SnailMappingTypeObject:
                    {
                        if (property.classInfo.cls == [NSDictionary class]) {
                            ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,value);
                        }
                        else if (property.classInfo.cls == [NSMutableDictionary class]) {
                            ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,[NSMutableDictionary dictionaryWithDictionary:value]);
                        }
                        else {
                            id tmp;
                            if (keyMapDic[key]) tmp = [SnailMapping mappingWithSource:value Target:keyMapDic[key]];
                            else tmp = [SnailMapping mappingWithSource:value Target:property.classInfo.cls];
                            ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,tmp);
                        }
                        break;
                    }
                    default:
                        ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,nil);
                        break;
                }
                
            }
            else if ([value isKindOfClass:[NSNull class]]) { //NSNull
                
                switch (property.dataType) {
                    case SnailMappingTypeChar:
                    case SnailMappingTypeInt:
                    case SnailMappingTypeShort:
                    case SnailMappingTypeUnSignedChar:
                    case SnailMappingTypeUnSignedInt:
                    case SnailMappingTypeUnSignedShort:
                    case SnailMappingTypeFloat:
                    case SnailMappingTypeLong:
                    case SnailMappingTypeUnSignedLong:
                    case SnailMappingTypeUnsignedLongLong:
                    case SnailMappingTypeLongLong:
                    case SnailMappingTypeDouble:
                        ((void (*)(id,SEL,int))(void *)objc_msgSend)(target,property.setterSEL,0);
                        break;
                    case SnailMappingTypeCharString:
                        ((void (*)(id,SEL,char *))(void *)objc_msgSend)(target,property.setterSEL,"");
                        break;
                    default:
                        ((void (*)(id,SEL,id))(void *)objc_msgSend)(target,property.setterSEL,nil);
                        break;
                }
                
            }

        }
    }
    
    return target;
    
}

+ (id)mappingAnalyzeWithSource:(id)source {
    
    if (source == [NSNull null]) return nil;
    if ([source isKindOfClass:[NSAttributedString class]]) return [source string];
    if ([source isKindOfClass:[NSString class]]) return source;
    if ([source isKindOfClass:[NSNumber class]]) return source;
    if ([source isKindOfClass:[NSURL class]]) return [source absoluteString];
    
    if ([source isKindOfClass:[NSDate class]]) {
        NSDateFormatter *tmp = [NSDateFormatter new];
        if ([[source class] snailMappingAnalyzeDateFormatter]) {
            [tmp setDateFormat:[[source class] snailMappingAnalyzeDateFormatter]];
        }
        return [tmp stringFromDate:(NSDate *)source];
    }
    
    if ([source isKindOfClass:[NSArray class]]) {
        NSMutableArray *tmp = [NSMutableArray new];
        for (id tmpSrc in source) {
            id tempTarget = [self mappingAnalyzeWithSource:tmpSrc];
            if (tempTarget) [tmp addObject:tempTarget];
        }
        return tmp;
    }
    
    if ([source isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tmp = [NSMutableDictionary new];
        for (NSString *key in [source allKeys]) {
            id tempTarget = [self mappingAnalyzeWithSource:[source objectForKey:key]];
            if (tempTarget) tmp[key] = tempTarget;
        }
        return tmp;
    }
    
    NSMutableDictionary *tmp = [NSMutableDictionary new];
    SnailMappingClassInfo *clsInfo = [SnailMappingClassInfo createWithClass:[source class]];
    for (SnailMappingPropertyInfo *property in clsInfo.propers) {
        
        switch (property.dataType) {
            case SnailMappingTypeChar:
            case SnailMappingTypeUnSignedChar:
            {
                char ch = ((char(*)(id,SEL))objc_msgSend)(source,property.getterSEL);
                tmp[property.name] = [NSString stringWithFormat:@"%c",ch];
            }
                break;
            case SnailMappingTypeInt:
            case SnailMappingTypeShort:
            case SnailMappingTypeLong:
            case SnailMappingTypeLongLong:
            case SnailMappingTypeUnSignedInt:
            case SnailMappingTypeUnSignedShort:
            case SnailMappingTypeUnSignedLong:
            case SnailMappingTypeUnsignedLongLong:
            {
                NSInteger num = ((NSInteger(*)(id,SEL))objc_msgSend)(source,property.getterSEL);
                tmp[property.name] = [NSString stringWithFormat:@"%ld",(long)num];
            }
                break;
            case SnailMappingTypeFloat:
            case SnailMappingTypeDouble:
            {
                double d = ((double(*)(id,SEL))objc_msgSend)(source,property.getterSEL);
                tmp[property.name] = [NSString stringWithFormat:@"%f",d];
            }
                break;
            case SnailMappingTypeObject:
            {
                id target = ((id(*)(id,SEL))objc_msgSend)(source,property.getterSEL);
                if (target) {
                    id tmpTarget = [self mappingAnalyzeWithSource:target];
                    if (tmpTarget) {
                        tmp[property.name] = tmpTarget;
                    }
                }
            }
                break;
            default:
                break;
        }
        
    }

    return tmp;
    
}

@end
