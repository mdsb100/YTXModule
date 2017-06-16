//
//  TestYTXModuleJumpSpec.m
//  YTXModule
//
//  Created by 奚潇川 on 06/06/2017.
//  Copyright © 2017 caojun. All rights reserved.
//

#import <YTXModule/YTXModuleJump.h>

UIViewController *sign;

static id testVC1;
static id testVC2;
static id testUserInfo;
static id testCompletion;

@interface YTXModuleJump (Test)

+ (void)jumpTest:(NSDictionary *)data from:(UIViewController *)viewController;

@end

@implementation YTXModuleJump (Test)

+ (void)jumpTest:(NSDictionary *)data from:(UIViewController *)viewController {
    sign = viewController;
}

@end

@interface YTXTest : YTXModule

@end

@implementation YTXTest

YTXMODULE_EXTERN_ROUTER_METHOD(@"YTX://SVC")
{
    YTXMODULE_SOURCE_VIEWCONTROLLER(vc);
    testVC1 = vc;
}

YTXMODULE_EXTERN_ROUTER_METHOD(@"YTX://SVC/ALL")
{
    YTXMODULE_EXAPAND_VIEWCONTROLLER_USRINFO_COMPLETION(vc, userinfo, completion);
    testVC2 = vc;
    testUserInfo = userinfo;
    testCompletion = completion;
    completion(@15);
}

YTXMODULE_EXTERN()
{
    //相当于load
    
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

describe(@"测试jumpWithUrl", ^{
    it(@"只传vc", ^{
        UIViewController *viewController = [UIViewController new];
        [YTXModuleJump jumpWithUrl:@"YTX://SVC" fromViewController:viewController];
        [[testVC1 should] equal:viewController];
    });
    
    it(@"传所有参数", ^{
        static id testResult;
        UIViewController *viewController = [UIViewController new];
        
        [YTXModuleJump jumpWithUrl:@"YTX://SVC/ALL" fromViewController:viewController userInfo:@{@"test":@1} completion:^(id result) {
            testResult = result;
        }];
        
        [[testVC2 should] equal:viewController];
        [[testUserInfo should] beNonNil];
        [[testUserInfo[@"test"] should] equal:@1];
        [[testCompletion should] beNonNil];
        [[testResult should] equal:@15];
    });
});

SPEC_END
