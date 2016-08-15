# YTXModule

## Example
在.m中
```objective-c
YTXMODULE_EXTERN()
{
    //相当于load
    isLoad = YES;
}

//记得判断 userInfo, completion是否为空

YTXMODULE_EXTERN_ROUTER_METHOD(@"URL")
{
    YTXMODULE_EXAPAND_PARAMETERS(parameters)
    NSLog(@"%@ %@", userInfo, completion);
    isCallRouterMacro1 = YES;
    completionExits = completion;
    userInfoExits = userInfo;
    completion(@"Success");
}

YTXMODULE_EXTERN_ROUTER_OBJECT_METHOD(@"object")
{
    YTXMODULE_EXAPAND_PARAMETERS(parameters)
    NSLog(@"%@ %@", userInfo, completion);
    isCallRouterObjectMacro1 = YES;
    completionExits1 = completion;
    userInfoExits1 = userInfo;
    return @"我是个类型";
}

YTXMODULE_EXTERN_ROUTER_METHOD(@"YTX://QUERY/:query")
{
    YTXMODULE_EXAPAND_PARAMETERS(parameters)
    NSLog(@"%@ %@", userInfo, completion);
    
    testQueryStringQueryValue = parameters[@"query"];;
    testQueryStringNameValue = parameters[@"name"];
    testQueryStringAgeValue = parameters[@"age"];
}

```
在其他地方
```objective-c
[YTXModule openURL:@"URL" withUserInfo:@{@"Test":@1} completion:^(id result) {
    NSLog(@"completion:%@", result);
}];

NSString * testObject1 = [YTXModule objectForURL:@"object" withUserInfo:@{@"Test":@1}];

[YTXModule openURL:@"YTX://QUERY/query?age=18&name=CJ"];
```

## Requirements

## Installation

YTXModule is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "YTXModule"
```

## Author

caojun, 78612846@qq.com

## License

YTXModule is available under the MIT license. See the LICENSE file for more info.
