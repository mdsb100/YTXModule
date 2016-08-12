//
//  YTXModule.m
//  Pods
//
//  Created by CaoJun on 16/8/12.
//
//

#import "YTXModule.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>

#define ADD_SELECTOR_PREFIX(__SELECTOR__) @selector(ytxmodule_##__SELECTOR__)

#define SWIZZLE_DELEGATE_METHOD(__SELECTORSTRING__) \
Swizzle([delegate class], @selector(__SELECTORSTRING__), class_getClassMethod([YTXModule class], ADD_SELECTOR_PREFIX(__SELECTORSTRING__))); \

#define APPDELEGATE_METHOD_MSG_SEND(__SELECTOR__, __ARG1__, __ARG2__) \
for (Class cls in YTXModuleClasses) { \
if ([cls respondsToSelector:__SELECTOR__]) { \
    [cls performSelector:__SELECTOR__ withObject:__ARG1__ withObject:__ARG2__]; \
} \
}

#define SELECTOR_IS_EQUAL(__SELECTOR1__, __SELECTOR2__) \
Method m1 = class_getClassMethod([YTXModule class], __SELECTOR1__); \
IMP imp1 = method_getImplementation(m1); \
Method m2 = class_getInstanceMethod([self class], __SELECTOR2__); \
IMP imp2 = method_getImplementation(m2); \

#define DEF_APPDELEGATE_METHOD_CONTAIN_RESULT(__ARG1__, __ARG2__) \
BOOL result = YES; \
SEL ytx_selector = NSSelectorFromString([NSString stringWithFormat:@"ytxmodule_%@", NSStringFromSelector(_cmd)]); \
SELECTOR_IS_EQUAL(ytx_selector, _cmd) \
if (imp1 != imp2) { \
    result = [YTXModule performSelector:ytx_selector withObject:__ARG1__ withObject:__ARG2__]; \
} \
APPDELEGATE_METHOD_MSG_SEND(_cmd, __ARG1__, __ARG2__); \
return result; \

#define DEF_APPDELEGATE_METHOD(__ARG1__, __ARG2__) \
SEL ytx_selector = NSSelectorFromString([NSString stringWithFormat:@"ytxmodule_%@", NSStringFromSelector(_cmd)]); \
SELECTOR_IS_EQUAL(ytx_selector, _cmd) \
if (imp1 != imp2) { \
    [YTXModule performSelector:ytx_selector withObject:__ARG1__ withObject:__ARG2__]; \
} \
APPDELEGATE_METHOD_MSG_SEND(_cmd, __ARG1__, __ARG2__); \


void Swizzle(Class class, SEL originalSelector, Method swizzledMethod)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    SEL swizzledSelector = method_getName(swizzledMethod);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod && originalMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation UIApplication (YTXModule)
- (void)module_setDelegate:(id<UIApplicationDelegate>) delegate
{
    
    static dispatch_once_t delegateOnceToken;
    dispatch_once(&delegateOnceToken, ^{
        SWIZZLE_DELEGATE_METHOD(applicationDidFinishLaunching:);
        SWIZZLE_DELEGATE_METHOD(application: willFinishLaunchingWithOptions:);
        SWIZZLE_DELEGATE_METHOD(application: didFinishLaunchingWithOptions:);
        SWIZZLE_DELEGATE_METHOD(applicationDidBecomeActive:)
        SWIZZLE_DELEGATE_METHOD(applicationWillResignActive:)
        SWIZZLE_DELEGATE_METHOD(application: openURL: options:)
        SWIZZLE_DELEGATE_METHOD(applicationDidReceiveMemoryWarning:)
        SWIZZLE_DELEGATE_METHOD(applicationWillTerminate:)
        SWIZZLE_DELEGATE_METHOD(applicationSignificantTimeChange:);
        SWIZZLE_DELEGATE_METHOD(application: didRegisterForRemoteNotificationsWithDeviceToken:)
        SWIZZLE_DELEGATE_METHOD(application: didFailToRegisterForRemoteNotificationsWithError:)
        SWIZZLE_DELEGATE_METHOD(application: didReceiveRemoteNotification:)
        SWIZZLE_DELEGATE_METHOD(application: handleEventsForBackgroundURLSession: completionHandler:)
        SWIZZLE_DELEGATE_METHOD(application: handleWatchKitExtensionRequest: reply:)
        SWIZZLE_DELEGATE_METHOD(applicationShouldRequestHealthAuthorization:)
        SWIZZLE_DELEGATE_METHOD(applicationDidEnterBackground:)
        SWIZZLE_DELEGATE_METHOD(applicationWillEnterForeground:)
        SWIZZLE_DELEGATE_METHOD(applicationProtectedDataWillBecomeUnavailable:)
        SWIZZLE_DELEGATE_METHOD(applicationProtectedDataDidBecomeAvailable:)
    });
    
    [self module_setDelegate:delegate];
}
@end

BOOL YTXModuleClassIsRegistered(Class cls)
{
    return [objc_getAssociatedObject(cls, &YTXModuleClassIsRegistered) ?: @YES boolValue];
}

static NSMutableArray<Class> *YTXModuleClasses;

@interface YTXModule()

@property (nonatomic, assign) BOOL ready;

@end

@implementation YTXModule


+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Swizzle([UIApplication class], @selector(setDelegate:), class_getInstanceMethod([UIApplication class], @selector(module_setDelegate:)));
    });
}

+ (void)registerAppDelegateModule:(Class) moduleClass
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YTXModuleClasses = [NSMutableArray new];
    });
    
    // Register module
    [YTXModuleClasses addObject:moduleClass];
    
    objc_setAssociatedObject(moduleClass, &YTXModuleClassIsRegistered,
                             @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (nullable UIViewController *) createRootViewControllerWithOptions:(nullable NSDictionary *) options
{
    return NULL;
}

#pragma mark - AppDelegate

+ (void)applicationDidFinishLaunching:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}


+ (BOOL)ytxmodule_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    DEF_APPDELEGATE_METHOD_CONTAIN_RESULT(application, launchOptions);
}

+ (BOOL)ytxmodule_application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions
{
    DEF_APPDELEGATE_METHOD_CONTAIN_RESULT(application, launchOptions);
}

+ (void)applicationDidBecomeActive:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)applicationWillResignActive:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options NS_AVAILABLE_IOS(9_0); // no equiv. notification. return NO if the application can't open for some reaso
{
    SEL ytx_selector = NSSelectorFromString([NSString stringWithFormat:@"ytxmodule_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(ytx_selector, _cmd)
    if (imp1 != imp2) {
        [YTXModule application:app openURL:url options:options];
    }
    id (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;
    for (Class cls in YTXModuleClasses) {
        if ([cls respondsToSelector:_cmd]) {
            typed_msgSend(cls, _cmd, app, url, options);
        }
    }
}
+ (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;      // try to clean up as much memory as possible. next step is to terminate ap
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)applicationWillTerminate:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)applicationSignificantTimeChange:(UIApplication *)application;        // midnight, carrier time update, daylight savings time chang
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken NS_AVAILABLE_IOS(3_0)
{
    DEF_APPDELEGATE_METHOD(application, deviceToken);
}
+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_IOS(3_0)
{
    DEF_APPDELEGATE_METHOD(application, error);
}
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(3_0)
{
    DEF_APPDELEGATE_METHOD(application, userInfo);
}
+ (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler NS_AVAILABLE_IOS(7_0)
{
    SEL ytx_selector = NSSelectorFromString([NSString stringWithFormat:@"ytxmodule_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(ytx_selector, _cmd)
    if (imp1 != imp2) {
        [YTXModule application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
    }
    id (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;
    for (Class cls in YTXModuleClasses) {
        if ([cls respondsToSelector:_cmd]) {
            typed_msgSend(cls, _cmd, application, identifier, completionHandler);
        }
    }
}
+ (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply NS_AVAILABLE_IOS(8_2)
{
    SEL ytx_selector = NSSelectorFromString([NSString stringWithFormat:@"ytxmodule_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(ytx_selector, _cmd)
    if (imp1 != imp2) {
        [YTXModule application:application handleWatchKitExtensionRequest:userInfo reply:reply];
    }
    id (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;
    for (Class cls in YTXModuleClasses) {
        if ([cls respondsToSelector:_cmd]) {
            typed_msgSend(cls, _cmd, application, userInfo, reply);
        }
    }
}
+ (void)applicationShouldRequestHealthAuthorization:(UIApplication *)application NS_AVAILABLE_IOS(9_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)applicationDidEnterBackground:(UIApplication *)application NS_AVAILABLE_IOS(4_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)applicationWillEnterForeground:(UIApplication *)application NS_AVAILABLE_IOS(4_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application NS_AVAILABLE_IOS(4_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)applicationProtectedDataDidBecomeAvailable:(UIApplication *)application    NS_AVAILABLE_IOS(4_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
@end
