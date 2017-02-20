# YTXModule

## Example
In .m
```objective-c
YTXMODULE_EXTERN()
{
    //This is load
    isLoad = YES;
}

//check userInfo/completion should be nil

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

other .m
```objective-c
[YTXModule openURL:@"URL" withUserInfo:@{@"Test":@1} completion:^(id result) {
    NSLog(@"completion:%@", result);
}];

NSString * testObject1 = [YTXModule objectForURL:@"object" withUserInfo:@{@"Test":@1}];

[YTXModule openURL:@"YTX://QUERY/query?age=18&name=CJ"];
```

Application life. Support all application life.
```objective-c
YTXMODULE_EXTERN()
{
    
}
+ (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    applicationLifCycle1 = YES;
    [YTXModule registerURLPattern:@"YTX://Test/targetSelector" withTarget:self withSelector:@selector(testRegisterTargetSelector)];
    testRegisterTargetSelector = [YTXModule objectForURL:@"YTX://Test/targetSelector"];
    return YES;
}
```

```objective-c
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [YTXModule registerAppDelegateObject:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [YTXModule unregisterAppDelegateObject:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"Receive BecomeActive");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Receive ResignActive");
}
```

More infomation, please check [test case](https://github.com/mdsb100/YTXModule/blob/master/Example/Tests/TestYTXModuleSpec.m)

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
