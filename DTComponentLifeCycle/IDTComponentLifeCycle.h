//
//  IDTComponentLifeCycle.h
//  DTComponentLifeCycle
//
//  Created by dirtmelon on 2022/1/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 说明：
 使用 DT_REGIST_COMPONENT_CLASS 注册对应的类，需要在 .m 文件下调用，例如
 //
 // DTAComponent.m
 DT_REGIST_COMPONENT_CLASS(DTAComponent)

 /// DTAComponent 为该组件的初始化管理器，一般来说每个组件只需要一个初始化管理器，也可以设置多个
 /// 是否切换至主线程可以根据需要自行操作
 @interface DTAComponent () <IDTComponentLifeCycle>

 @end
  
 @implementation DTAComponent

 /// 定义优先级
 + (DTComponentPriority)priority
 {
     return DTComponentPriorityMedium;
 }

 #pragma mark - IDTComponentLifeCycle
 /// 根据需要实现启动周期内不同的方法
 + (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions
 {
     NSLog(@"%s", __func__);
 }

 + (void)homePageViewDidLoad
 {
     NSLog(@"%s", __func__);
 }
 @end
 
 */
#define DT_COMPONENT_SECTION_NAME "__dt_component"

#define DT_REGIST_COMPONENT_CLASS(className) \
char *dtComponent##className __attribute__((used, section("__DATA,__dt_component"))) = (char *)""#className""; \

typedef float DTComponentPriority;
/// 启动最高优先级，用于崩溃 sdk ，日志等
static const DTComponentPriority DTComponentPriorityRequired = 1000;
/// 较高层级的业务，如果有被其它组件依赖，可以使用该优先级
static const DTComponentPriority DTComponentPriorityHigh = 750;
/// 普通优先级，一般来说使用该优先级即可
static const DTComponentPriority DTComponentPriorityMedium = 500;
/// 最低优先级，最后初始化
static const DTComponentPriority DTComponentPriorityLow = 250;

@protocol IDTComponentLifeCycle <NSObject>

@required

/// 初始化优先级
@property (nonatomic, readonly, class) DTComponentPriority priority;

@optional

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
