# ModelGenerator
通过JSon文件快速生成模型结构，当然需要进行微调了。

使用方式如下：

> 1. 编译生成ModelGenerator
> 2. 终端执行命令 ./ModelGenerator /Users/Rayor/Desktop/Directions.geojson > demo.m



生成一个demo.m文件，从文件中可以直接看到结果，自己再去编辑调整名称即可。

```

====================@interface==================

@class FMGeneratorModel;
@class FMDataModel;


/** <#desc#> */
@interface FMGeneratorModel : NSObject

/** <#desc#> */
@property (nonatomic, copy)   NSString *msg;
/** <#desc#> */
@property (nonatomic, strong) DataModel *data;
/** <#desc#> */
@property (nonatomic, copy)   NSString *code;

@end

/** <#desc#> */
@interface FMDataModel : NSObject

/** <#desc#> */
@property (nonatomic, copy)   NSString *goods_thumb;
/** <#desc#> */
@property (nonatomic, copy)   NSString *good_deatail_shareh5;

@end

====================@implementation====================

@implementation FMGeneratorModel

@end

@implementation FMDataModel

@end


```

