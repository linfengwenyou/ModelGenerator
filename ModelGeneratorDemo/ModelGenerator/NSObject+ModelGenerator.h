//
//  NSObject+ModelGenerator.h
//  ModelGenerator
//
//  Created by fumi on 2018/8/31.
//  Copyright © 2018年 fumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RAGeneratorModel.h"


typedef NS_ENUM(NSInteger,RAModelGeneratorType) {
    RAModelGeneratorTypeMJ = 0,         // 使用MJExtension
    RAModelGeneratorTypeYY              // 使用YYModel配置
};

@interface NSObject (ModelGenerator)
@property (nonatomic, assign, class) RAModelGeneratorType generatorType;
@property (nonatomic, strong, class) NSString *prefix;
@property (nonatomic, strong, class) RAHeadModel *headModel;

/**
 根据字典打印出对应属性模型
 
 @param dictionary 数据字典
 @param prefix 模型前缀关键字 eg: DY....
 @param outsideModelName 最外层模型名称,如果设置了前缀关键字会自动加上
 @param generatorType 使用MJExtension 还是YYModel 自动生成模型中系统关键字替换和数组中字典转模型语法代码
 
 */
+ (void)DY_makeModelWithDictionary:(NSDictionary *)dictionary
                            prefix:(NSString *)prefix
                  outsideModelName:(NSString *)outsideModelName
                          makeType:(RAModelGeneratorType)generatorType;

/** 通过json文件配置 */
+ (void)DY_makeModelWithJsonPath:(NSString *)jsonPath
                            prefix:(NSString *)prefix
                  outsideModelName:(NSString *)outsideModelName
                          makeType:(RAModelGeneratorType)generatorType;

@end
