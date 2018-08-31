//
//  RAGeneratorModel.h
//  ModelGenerator
//
//  Created by fumi on 2018/8/31.
//  Copyright © 2018年 fumi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RAGeneratorModel : NSObject
@property (nonatomic, strong) NSMutableArray *headArray;
@property (nonatomic, strong) NSMutableArray *footerArray;
@property (nonatomic, strong) NSMutableArray *classArray;

@property (nonatomic, strong) NSMutableString *modelArrayString;
@property (nonatomic, strong) NSMutableString *headStr;
@property (nonatomic, strong) NSMutableString *footerStr;
@property (nonatomic, strong) NSNumber *number;
@end

@interface RAHeadModel : NSObject
@property (nonatomic, strong) NSString *head;
@property (nonatomic, strong) NSString *footer;
@property (nonatomic, strong) NSString *className;
@end

