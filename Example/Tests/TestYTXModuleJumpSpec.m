//
//  TestYTXModuleJumpSpec.m
//  YTXModule
//
//  Created by 奚潇川 on 06/06/2017.
//  Copyright © 2017 caojun. All rights reserved.
//


SPEC_BEGIN(InitialTestYTXModuleSpec)

describe(@"测试YTXModuleJump", ^{
    it(@"检查router不会覆盖", ^{
        [[@1 should] equal:@1];
    });
});

SPEC_END
