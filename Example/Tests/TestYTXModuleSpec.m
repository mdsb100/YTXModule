//
//  TestYTXModuleSpec.m
//  TestYTXModuleSpec
//
//  Created by caojun on 08/12/2016.
//  Copyright (c) 2016 caojun. All rights reserved.
//

// https://github.com/kiwi-bdd/Kiwi

#import <YTXModule/YTXModule.h>

static BOOL isLoad = NO;
static BOOL applicationLifCycle1 = NO;
static BOOL applicationLifCycle2 = NO;
static BOOL applicationLifCycle3 = NO;

static BOOL isCallRouterMacro1 = NO;
static BOOL isCallRouterMacro2 = NO;
static BOOL isCallRouterMacro3 = NO;

static BOOL isCallRouterObjectMacro1 = NO;
static BOOL isCallRouterObjectMacro2 = NO;
static BOOL isCallRouterObjectMacro3 = NO;

static NSString * testQueryStringQueryValue = nil;
static NSString * testQueryStringNameValue = nil;
static NSString * testQueryStringAgeValue = nil;
static NSString * testRegisterTargetSelector = nil;

static id completionExits = nil;
static id userInfoExits = nil;

static id completionExits1 = nil;
static id userInfoExits1 = nil;

static BOOL isCallNOParametersAndCompletion = NO;
static id testUserInfoNoExits = nil;
static id testCompletionNoExits = nil;
static id testUserInfoNoExits1 = nil;
static id testCompletionNoExits1 = nil;

static id testCover;

static id testCoverA;

static id testCoverB;

static id testCoverANotExits;

static int testWillCallObjectForUrl = 0;
static int testOnceWillCallObjectForUrl = 0;
static int testWillCallOpenUrl = 0;
static int testOnceWillCallOpenUrl = 0;

@interface YTXTestModuleA : YTXModule

@end

@implementation YTXTestModuleA

YTXMODULE_EXTERN()
{
    //相当于load
    isLoad = YES;
}



YTXMODULE_EXTERN_ROUTER_METHOD(@"URL")
{
    YTXMODULE_EXAPAND_PARAMETERS(parameters)
    NSLog(@"%@ %@", userInfo, completion);
    isCallRouterMacro1 = YES;
    completionExits = completion;
    userInfoExits = userInfo;
    completion(@"Success");
}

YTXMODULE_EXTERN_ROUTER_METHOD(@"URL1")
{
    YTXMODULE_EXAPAND_PARAMETERS(parameters)
    NSLog(@"%@ %@", userInfo, completion);
    isCallRouterMacro2 = YES;
    completion(@"Success");
}

YTXMODULE_EXTERN_ROUTER_METHOD(@"URL1_NO_CALL")
{
    YTXMODULE_EXAPAND_PARAMETERS(parameters)
    NSLog(@"%@ %@", userInfo, completion);
    isCallRouterMacro3 = YES;
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

YTXMODULE_EXTERN_ROUTER_OBJECT_METHOD(@"object1")
{
    YTXMODULE_EXAPAND_PARAMETERS(parameters)
    NSLog(@"%@ %@", userInfo, completion);
    isCallRouterObjectMacro2 = YES;
    return @"我是个类型";
}

YTXMODULE_EXTERN_ROUTER_OBJECT_METHOD(@"object1_NO_CALL")
{
    YTXMODULE_EXAPAND_PARAMETERS(parameters)
    NSLog(@"%@ %@", userInfo, completion);
    isCallRouterObjectMacro3 = YES;
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

YTXMODULE_EXTERN_ROUTER_METHOD(@"NOParametersAndCompletion")
{
    YTXMODULE_EXAPAND_PARAMETERS(parameters)
    
    isCallNOParametersAndCompletion = YES;
    testUserInfoNoExits = userInfo;
    
    testCompletionNoExits = completion;
}

YTXMODULE_EXTERN_ROUTER_METHOD(@"YTX://Test/A")
{
    testCoverANotExits=@1;
}

YTXMODULE_EXTERN_ROUTER_METHOD(@"YTX://Test/A")
{
    testCoverA=@1;
}

YTXMODULE_EXTERN_ROUTER_METHOD(@"YTX://Test/B")
{
    testCoverB=@1;
}

YTXMODULE_EXTERN_ROUTER_METHOD(@"YTX://Test")
{
    testCover=@1;
}

+ (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    applicationLifCycle1 = YES;
    [YTXModule registerURLPattern:@"YTX://Test/targetSelector" withTarget:self withSelector:@selector(testRegisterTargetSelector)];
    testRegisterTargetSelector = [YTXModule objectForURL:@"YTX://Test/targetSelector"];
    return YES;
}

+ (NSString *)testRegisterTargetSelector {
    return @"1024 Hello World";
}

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    applicationLifCycle2 = YES;
    return YES;
}

+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options {
    NSLog(@"----------------------");
    return YES;
}

+ (void)applicationDidBecomeActive:(UIApplication *)application
{
    applicationLifCycle3 = YES;
    
}

+ (void)onceWillCallOpenUrl {
    testOnceWillCallOpenUrl++;
}

+ (void)willCallOpenUrl {
    testWillCallOpenUrl++;
}


+ (void)onceWillCallObjectForUrl {
    testOnceWillCallObjectForUrl++;
}

+ (void)willCallObjectForUrl {
    testWillCallObjectForUrl++;
}

@end

//@interface YTXTestModuleB : NSObject
//
//@end
//
//@implementation YTXTestModuleB
//
//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//    
//}
//
//@end


SPEC_BEGIN(InitialTestYTXModuleSpec)

describe(@"测试YTXModule", ^{
//    YTXTestModuleB * b = [YTXTestModuleB new];
//    [YTXModule registerAppDelegateObject:b];
    
    context(@"测试YTXMODULE_EXTERN宏", ^{
        it(@"检查YTXMODULE_EXTERN这个宏的包体会被调用", ^{
            [[@(isLoad) should] equal:@1];
        });
    });
    
    context(@"测试YTXMODULE注册方法", ^{
        it(@"检查注册方法是否被调用", ^{
            [[testRegisterTargetSelector should] equal:@"1024 Hello World"];
        });
    });
    
    context(@"测试runtime扩展Application生命周期的方法", ^{
        it(@"检查方法被调用：+ (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions", ^{
            [[@(applicationLifCycle1) should] equal:@1];
        });
        it(@"检查方法被调用：+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions", ^{
            [[@(applicationLifCycle2) should] equal:@1];
        });
//        it(@"检查方法被调用：+ (void)applicationDidBecomeActive:(UIApplication *)application", ^{
//            [[@(applicationLifCycle3) should] equal:@1];
//        });
    });
    
    context(@"测试Router", ^{
        it(@"检查宏被调用：YTXMODULE_EXTERN_ROUTER_METHOD", ^{
            [[@(isCallRouterMacro1) should] equal:@1];
            [[@(isCallRouterMacro2) should] equal:@1];
            [[@(isCallRouterMacro3) should] equal:@0];
        });
        it(@"检查宏被调用：YTXMODULE_EXTERN_ROUTER_OBJECT_METHOD", ^{
            [[@(isCallRouterObjectMacro1) should] equal:@1];
            [[@(isCallRouterObjectMacro2) should] equal:@1];
            [[@(isCallRouterObjectMacro3) should] equal:@0];
        });
        it(@"检查URL Query Paramete语法会被自动解析:YTX://QUERY/query?age=18&name=CJ", ^{
            [[testQueryStringQueryValue should] equal:@"query"];
            [[testQueryStringNameValue should] equal:@"CJ"];
            [[testQueryStringAgeValue should] equal:@"18"];
        });
        it(@"检查router中parameters中的userInfo和completion不为空", ^{
            [[userInfoExits shouldNot] beNil];
            [[completionExits shouldNot] beNil];
        });
        
        it(@"检查object中parameters中的userInfo不为空，completion为空", ^{
            [[userInfoExits1 shouldNot] beNil];
            [[completionExits1 should] beNil];
        });
        it(@"检查不传UserInfo和Completion确实取不到", ^{
            [[@(isCallNOParametersAndCompletion) should] equal:@1];
            [[testUserInfoNoExits should] beNonNil];
            [[testCompletionNoExits should] beNil];
            [[testUserInfoNoExits1 should] beNil];
            [[testCompletionNoExits1 should] beNil];
        });
        
        it(@"检查router不会覆盖", ^{
            [testCover shouldNotBeNil];
            [testCoverANotExits shouldBeNil];
            [testCoverA shouldNotBeNil];
            [testCoverB shouldNotBeNil];
        });
        
        it(@"register unregister url", ^{
            NSString * url = @"method://testregister";
            UIViewController * vc = [UIViewController new];
            [YTXModule registerURLPattern:url withTarget:vc withSelector:@selector(viewDidLoad)];
            
            BOOL ret = [YTXModule canOpenURL:url];
            
            [[@(ret) should] equal:@YES];
            
            [YTXModule deregisterURLPattern:url];
            
            ret = [YTXModule canOpenURL:url];
            
            [[@(ret) should] equal:@NO];
        });
        
        it(@"generateURLWithPattern", ^{
            NSString * url = [YTXModule generateURLWithPattern:@"object://test/:id/:kk" parameters:@[@10, @"name"]];
            
            [[url should] equal:@"object://test/10/name"];
        });
        
        it(@"unregisterAppDelegate", ^{
            [YTXModule registerAppDelegateModule:[YTXTestModuleA class]];
            [YTXModule unregisterAppDelegateObject:[YTXTestModuleA class]];
        });
    });
  
    context(@"测试willCallObjectForUrl", ^{
        it(@"检查多次willCallObjectForUrl", ^{
            [[@(testWillCallObjectForUrl) should] beGreaterThan:@1];
        });
        
        it(@"检查一次willOnceCallObjectForUrl", ^{
            [[@(testOnceWillCallObjectForUrl) should] equal:@1];
        });
    });
    
});

SPEC_END

