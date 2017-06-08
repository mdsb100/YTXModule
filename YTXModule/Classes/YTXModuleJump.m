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
    if ([self respondsToSelector:s]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:s withObject:data ?: @{} withObject:viewController];
#pragma clang diagnostic pop
    }
}

@end
