//
//  YTXTestModule.m
//  Pods
//
//  Created by CaoJun on 16/8/12.
//
//

#import "YTXTestModule.h"
#import <objc/runtime.h>

@implementation YTXTestModule

YTXMODULE_EXTERN()
{

}

YTXMODULE_EXTERN_ROUTER_METHOD(@"URL")
{
    YTXMODULE_EXAPAND_PARAMETERS(parameters)
    NSLog(@"%@ %@", userInfo, completion);
    completion(@"Success");
}

YTXMODULE_EXTERN_ROUTER_OBJECT_METHOD(@"object")
{
    YTXMODULE_EXAPAND_PARAMETERS(parameters)
    NSLog(@"%@ %@", userInfo, completion);
    return @"我是个类型";
}



+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"YTXTestModule didFinishLaunchingWithOptions");
    return YES;
}

@end

