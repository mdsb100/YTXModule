//
//  YTXModuleJump.m
//  Pods
//
//  Created by 奚潇川 on 06/06/2017.
//
//

#import "YTXModuleJump.h"

@implementation YTXModuleJump

+ (void)jumpPage:(NSString *)page data:(NSDictionary *)data from:(UIViewController *)viewController {
    SEL s = NSSelectorFromString([NSString stringWithFormat:@"jump%@:from:", page]);
    if ([YTXModuleJump respondsToSelector:s]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ([viewController respondsToSelector:NSSelectorFromString(@"viewWillGoto")]) {
            [viewController performSelector:NSSelectorFromString(@"viewWillGoto")];
        }
        [YTXModuleJump performSelector:s withObject:data ?: @{} withObject:viewController];
        if ([viewController respondsToSelector:NSSelectorFromString(@"viewDidGoto")]) {
            [viewController performSelector:NSSelectorFromString(@"viewDidGoto")];
        }
#pragma clang diagnostic pop
    }
}

- (void)jumpExample:(NSDictionary *)data from:(UIViewController *)viewController {
    
}

@end
