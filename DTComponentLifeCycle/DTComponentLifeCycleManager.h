//
//  DTComponentLifeCycleManager.h
//  DTComponentLifeCycle
//
//  Created by dirtmelon on 2022/1/17.
//

#import <UIKit/UIKit.h>
#import "IDTComponentLifeMetric.h"

NS_ASSUME_NONNULL_BEGIN

@interface DTComponentLifeCycleManager : NSObject

@property (nullable, class, readonly) NSDictionary<UIApplicationLaunchOptionsKey,id> *launchOptions;

+ (void)registerMetricObservers:(NSArray <id<IDTComponentLifeMetric>> *)metricObservers;

/// 对应 AppDelegate 的方法，多次调用只会执行一次
+ (void)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions;

/// 对应 AppDelegate 的方法，多次调用只会执行一次
+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions;

/// 对应 AppDelegate 的方法
+ (void)applicationDidBecomeActive:(UIApplication *)application;

/// 对应 AppDelegate 的方法
+ (void)applicationWillResignActive:(UIApplication *)application;

/// 对应 AppDelegate 的方法
+ (void)applicationDidEnterBackground:(UIApplication *)application;

/// 对应 AppDelegate 的方法
+ (void)applicationWillEnterForeground:(UIApplication *)application;

/// 对应 AppDelegate 的方法
+ (void)applicationWillTerminate:(UIApplication *)application;

/// 首页 VC viewDidLoad 时调用，多次调用只会执行一次
+ (void)homePageViewDidLoad;

/// 首页 VC viewDidAppear 时调用，多次调用只会执行一次
+ (void)homePageViewDidAppear;

/// 首页 VC 开始拉取首页数据时调用，多次调用只会执行一次
+ (void)homePageWillFetchData;

/// 首页 VC 获取到数据后调用，多次调用只会执行一次
+ (void)homePageDidFetchData;

/// 首页 VC 的首屏完成渲染后调用，多次调用只会执行一次
+ (void)homePageDidFinishRender;

@end

NS_ASSUME_NONNULL_END
