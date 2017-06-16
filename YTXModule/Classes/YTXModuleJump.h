//
//  YTXModuleJump.h
//  Pods
//
//  Created by 奚潇川 on 06/06/2017.
//
//

#import <Foundation/Foundation.h>
#import <YTXModule/YTXModule.h>

extern  NSString *const _Nonnull YTXModuleRouterParameterSourceViewController;

#define YTXMODULE_SOURCE_VIEWCONTROLLER(__PARA__) \
NSDictionary * __dict = parameters ? : @{};\
NSDictionary * userInfo = __dict[YTXModuleRouterParameterUserInfo]; \
UIViewController * __PARA__ = userInfo ? userInfo[YTXModuleRouterParameterSourceViewController] : nil;

#define YTXMODULE_EXAPAND_VIEWCONTROLLER_USRINFO_COMPLETION(__VC__, __USRINFO__, __COMPLETION__) \
NSDictionary * __dict = parameters ? : @{};\
void(^__COMPLETION__)(id result) = __dict[YTXModuleRouterParameterCompletion]; \
NSDictionary * __USRINFO__ = __dict[YTXModuleRouterParameterUserInfo]; \
UIViewController * __VC__ = __USRINFO__ ? __USRINFO__[YTXModuleRouterParameterSourceViewController] : nil;


@interface YTXModuleJump : NSObject

/**
 跳转至指定URL页面，URL必须完全匹配，否则这条将不会执行任何操作。该方法直接采用字符串匹配，按道理每个项目需要自己建立一个该类的子类，创建一套枚举对应每一个页面，以适应从webjs跳转。
 + (void)jumpPageType:(XXXModuleJumpType)pageType data:(nullable NSDictionary *)data from:(nonnull UIViewController *)viewController;

 @param page 目标页面的名称，业务组件间需要确定每个页面名都是唯一的。需要实现一个category方法[NSString stringWithFormat:@"jump%@:", page]
 @param data 页面跳转需要传递的参数
 @param viewController 你从哪里来
 */
+ (void)jumpPage:(nonnull NSString *)page data:(nullable NSDictionary *)data from:(nonnull UIViewController *)viewController;

/** Example
+ (void)jumpExample:(nullable NSDictionary *)data from:(nonnull UIViewController *)viewController;
 */


/**
 * 其实是用openURL
 * YES 表示 找到了URL
 */
+ (BOOL)jumpWithUrl:(nonnull NSString *)url fromViewController:(nonnull UIViewController *) fromViewController;

+ (BOOL)jumpWithUrl:(nonnull NSString *)url fromViewController:(nonnull UIViewController *) fromViewController userInfo:(nullable NSDictionary *)userInfo completion:(nullable void (^)(_Nullable id result))completion;

@end
