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
    return YES;
}

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    applicationLifCycle2 = YES;
    return YES;
}

+ (void)applicationDidBecomeActive:(UIApplication *)application
{
    applicationLifCycle3 = YES;
    
}

@end


SPEC_BEGIN(InitialTestYTXModuleSpec)

describe(@"测试YTXModule", ^{
    context(@"测试YTXMODULE_EXTERN宏", ^{
        it(@"检查YTXMODULE_EXTERN这个宏的包体会被调用", ^{
            [[@(isLoad) should] equal:@1];
        });
    });
    
    
    context(@"测试runtime扩展Application生命周期的方法", ^{
        it(@"检查方法被调用：+ (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions", ^{
            [[@(applicationLifCycle1) should] equal:@1];
        });
        it(@"检查方法被调用：+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions", ^{
            [[@(applicationLifCycle2) should] equal:@1];
        });
        it(@"检查方法被调用：+ (void)applicationDidBecomeActive:(UIApplication *)application", ^{
            [[@(applicationLifCycle3) should] equal:@1];
        });
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
            [[testUserInfoNoExits should] beNil];
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
    });
  
});

SPEC_END

