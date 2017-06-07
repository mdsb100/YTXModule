//
//  YTXModuleJump.h
//  Pods
//
//  Created by 奚潇川 on 06/06/2017.
//
//

#import <Foundation/Foundation.h>

@interface YTXModuleJump : NSObject

/**
 跳转至指定URL页面，URL必须完全匹配，否则这条将不会执行任何操作。该方法直接采用字符串匹配，按道理每个项目需要自己建立一个该类的子类，创建一套枚举对应每一个页面，以适应从webjs跳转。
 + (void)jumpPageType:(XXXModuleJumpType)pageType data:(nullable NSDictionary *)data from:(nullable UIViewController *)viewController;

 @param page 目标页面的名称，业务组件间需要确定每个页面名都是唯一的。需要实现一个category方法[NSString stringWithFormat:@"jump%@:", page]
 @param data 页面跳转需要传递的参数
 @param viewController 你从哪里来
 */
+ (void)jumpPage:(nonnull NSString *)page data:(nullable NSDictionary *)data from:(nonnull UIViewController *)viewController;

/** Example
+ (void)jumpExample:(nullable NSDictionary *)data from:(nullable UIViewController *)viewController;
 */

@end
