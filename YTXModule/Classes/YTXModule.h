    //
//  YTXModule.h
//  Pods
//
//  Created by CaoJun on 16/8/12.
//
//

#import <Foundation/Foundation.h>

#define YTXMODULE_EXTERN() \
+ (void)load \
{ \
    [YTXModule registerAppDelegateModule:self]; \
    [YTXModule detectRouterModule:self]; \
    if ([self respondsToSelector:@selector(__ytxmodule_load)]) { \
        [self performSelector:@selector(__ytxmodule_load)]; \
    } \
} \
+ (void)__ytxmodule_load \

#define YTXMODULE_EXAPAND_PARAMETERS(__PARA__) \
    NSDictionary * dict = __PARA__ ? : @{};\
    void(^completion)(id result) = dict[YTXModuleRouterParameterCompletion]; \
    NSDictionary * userInfo = dict[YTXModuleRouterParameterUserInfo]; \

#define YTX_CONCAT2(A, B) A ## B
#define YTX_CONCAT(A, B) YTX_CONCAT2(A, B)

#define YTXMODULE_EXTERN_ROUTER_METHOD(url) \
YTXMODULE_EXTERN_ROUTER_REMAP_RETURN_METHOD(url, counter, void)

#define YTXMODULE_EXTERN_ROUTER_OBJECT_METHOD(url) \
YTXMODULE_EXTERN_ROUTER_REMAP_RETURN_METHOD(url, counter, id)

#define YTXMODULE_EXTERN_ROUTER_REMAP_RETURN_METHOD(url, counter, returntype) \
+ (void)YTX_CONCAT(__YTXModuleRouterRegisterURL_, YTX_CONCAT(counter, __LINE__)) \
{ \
    [YTXModule registerURLPattern:url withTarget:self withSelector:@selector(YTX_CONCAT(__YTXModuleRouterSelector_, YTX_CONCAT(counter, __LINE__)):)]; \
} \
\
+ (returntype)YTX_CONCAT(__YTXModuleRouterSelector_, YTX_CONCAT(counter, __LINE__)):(nullable NSDictionary *) parameters \


extern NSString *const YTXModuleRouterParameterURL;
extern NSString *const YTXModuleRouterParameterCompletion;
extern NSString *const YTXModuleRouterParameterUserInfo;

@interface YTXModule : NSObject

@property (nonatomic, readonly, assign) BOOL ready;

+ (void) registerAppDelegateModule:(Class) moduleClass;

+ (void) detectRouterModule:(Class) moduleClass;

+ (nullable UIViewController *) createRootViewControllerWithOptions:(nullable NSDictionary *) options;

#pragma mark - router
/**
 *  注册 URLPattern 对应的 Handler，在 handler 中可以初始化 VC，然后对 VC 做各种操作
 *
 *  @param URLPattern 带上 scheme，如 mgj://beauty/:id
 *  @param target     selecotr的执行者
 *  @param selector   该 selector 会传一个字典，包含了注册的 URL 中对应的变量。
 *                    假如注册的 URL 为 mgj://beauty/:id 那么，就会传一个 @{@"id": 4} 这样的字典过来
 */
+ (void)registerURLPattern:(NSString *)URLPattern withTarget:(id)target withSelector:(SEL)selector;

/**
 *  取消注册某个 URL Pattern
 *
 *  @param URLPattern
 */
+ (void)deregisterURLPattern:(NSString *)URLPattern;

/**
 *  打开此 URL
 *  会在已注册的 URL -> Handler 中寻找，如果找到，则执行 Handler
 *
 *  @param URL 带 Scheme，如 mgj://beauty/3
 */
+ (void)openURL:(NSString *)URL;

/**
 *  打开此 URL，同时当操作完成时，执行额外的代码
 *
 *  @param URL        带 Scheme 的 URL，如 mgj://beauty/4
 *  @param completion URL 处理完成后的 callback，完成的判定跟具体的业务相关
 */
+ (void)openURL:(NSString *)URL completion:(void (^)(id result))completion;

/**
 *  打开此 URL，带上附加信息，同时当操作完成时，执行额外的代码
 *
 *  @param URL        带 Scheme 的 URL，如 mgj://beauty/4
 *  @param parameters 附加参数
 *  @param completion URL 处理完成后的 callback，完成的判定跟具体的业务相关
 */
+ (void)openURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo completion:(void (^)(id result))completion;

/**
 * 查找谁对某个 URL 感兴趣，如果有的话，返回一个 object
 *
 *  @param URL
 */
+ (id)objectForURL:(NSString *)URL;

/**
 * 查找谁对某个 URL 感兴趣，如果有的话，返回一个 object
 *
 *  @param URL
 *  @param userInfo
 */
+ (id)objectForURL:(NSString *)URL withUserInfo:(NSDictionary *)userInfo;

/**
 *  是否可以打开URL
 *
 *  @param URL
 *
 *  @return
 */
+ (BOOL)canOpenURL:(NSString *)URL;

/**
 *  调用此方法来拼接 urlpattern 和 parameters
 *
 *  #define YTX_ROUTE_BEAUTY @"beauty/:id"
 *  [YTXModule generateURLWithPattern:YTX_ROUTE_BEAUTY, @[@13]];
 *
 *
 *  @param pattern    url pattern 比如 @"beauty/:id"
 *  @param parameters 一个数组，数量要跟 pattern 里的变量一致
 *
 *  @return
 */
+ (NSString *)generateURLWithPattern:(NSString *)pattern parameters:(NSArray *)parameters;

@end
