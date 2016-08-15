//
//  YTXViewController.m
//  YTXModule
//
//  Created by caojun on 08/12/2016.
//  Copyright (c) 2016 caojun. All rights reserved.
//

#import "YTXViewController.h"

#import <MGJRouter/MGJRouter.h>

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
    
    
    NSString * testObject = [YTXModule objectForURL:@"object" withUserInfo:@{@"Test":@2}];
    NSLog(@"%@", testObject);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
