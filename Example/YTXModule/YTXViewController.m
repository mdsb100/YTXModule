//
//  YTXViewController.m
//  YTXModule
//
//  Created by caojun on 08/12/2016.
//  Copyright (c) 2016 caojun. All rights reserved.
//

#import "YTXViewController.h"

#import <YTXModule/YTXModule.h>

@interface YTXViewController ()

@end

@implementation YTXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [YTXModule openURL:@"URL" withUserInfo:@{@"Test":@1} completion:^(id result) {
        NSLog(@"completion:%@", result);
    }];
    [YTXModule openURL:@"URL1" withUserInfo:@{@"Test":@2} completion:^(id result) {
        NSLog(@"completion:%@", result);
    }];
    [YTXModule openURL:@"YTX://QUERY/query?age=18&name=CJ"];
    [YTXModule openURL:@"NOParametersAndCompletion"];
    
    NSString * testObject1 = [YTXModule objectForURL:@"object" withUserInfo:@{@"Test":@1}];
    NSString * testObject2 = [YTXModule objectForURL:@"object1" withUserInfo:@{@"Test":@2}];
    
    [YTXModule openURL:@"YTX://Test"];
    
    [YTXModule openURL:@"YTX://Test/A"];
    
    [YTXModule openURL:@"YTX://Test/B"];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [YTXModule registerAppDelegateObject:self];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [YTXModule unregisterAppDelegateObject:self];
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [YTXModule unregisterAppDelegateObject:self];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"Receive BecomeActive");
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Receive ResignActive");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
