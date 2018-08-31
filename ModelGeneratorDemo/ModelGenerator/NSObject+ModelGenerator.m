//
//  NSObject+ModelGenerator.m
//  ModelGenerator
//
//  Created by fumi on 2018/8/31.
//  Copyright © 2018年 fumi. All rights reserved.
//

#import "NSObject+ModelGenerator.h"
#import <objc/runtime.h>

/** 日志输出控制 */
#ifdef DEBUG
# define RALog(s, ...) printf("\n%s\n",  [[NSString stringWithFormat:(s), ##__VA_ARGS__] UTF8String] );
#else
# define RALog(...);
#endif
static NSString *stringClass = @"/** <#desc#> */\n@property (nonatomic, copy)   NSString *";
static NSString *numberClass = @"/** <#desc#> */\n@property (nonatomic, strong) NSNumber *";
static NSString *nsnullClass = @"/** <#desc#> */\n@property (nonatomic, strong) id ";
static NSString *dictionaryClass = @"/** <#desc#> */\n@property (nonatomic, strong) ";
static NSString *arrayClass = @"/** <#desc#> */\n@property (nonatomic, strong) NSArray *";
static NSString *MJ_ReplaceId = @"\n+(NSDictionary *)mj_replacedKeyFromPropertyName {\n  return @{@\"Id\" : @\"id\"};\n\n}";
static NSString *YY_ReplaceId = @"\n+(NSDictionary *)modelCustomPropertyMapper {\n  return @{@\"Id\" : @\"id\"};\n\n}";
static NSString *MJ_ArrIncludeDicToModelString = @"mj_objectClassInArray";
static NSString *YY_ArrIncludeDicToModelString = @"modelContainerPropertyGenericClass";


@implementation NSObject (ModelGenerator)

@dynamic generatorType;
static RAModelGeneratorType _generatorType;

@dynamic prefix;
static NSString *_prefix;

@dynamic headModel;
static RAHeadModel *_headModel;

#pragma mark - setter & getter

+ (RAModelGeneratorType)generatorType
{
    return _generatorType;
}

+ (NSString *)prefix
{
    return _prefix;
}

+ (RAHeadModel *)headModel
{
    return _headModel;
}

+ (void)setGeneratorType:(RAModelGeneratorType)generatorType
{
    _generatorType = generatorType;
}

+ (void)setPrefix:(NSString *)prefix
{
    _prefix = prefix;
}

+ (void)setHeadModel:(RAHeadModel *)headModel
{
    _headModel = headModel;
}


+ (void)ra_generatorModelWithDictionary:(NSDictionary *)dictionary
                            prefix:(NSString *)prefix
                  outsideModelName:(NSString *)outsideModelName
                          makeType:(RAModelGeneratorType)generatorType
{
    if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]] || dictionary.count == 0) {
        NSLog(@"非字典类型或字典为空!");
        return;
    }
    _generatorType = generatorType;
    _prefix = prefix ?: @"";
    _headModel = [self ra_generatorModelWithDictionary:dictionary ModelName:outsideModelName];

    // 执行脚本命令
    RALog(@"====================@interface==================\n\n%@\n\n%@\n====================@implementation====================\n\n%@\n\n",_headModel.className,_headModel.head,_headModel.footer);

}


/** 通过json文件配置 */
+ (void)ra_generatorModelWithJsonPath:(NSString *)jsonPath
                            prefix:(NSString *)prefix
                  outsideModelName:(NSString *)outsideModelName
                          makeType:(RAModelGeneratorType)generatorType
{
    
    NSString *content = [[NSString alloc] initWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    // 将jsonString转为字典
    NSError *error = nil;
    if (!content) {
        RALog(@"wrong type");
        return;
    }
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    id dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [self ra_generatorModelWithDictionary:dict prefix:prefix outsideModelName:outsideModelName makeType:generatorType];
    } else {
        RALog(@"wrong type");
    }
}


#pragma mark - private

+ (RAHeadModel *)ra_generatorModelWithDictionary:(NSDictionary *)dictionary ModelName:(NSString *)modelName {
    
    if (!dictionary) return nil;
    
    RAGeneratorModel *model = [[RAGeneratorModel alloc] init];
    [self modelHeadWithModelName:modelName MakeModel:model];
    
    for (id obj in dictionary) {
        if ([dictionary[obj] isKindOfClass:[NSString class]]) {
            
            [self modelWithString:obj ModelName:modelName MakeModel:model];
        } else if ([dictionary[obj] isKindOfClass:[NSNumber class]]) {
            
            [self modelWithNumber:obj ModelName:modelName MakeModel:model];
        } else if ([dictionary[obj] isKindOfClass:[NSDictionary class]]) {
            
            [self modelWithDictionary:obj ModelName:modelName MakeModel:model Dictionary:dictionary];
        } else if ([dictionary[obj] isKindOfClass:[NSArray class]]) {
            
            [self modelWithArray:obj ModelName:modelName MakeModel:model Dictionary:dictionary];
        } else if ([dictionary[obj] isKindOfClass:[NSNull class]]) {
            [model.headStr appendString:[NSString stringWithFormat:@"%@%@;\n",nsnullClass,obj]];
        } else {
            
            NSLog(@"%@不能识别的数据类型\n",obj);
        }
    }
    
    //数组中字典转模型
    if (model.modelArrayString.length > 0) {
        if (_generatorType == RAModelGeneratorTypeMJ) {
            [model.footerStr appendFormat:@"\n+ (NSDictionary *)%@{\n return @{ %@ }; \n}",MJ_ArrIncludeDicToModelString,model.modelArrayString];
        } else if (_generatorType == RAModelGeneratorTypeYY) {
            [model.footerStr appendFormat:@"\n+ (NSDictionary *)%@{\n return @{ %@ }; \n}",YY_ArrIncludeDicToModelString,model.modelArrayString];
        }
        
    }
    
    [self modelFooterWithMakeModel:model];
    
    NSString *classString = [model.classArray componentsJoinedByString:@""].length == 0 ? @"" : [NSString stringWithFormat:@"%@",[model.classArray componentsJoinedByString:@""]];
    
    RAHeadModel *headModel = [[RAHeadModel alloc] init];
    headModel.head = [model.headArray componentsJoinedByString:@"\n"];
    headModel.footer = [model.footerArray componentsJoinedByString:@"\n"];
    headModel.className = classString;
    
    return headModel;
}


+ (RAGeneratorModel *)modelHeadWithModelName:(NSString *)modelName MakeModel:(RAGeneratorModel *)model{
    
    [model.headStr appendString:[NSString stringWithFormat:@"/** <#desc#> */\n@interface %@%@ : NSObject\n\n",_prefix,[self capitalized:modelName]]];
    [model.footerStr appendString:[NSString stringWithFormat:@"@implementation %@%@\n",_prefix,[self capitalized:modelName]]];
    if (modelName && modelName.length > 0) {
        [model.classArray addObject:[NSString stringWithFormat:@"@class %@%@;\n",_prefix,[self capitalized:modelName]]];
    }
    return model;
}

+ (RAGeneratorModel *)modelFooterWithMakeModel:(RAGeneratorModel *)model{
    
    [model.headStr appendString:@"\n@end\n"];
    [model.footerStr appendString:@"\n@end\n"];
    [model.headArray insertObject:model.headStr atIndex:0];
    [model.footerArray insertObject:model.footerStr atIndex:0];
    return model;
}


+ (RAGeneratorModel *)modelWithString:(id)obj ModelName:(NSString *)modelName MakeModel:(RAGeneratorModel *)model{
    
    if ([obj isEqualToString:@"id"]) {
        [model.headStr appendString:[NSString stringWithFormat:@"%@%@Id;\n", stringClass, modelName]];
        //将id映射到Id
        if (_generatorType == RAModelGeneratorTypeMJ) {
            [model.footerStr appendString:MJ_ReplaceId];
        } else if (_generatorType == RAModelGeneratorTypeYY) {
            [model.footerStr appendString:YY_ReplaceId];
        }
        
    } else {
        [model.headStr appendString:[NSString stringWithFormat:@"%@%@;\n", stringClass, obj]];
    }
    return model;
}

+ (RAGeneratorModel *)modelWithNumber:(id)obj ModelName:(NSString *)modelName MakeModel:(RAGeneratorModel *)model {
    
    if ([obj isEqualToString:@"id"]) {
        [model.headStr appendString:[NSString stringWithFormat:@"%@%@Id;\n", numberClass, modelName]];
        if (_generatorType == RAModelGeneratorTypeMJ) {
            [model.footerStr appendString:MJ_ReplaceId];
        } else if (_generatorType == RAModelGeneratorTypeYY) {
            [model.footerStr appendString:YY_ReplaceId];
        }
    } else {
        [model.headStr appendString:[NSString stringWithFormat:@"%@%@;\n", numberClass, obj]];
    }
    return model;
}

+ (RAGeneratorModel *)modelWithDictionary:(id)obj ModelName:(NSString *)modelName MakeModel:(RAGeneratorModel *)model Dictionary:(NSDictionary *)dictionary{
    
    [model.headStr appendString:[NSString stringWithFormat:@"%@%@Model *%@;\n",dictionaryClass, [self capitalized:obj],obj]];
    RAHeadModel *headModel = [self ra_generatorModelWithDictionary:dictionary[obj] ModelName:[NSString stringWithFormat:@"%@Model",obj]];
    
    [model.classArray addObject:headModel.className];
    [model.headArray addObject:headModel.head];
    [model.footerArray addObject:headModel.footer];
    return model;
}

+ (RAGeneratorModel *)modelWithArray:(id)obj ModelName:(NSString *)modelName MakeModel:(RAGeneratorModel *)model Dictionary:(NSDictionary *)dictionary{
    
    [model.headStr appendString:[NSString stringWithFormat:@"%@%@;\n",arrayClass,obj]];
    id resault = [self returnFirstObjWithArr:dictionary[obj]];
    if ([resault isKindOfClass:[NSDictionary class]]) {
        RAHeadModel *headModel = [self ra_generatorModelWithDictionary:resault ModelName:[NSString stringWithFormat:@"%@Model",obj]];
        
        [model.classArray addObject:headModel.className];
        [model.headArray addObject:headModel.head];
        [model.footerArray addObject:headModel.footer];
        if (model.modelArrayString.length == 0) {
            [model.modelArrayString appendFormat:@"@\"%@\" : @\"%@%@Model\"", obj, _prefix,[self capitalized:obj]];
        } else {
            [model.modelArrayString appendFormat:@",\n@\"%@\" : @\"%@%@Model\"\n", obj, _prefix,[self capitalized:obj]];
        }
    }
    return model;
}

+ (NSString *)capitalized:(NSString *)string {
    NSMutableString *mStr = [NSMutableString stringWithString:string];
    if (string && string.length > 0) {
        char c = [string characterAtIndex:0];
        if(c>='a' && c<='z')
            c-=32;
        [mStr replaceCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithFormat:@"%c",c]];
    }
    return mStr;
}

+ (id)returnFirstObjWithArr:(NSArray *)obj {
    
    if ([obj count] == 0) return nil;
    if ([[obj firstObject] isKindOfClass:[NSArray class]]) {
        return  [self returnFirstObjWithArr:[obj firstObject]];
    } else {
        return [obj firstObject];
    }
}

@end
