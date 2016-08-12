//
//  YTXTestModule.m
//  Pods
//
//  Created by CaoJun on 16/8/12.
//
//

#import "YTXTestModule.h"

@implementation YTXTestModule

YTX_EXTERN_APPDELEGATE_MODULE()

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"YTXTestModule didFinishLaunchingWithOptions");
    return YES;
}

@end

