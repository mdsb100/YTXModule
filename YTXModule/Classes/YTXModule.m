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
} \
\
for (id obj in YTXModuleObjects) { \
id target = [obj nonretainedObjectValue];\
if ([target respondsToSelector:__SELECTOR__]) { \
[target performSelector:__SELECTOR__ withObject:__ARG1__ withObject:__ARG2__]; \
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
result = !![self performSelector:ytx_selector withObject:__ARG1__ withObject:__ARG2__]; \
} \
APPDELEGATE_METHOD_MSG_SEND(_cmd, __ARG1__, __ARG2__); \
return result; \

#define DEF_APPDELEGATE_METHOD(__ARG1__, __ARG2__) \
SEL ytx_selector = NSSelectorFromString([NSString stringWithFormat:@"ytxmodule_%@", NSStringFromSelector(_cmd)]); \
SELECTOR_IS_EQUAL(ytx_selector, _cmd) \
if (imp1 != imp2) { \
[self performSelector:ytx_selector withObject:__ARG1__ withObject:__ARG2__]; \
} \
APPDELEGATE_METHOD_MSG_SEND(_cmd, __ARG1__, __ARG2__); \

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

static NSString * const YTX_MODULE_ROUTER_WILDCARD_CHARACTER = @"~";
static NSString * const YTX_MODULE_ROUTER_SELECTOR_KEY = @"selector";
static NSString * const YTX_MODULE_ROUTER_CLASS_KEY = @"cls";

static char YTXModuleOnceFlagOfOpenUrl;
static char YTXModuleOnceFlagOfObjectOfUrl;

NSString *const YTXModuleRouterParameterURL = @"YTXModuleRouterParameterURL";
NSString *const YTXModuleRouterParameterCompletion = @"YTXRouterParameterCompletion";
NSString *const YTXModuleRouterParameterUserInfo = @"YTXModuleRouterParameterUserInfo";

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
    //
    class_addMethod(class,
                    swizzledSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
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
        SWIZZLE_DELEGATE_METHOD(application: handleOpenURL:)
        SWIZZLE_DELEGATE_METHOD(application: openURL: sourceApplication: annotation:)
        SWIZZLE_DELEGATE_METHOD(applicationDidReceiveMemoryWarning:)
        SWIZZLE_DELEGATE_METHOD(applicationWillTerminate:)
        SWIZZLE_DELEGATE_METHOD(applicationSignificantTimeChange:);
        SWIZZLE_DELEGATE_METHOD(application: didRegisterForRemoteNotificationsWithDeviceToken:)
        SWIZZLE_DELEGATE_METHOD(application: didFailToRegisterForRemoteNotificationsWithError:)
        SWIZZLE_DELEGATE_METHOD(application: didReceiveRemoteNotification:)
        SWIZZLE_DELEGATE_METHOD(application: didReceiveLocalNotification:)
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

BOOL YTXModuleObjectIsRegistered(id x)
{
    return [objc_getAssociatedObject(x, &YTXModuleObjectIsRegistered) ?: @YES boolValue];
}

static NSMutableArray<Class> *YTXModuleClasses;

static NSMutableArray<id> *YTXModuleObjects;

@interface YTXModule()

@property (nonatomic) NSMutableDictionary *routes;

@end

@implementation YTXModule


+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Swizzle([UIApplication class], @selector(setDelegate:), class_getInstanceMethod([UIApplication class], @selector(module_setDelegate:)));
    });
}

+ (instancetype)sharedIsntance
{
    static YTXModule *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
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

+ (void) registerAppDelegateObject:(nonnull id) obj
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        YTXModuleObjects = [NSMutableArray new];
    });
    
    // Register module
    [YTXModuleObjects addObject:[NSValue valueWithNonretainedObject:obj]];
    
    objc_setAssociatedObject(obj, &YTXModuleObjectIsRegistered,
                             @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void) unregisterAppDelegateObject:(nonnull id) obj
{
    for (int i = 0; i < YTXModuleObjects.count ; i++) {
        NSValue *currentValue = YTXModuleObjects[i];
        id currentObj = [currentValue nonretainedObjectValue];
        if (currentObj == nil || currentObj == obj) {
            [YTXModuleObjects removeObject:currentValue];
            i--;
        }
    }
    
    //以安全的方式移除相关关联，而不是移除所有关联
    objc_setAssociatedObject(obj, &YTXModuleObjectIsRegistered,
                             nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void) detectRouterModule:(Class) moduleClass
{
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(object_getClass(moduleClass), &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        NSString * methodName = NSStringFromSelector(method_getName(method));
        if ([methodName hasPrefix:@"__YTXModuleRouterRegisterURL_"]) {
            [moduleClass performSelector:method_getName(method)]; \
        }
    }
    
    free(methods);
}

+ (nullable UIViewController *) createRootViewControllerWithModuleName:(nullable NSString*)moduleName options:(nullable NSDictionary *) options
{
    if (!moduleName) {
        return NULL;
    }
    Class cls = NSClassFromString(moduleName);
    return [cls performSelector:@selector(createRootViewControllerWithModuleName:options:) withObject:nil withObject:options];
}

+ (void)callOpenUrl {
    if (![self onceFlagOfOpenUrl]) {
        [self markOnceFlagOfOpenUrl];
        [self onceWillCallOpenUrl];
    }
    [self willCallOpenUrl];
}

+ (void)onceWillCallOpenUrl {
}

+ (void)willCallOpenUrl {
}

+ (void)callObjectForUrl {
    if (![self onceFlagOfObjectForUrl]) {
        [self markOnceFlagOfObjectForUrl];
        [self onceWillCallObjectForUrl];
    }
    [self willCallObjectForUrl];
}

+ (void)willCallObjectForUrl {
}

+ (void)onceWillCallObjectForUrl {
}

+ (void)markOnceFlagOfOpenUrl {
    objc_setAssociatedObject(self, &YTXModuleOnceFlagOfOpenUrl,
                             @YES,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)onceFlagOfOpenUrl {
    return [objc_getAssociatedObject(self, &YTXModuleOnceFlagOfOpenUrl) boolValue];
}

+ (void)markOnceFlagOfObjectForUrl {
    objc_setAssociatedObject(self, &YTXModuleOnceFlagOfObjectOfUrl,
                             @YES,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)onceFlagOfObjectForUrl {
    return [objc_getAssociatedObject(self, &YTXModuleOnceFlagOfObjectOfUrl) boolValue];
}

#pragma mark - AppDelegate

+ (void)ytxmodule_applicationDidFinishLaunching:(UIApplication *)application
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

+ (void)ytxmodule_applicationDidBecomeActive:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)ytxmodule_applicationWillResignActive:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (BOOL)ytxmodule_application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options NS_AVAILABLE_IOS(9_0); // no equiv. notification. return NO if the application can't open for some reaso
{
    BOOL result = YES;
    SEL ytx_selector = NSSelectorFromString([NSString stringWithFormat:@"ytxmodule_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(ytx_selector, _cmd)
    if (imp1 != imp2) {
        result = ((BOOL (*)(id, SEL, id, id, id))(void *)objc_msgSend)(self, ytx_selector, app, url, options);
    }
    BOOL (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;
    for (Class cls in YTXModuleClasses) {
        if ([cls respondsToSelector:_cmd]) {
            typed_msgSend(cls, _cmd, app, url, options);
        }
    }
    
    for (NSValue * obj in YTXModuleObjects) {
        id target = [obj nonretainedObjectValue];
        if ([target respondsToSelector:_cmd]) {
            typed_msgSend(target, _cmd, app, url, options);
        }
    }
    return result;
}

+ (BOOL)ytxmodule_application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    DEF_APPDELEGATE_METHOD_CONTAIN_RESULT(application, url);
}

+ (BOOL)ytxmodule_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = YES;
    SEL ytx_selector = NSSelectorFromString([NSString stringWithFormat:@"ytxmodule_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(ytx_selector, _cmd)
    if (imp1 != imp2) {
        result = ((BOOL (*)(id, SEL, id, id, id, id))(void *)objc_msgSend)(self, ytx_selector, application, url, sourceApplication, annotation);
    }
    BOOL (*typed_msgSend)(id, SEL, id, id, id, id) = (void *)objc_msgSend;
    for (Class cls in YTXModuleClasses) {
        if ([cls respondsToSelector:_cmd]) {
            typed_msgSend(cls, _cmd, application, url, sourceApplication, annotation);
        }
    }
    
    for (NSValue * obj in YTXModuleObjects) {
        id target = [obj nonretainedObjectValue];
        if ([target respondsToSelector:_cmd]) {
            typed_msgSend(target, _cmd, application, url, sourceApplication, annotation);
        }
    }
    return result;
}

+ (void)ytxmodule_applicationDidReceiveMemoryWarning:(UIApplication *)application;      // try to clean up as much memory as possible. next step is to terminate ap
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)ytxmodule_applicationWillTerminate:(UIApplication *)application
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)ytxmodule_applicationSignificantTimeChange:(UIApplication *)application;        // midnight, carrier time update, daylight savings time chang
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)ytxmodule_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken NS_AVAILABLE_IOS(3_0)
{
    DEF_APPDELEGATE_METHOD(application, deviceToken);
}
+ (void)ytxmodule_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_IOS(3_0)
{
    DEF_APPDELEGATE_METHOD(application, error);
}
+ (void)ytxmodule_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(3_0)
{
    DEF_APPDELEGATE_METHOD(application, userInfo);
}
+ (void)ytxmodule_application:(UIApplication *)application didReceiveLocalNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(3_0)
{
    DEF_APPDELEGATE_METHOD(application, userInfo);
}
+ (void)ytxmodule_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler NS_AVAILABLE_IOS(7_0)
{
    SEL ytx_selector = NSSelectorFromString([NSString stringWithFormat:@"ytxmodule_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(ytx_selector, _cmd)
    if (imp1 != imp2) {
        ((void (*)(id, SEL, id, id, id))(void *)objc_msgSend)(self, ytx_selector, application, identifier, completionHandler);
    }
    void (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;
    for (Class cls in YTXModuleClasses) {
        if ([cls respondsToSelector:_cmd]) {
            typed_msgSend(cls, _cmd, application, identifier, completionHandler);
        }
    }
    
    for (NSValue * obj in YTXModuleObjects) {
        id target = [obj nonretainedObjectValue];
        if ([target respondsToSelector:_cmd]) {
            typed_msgSend(target, _cmd, application, identifier, completionHandler);
        }
    }
}
+ (void)ytxmodule_application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply NS_AVAILABLE_IOS(8_2)
{
    SEL ytx_selector = NSSelectorFromString([NSString stringWithFormat:@"ytxmodule_%@", NSStringFromSelector(_cmd)]);
    SELECTOR_IS_EQUAL(ytx_selector, _cmd)
    if (imp1 != imp2) {
        ((void (*)(id, SEL, id, id, id))(void *)objc_msgSend)(self, ytx_selector, application, userInfo, reply);
    }
    void (*typed_msgSend)(id, SEL, id, id, id) = (void *)objc_msgSend;
    for (Class cls in YTXModuleClasses) {
        if ([cls respondsToSelector:_cmd]) {
            typed_msgSend(cls, _cmd, application, userInfo, reply);
        }
    }
    
    for (NSValue * obj in YTXModuleObjects) {
        id target = [obj nonretainedObjectValue];
        if ([target respondsToSelector:_cmd]) {
            typed_msgSend(target, _cmd, application, userInfo, reply);
        }
    }
}
+ (void)ytxmodule_applicationShouldRequestHealthAuthorization:(UIApplication *)application NS_AVAILABLE_IOS(9_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)ytxmodule_applicationDidEnterBackground:(UIApplication *)application NS_AVAILABLE_IOS(4_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)ytxmodule_applicationWillEnterForeground:(UIApplication *)application NS_AVAILABLE_IOS(4_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)ytxmodule_applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application NS_AVAILABLE_IOS(4_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}
+ (void)ytxmodule_applicationProtectedDataDidBecomeAvailable:(UIApplication *)application    NS_AVAILABLE_IOS(4_0)
{
    DEF_APPDELEGATE_METHOD(application, NULL);
}

#pragma mark - router
+ (void)registerURLPattern:(NSString *)URLPattern withTarget:(id)target withSelector:(SEL)selector
{
    [[self sharedIsntance] addURLPattern:URLPattern withTarget:target withSelector:selector];
}

+ (void)deregisterURLPattern:(NSString *)URLPattern
{
    [[self sharedIsntance] removeURLPattern:URLPattern];
}

+ (void)openURL:(NSString *)URL
{
    [self openURL:URL completion:nil];
}

+ (void)openURL:(NSString *)URL completion:(void (^)(id result))completion
{
    [self openURL:URL withUserInfo:nil completion:completion];
}

+ (void)openURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo completion:(void (^)(id result))completion
{
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [[self sharedIsntance] extractParametersFromURL:URL];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            parameters[key] = [obj stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }];
    
    if (parameters) {
        SEL selector = NSSelectorFromString(parameters[YTX_MODULE_ROUTER_SELECTOR_KEY]);
        id target = [parameters[YTX_MODULE_ROUTER_CLASS_KEY] nonretainedObjectValue];
        if (completion) {
            parameters[YTXModuleRouterParameterCompletion] = completion;
        }
        if (userInfo) {
            parameters[YTXModuleRouterParameterUserInfo] = userInfo;
        }
        if (selector && target) {
            [parameters removeObjectForKey:YTX_MODULE_ROUTER_SELECTOR_KEY];
            [target performSelector:selector withObject:parameters];
        }
    }
}

+ (BOOL)canOpenURL:(NSString *)URL
{
    return [[self sharedIsntance] extractParametersFromURL:URL] ? YES : NO;
}

+ (NSString *)generateURLWithPattern:(NSString *)pattern parameters:(NSArray *)parameters
{
    NSInteger startIndexOfColon = 0;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSInteger parameterIndex = 0;
    
    for (int i = 0; i < pattern.length; i++) {
        NSString *character = [NSString stringWithFormat:@"%c", [pattern characterAtIndex:i]];
        if ([character isEqualToString:@":"]) {
            startIndexOfColon = i;
        }
        if (([@[@"/", @"?", @"&"] containsObject:character] || (i == pattern.length - 1 && startIndexOfColon) ) && startIndexOfColon) {
            if (i > (startIndexOfColon + 1)) {
                [items addObject:[NSString stringWithFormat:@"%@%@", [pattern substringWithRange:NSMakeRange(0, startIndexOfColon)], parameters[parameterIndex++]]];
                pattern = [pattern substringFromIndex:i];
                i = 0;
            }
            startIndexOfColon = 0;
        }
    }
    
    return [items componentsJoinedByString:@""];
}

+ (id)objectForURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo
{
    YTXModule *router = [YTXModule sharedIsntance];
    
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters = [router extractParametersFromURL:URL];
    SEL selector = NSSelectorFromString(parameters[YTX_MODULE_ROUTER_SELECTOR_KEY]);
    id target = [parameters[YTX_MODULE_ROUTER_CLASS_KEY] nonretainedObjectValue];
    if (selector && target) {
        if (userInfo) {
            parameters[YTXModuleRouterParameterUserInfo] = userInfo;
        }
        [parameters removeObjectForKey:YTX_MODULE_ROUTER_SELECTOR_KEY];
        return [target performSelector:selector withObject:parameters];;
    }
    return nil;
}

+ (id)objectForURL:(NSString *)URL
{
    return [self objectForURL:URL withUserInfo:nil];
}

- (void)addURLPattern:(NSString *)URLPattern withTarget:(id)target withSelector:(SEL)selector
{
    NSMutableDictionary *subRoutes = [self addURLPattern:URLPattern];
    if (selector && subRoutes) {
        subRoutes[@"_"] = NSStringFromSelector(selector);
        subRoutes[@"__"] = target;
    }
}

- (NSMutableDictionary *)addURLPattern:(NSString *)URLPattern
{
    NSArray *pathComponents = [self pathComponentsFromURL:URLPattern];
    
    NSInteger index = 0;
    NSMutableDictionary* subRoutes = self.routes;
    
    while (index < pathComponents.count) {
        NSString* pathComponent = pathComponents[index];
        if (![subRoutes objectForKey:pathComponent]) {
            subRoutes[pathComponent] = [[NSMutableDictionary alloc] init];
        }
        subRoutes = subRoutes[pathComponent];
        index++;
    }
    return subRoutes;
}

#pragma mark - Utils

- (NSMutableDictionary *)extractParametersFromURL:(NSString *)url
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[YTXModuleRouterParameterURL] = url;
    
    NSMutableDictionary* subRoutes = self.routes;
    NSArray* pathComponents = [self pathComponentsFromURL:url];
    
    // borrowed from HHRouter(https://github.com/Huohua/HHRouter)
    for (NSString* pathComponent in pathComponents) {
        BOOL found = NO;
        
        // 对 key 进行排序，这样可以把 ~ 放到最后
        NSArray *subRoutesKeys =[subRoutes.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        
        for (NSString* key in subRoutesKeys) {
            if ([key isEqualToString:pathComponent] || [key isEqualToString:YTX_MODULE_ROUTER_WILDCARD_CHARACTER]) {
                found = YES;
                subRoutes = subRoutes[key];
                break;
            } else if ([key hasPrefix:@":"]) {
                found = YES;
                subRoutes = subRoutes[key];
                parameters[[key substringFromIndex:1]] = pathComponent;
                break;
            }
        }
        // 如果没有找到该 pathComponent 对应的 handler，则以上一层的 handler 作为 fallback
        if (!found && !subRoutes[@"_"] && !subRoutes[@"__"]) {
            return nil;
        }
    }
    
    // Extract Params From Query.
    NSArray* pathInfo = [url componentsSeparatedByString:@"?"];
    if (pathInfo.count > 1) {
        NSString* parametersString = [pathInfo objectAtIndex:1];
        NSArray* paramStringArr = [parametersString componentsSeparatedByString:@"&"];
        for (NSString* paramString in paramStringArr) {
            NSArray* paramArr = [paramString componentsSeparatedByString:@"="];
            if (paramArr.count > 1) {
                NSString* key = [paramArr objectAtIndex:0];
                NSString* value = [paramArr objectAtIndex:1];
                parameters[key] = value;
            }
        }
    }
    
    if (subRoutes[@"_"]) {
        parameters[YTX_MODULE_ROUTER_SELECTOR_KEY] = [subRoutes[@"_"] copy];
    }
    if (subRoutes[@"__"]) {
        parameters[YTX_MODULE_ROUTER_CLASS_KEY] = [NSValue valueWithNonretainedObject:[subRoutes[@"__"] copy]];
    }
    
    return parameters;
}

- (void)removeURLPattern:(NSString *)URLPattern
{
    NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:[self pathComponentsFromURL:URLPattern]];
    
    // 只删除该 pattern 的最后一级
    if (pathComponents.count >= 1) {
        // 假如 URLPattern 为 a/b/c, components 就是 @"a.b.c" 正好可以作为 KVC 的 key
        NSString *components = [pathComponents componentsJoinedByString:@"."];
        NSMutableDictionary *route = [self.routes valueForKeyPath:components];
        
        if (route.count >= 1) {
            NSString *lastComponent = [pathComponents lastObject];
            [pathComponents removeLastObject];
            
            // 有可能是根 key，这样就是 self.routes 了
            route = self.routes;
            if (pathComponents.count) {
                NSString *componentsWithoutLast = [pathComponents componentsJoinedByString:@"."];
                route = [self.routes valueForKeyPath:componentsWithoutLast];
            }
            [route removeObjectForKey:lastComponent];
        }
    }
}

- (NSArray*)pathComponentsFromURL:(NSString*)URL
{
    NSMutableArray *pathComponents = [NSMutableArray array];
    if ([URL rangeOfString:@"://"].location != NSNotFound) {
        NSArray *pathSegments = [URL componentsSeparatedByString:@"://"];
        // 如果 URL 包含协议，那么把协议作为第一个元素放进去
        [pathComponents addObject:pathSegments[0]];
        
        // 如果只有协议，那么放一个占位符
        if ((pathSegments.count == 2 && ((NSString *)pathSegments[1]).length) || pathSegments.count < 2) {
            [pathComponents addObject:YTX_MODULE_ROUTER_WILDCARD_CHARACTER];
        }
        
        URL = [URL substringFromIndex:[URL rangeOfString:@"://"].location + 3];
    }
    
    for (NSString *pathComponent in [[NSURL URLWithString:URL] pathComponents]) {
        if ([pathComponent isEqualToString:@"/"]) continue;
        if ([[pathComponent substringToIndex:1] isEqualToString:@"?"]) break;
        [pathComponents addObject:pathComponent];
    }
    return [pathComponents copy];
}

- (NSMutableDictionary *)routes
{
    if (!_routes) {
        _routes = [[NSMutableDictionary alloc] init];
    }
    return _routes;
}

#pragma clang diagnostic pop

#pragma clang diagnostic pop

@end
