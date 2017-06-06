//
//  TestYTXModuleJumpSpec.m
//  YTXModule
//
//  Created by 奚潇川 on 06/06/2017.
//  Copyright © 2017 caojun. All rights reserved.
//

#import <YTXModule/YTXModuleJump.h>

NSString *sign;

@interface YTXModuleJump (Test)

- (void)jumpTest:(NSDictionary *)data from:(UIViewController *)viewController;

@end

@implementation YTXModuleJump (Test)

- (void)jumpTest:(NSDictionary *)data from:(UIViewController *)viewController {
    sign = @"success";
}

@end

SPEC_BEGIN(InitialTestYTXModuleJumpSpec)

describe(@"测试YTXModuleJump", ^{
    it(@"跳转Jump成功", ^{
        [YTXModuleJump jumpPage:@"TEST" data:nil from:nil];
        [[sign should] equal:@"success"];
    });
});

SPEC_END
