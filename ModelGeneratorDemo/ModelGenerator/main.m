//
//  main.m
//  ModelGenerator
//
//  Created by fumi on 2018/8/31.
//  Copyright © 2018年 fumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+ModelGenerator.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2 || argc > 3) {
            printf("格式如下：ModelGenerator filePath type\ntype: 0 使用MJ格式， 1使用YYModel格式，默认使用YYModel\n");
            return 0;
        }
        NSString *path = [NSString stringWithUTF8String:argv[1]];
        RAModelGeneratorType type = 1;
        if (argc == 3) {
            NSString *typeStr = [NSString stringWithUTF8String:argv[2]];
            if (typeStr.integerValue == 0) {
                type = 0;
            }
        }
        [NSObject ra_generatorModelWithJsonPath:path prefix:@"FM" outsideModelName:@"GeneratorModel" makeType:type];

        // 调试使用
//        NSString *filePath = [NSHomeDirectory() stringByAppendingString:@"/Desktop/ModelGenerator/Directions.geojson"];
//        [NSObject ra_generatorModelWithJsonPath:filePath prefix:@"FM" outsideModelName:@"TESTMODEL" makeType:RAModelGeneratorTypeYY];
//
    }
    return 0;
}
