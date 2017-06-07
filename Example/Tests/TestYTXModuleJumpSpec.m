//
//  TestYTXModuleJumpSpec.m
//  YTXModule
//
//  Created by 奚潇川 on 06/06/2017.
//  Copyright © 2017 caojun. All rights reserved.
//

#import <YTXModule/YTXModuleJump.h>

UIViewController *sign;

@interface YTXModuleJump (Test)

+ (void)jumpTest:(NSDictionary *)data from:(UIViewController *)viewController;

@end

@implementation YTXModuleJump (Test)

+ (void)jumpTest:(NSDictionary *)data from:(UIViewController *)viewController {
    sign = viewController;
}

@end

SPEC_BEGIN(InitialTestYTXModuleJumpSpec)

describe(@"测试YTXModuleJump", ^{
    it(@"跳转Jump成功", ^{
        UIViewController *viewController = [UIViewController new];
        [YTXModuleJump jumpPage:@"Test" data:nil from:viewController];
        [[sign should] equal:viewController];
    });
});

SPEC_END
