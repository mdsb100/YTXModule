//
//  YTXModule.h
//  Pods
//
//  Created by CaoJun on 16/8/12.
//
//

#import <Foundation/Foundation.h>

#define YTX_EXTERN_APPDELEGATE_MODULE() \
+ (void)load \
{ \
    [YTXModule registerAppDelegateModule:self]; \
} \


@interface YTXModule : NSObject

@property (nonatomic, readonly, assign) BOOL ready;

+ (void) registerAppDelegateModule:(Class) moduleClass;

+ (nullable UIViewController *) createRootViewControllerWithOptions:(nullable NSDictionary *) options;

@end
