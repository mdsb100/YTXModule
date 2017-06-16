//
//  YTXModuleJump.m
//  Pods
//
//  Created by 奚潇川 on 06/06/2017.
//
//

#import "YTXModuleJump.h"

NSString *const YTXModuleRouterParameterSourceViewController = @"YTXModuleRouterParameterSourceViewController";

@implementation YTXModuleJump

+ (void)jumpPage:(NSString *)page data:(NSDictionary *)data from:(UIViewController *)viewController {
    SEL s = NSSelectorFromString([NSString stringWithFormat:@"jump%@:from:", page]);
    if ([self respondsToSelector:s]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:s withObject:data ?: @{} withObject:viewController];
#pragma clang diagnostic pop
    }
}

+ (BOOL)jumpWithUrl:(nonnull NSString *)url fromViewController:(nonnull UIViewController *) fromViewController
{
    BOOL ret = [YTXModule canOpenURL:url];
    if(ret) {
        [YTXModule openURL:url withUserInfo:@{YTXModuleRouterParameterSourceViewController: fromViewController} completion:nil];
    }
    return ret;
}

+ (BOOL)jumpWithUrl:(nonnull NSString *)url fromViewController:(nonnull UIViewController *) fromViewController userInfo:(nullable NSDictionary *)userInfo completion:(nullable void (^)(_Nullable id result))completion
{
    BOOL ret = [YTXModule canOpenURL:url];
    if(ret) {
        NSMutableDictionary * newUserInfo;
        newUserInfo = userInfo ? [userInfo mutableCopy] : [NSMutableDictionary dictionary];
        [newUserInfo setObject:fromViewController forKey:YTXModuleRouterParameterSourceViewController];
        [YTXModule openURL:url withUserInfo:newUserInfo completion:completion];
    }
    return ret;
}

@end
