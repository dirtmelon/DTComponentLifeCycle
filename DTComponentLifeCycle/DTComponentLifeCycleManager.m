//
//  DTComponentLifeCycleManager.m
//  DTComponentLifeCycle
//
//  Created by dirtmelon on 2022/1/17.
//

#import "DTComponentLifeCycleManager.h"
#import "IDTComponentLifeCycle.h"
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <mach-o/getsect.h>

#ifdef __LP64__
typedef uint64_t dt_value;
typedef struct section_64 dt_section;
typedef struct mach_header_64 dt_mach_header;
#define dt_getsectbynamefromheader getsectbynamefromheader_64
#else
typedef uint32_t dt_value;
typedef struct section dt_section;
typedef struct mach_header dt_mach_header;
#define dt_getsectbynamefromheader getsectbynamefromheader
#endif


@interface DTComponentLifeCycleManager ()

@property (nonatomic, copy) NSArray <Class <IDTComponentLifeCycle>> *classes;

@property (nonatomic, strong) NSMutableArray <id<IDTComponentLifeMetric>> *metricObservers;

@property (nonatomic, strong) NSMutableSet <NSString *> *didPerformSelectors;

@property (nonatomic, copy) NSDictionary<UIApplicationLaunchOptionsKey,id> *launchOptions;

@end

@implementation DTComponentLifeCycleManager

+ (instancetype)sharedManager {
    static DTComponentLifeCycleManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DTComponentLifeCycleManager alloc] init];
    });
    return manager;
}

+ (NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    return [DTComponentLifeCycleManager sharedManager].launchOptions;
}

+ (void)registerMetricObservers:(NSArray<id<IDTComponentLifeMetric>> *)metricObservers {
    [[DTComponentLifeCycleManager sharedManager].metricObservers addObjectsFromArray:metricObservers];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupClasses];
        _metricObservers = [[NSMutableArray alloc] init];
        _didPerformSelectors = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)setupClasses {
    NSMutableArray <Class <IDTComponentLifeCycle>> *classes = [[NSMutableArray alloc] init];
    uint32_t count = _dyld_image_count();
    for (uint32_t index = 0; index < count; index++) {
        const struct mach_header *header = _dyld_get_image_header(index);
        Dl_info info;
        if (dladdr(header, &info) == 0) {
            continue;
        }
        void *fbase = info.dli_fbase;
        const dt_section *section = dt_getsectbynamefromheader(fbase, "__DATA", DT_COMPONENT_SECTION_NAME);
        if (section == NULL) {
            continue;
        }
        for (dt_value offset = section->offset; offset < section->offset + section->size; offset += sizeof(char *)) {
            const void *address = fbase + offset;
            if (address == NULL) {
                continue;
            }
            char *strs = *(char **)address;
            NSString *string = [NSString stringWithUTF8String:strs];
            Class class = NSClassFromString(string);
            if (class) {
                [classes addObject:class];
            } else {
                NSAssert(NO, @"找不到对应的 class");
            }

        }
    }

    _classes = [classes sortedArrayUsingComparator:^NSComparisonResult(Class <IDTComponentLifeCycle> obj1, Class  <IDTComponentLifeCycle> obj2) {
        if ([obj1 priority] < [obj2 priority]) {
            return NSOrderedDescending;
        } else if ([obj1 priority] > [obj2 priority]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
}

#pragma mark - IDTComponentLifeCycle

+ (void)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    if ([self didPerformSelector:_cmd]) {
        return;
    }
    DTComponentLifeCycleManager.sharedManager.launchOptions = launchOptions;
    [self performTasksWithSelector:_cmd withObject:application withObject:launchOptions];
}

+ (void)application:(UIApplication *)application
didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    if ([self didPerformSelector:_cmd]) {
        return;
    }
    DTComponentLifeCycleManager.sharedManager.launchOptions = launchOptions;
    [self performTasksWithSelector:_cmd withObject:application withObject:launchOptions];
}

+ (void)applicationDidBecomeActive:(UIApplication *)application {
    [self performTasksWithSelector:_cmd withObject:application];
}

+ (void)applicationWillResignActive:(UIApplication *)application {
    [self performTasksWithSelector:_cmd withObject:application];
}

+ (void)applicationDidEnterBackground:(UIApplication *)application {
    [self performTasksWithSelector:_cmd withObject:application];

}

+ (void)applicationWillEnterForeground:(UIApplication *)application {
    [self performTasksWithSelector:_cmd withObject:application];
}

+ (void)applicationWillTerminate:(UIApplication *)application {
    [self performTasksWithSelector:_cmd withObject:application];
}

+ (void)homePageViewDidLoad {
    if ([self didPerformSelector:_cmd]) {
        return;
    }
    [self performTasksWithSelector:_cmd];
}

+ (void)homePageViewDidAppear {
    if ([self didPerformSelector:_cmd]) {
        return;
    }
    [self performTasksWithSelector:_cmd];
}

+ (void)homePageWillFetchData {
    if ([self didPerformSelector:_cmd]) {
        return;
    }
    [self performTasksWithSelector:_cmd];
}

+ (void)homePageDidFetchData {
    if ([self didPerformSelector:_cmd]) {
        return;
    }
    [self performTasksWithSelector:_cmd];
}

+ (void)homePageDidFinishRender {
    if ([self didPerformSelector:_cmd]) {
        return;
    }
    [self performTasksWithSelector:_cmd];
}

#pragma mark - Private

+ (BOOL)didPerformSelector:(SEL)aSelector {
    return [DTComponentLifeCycleManager.sharedManager.didPerformSelectors containsObject:NSStringFromSelector(aSelector)];
}

+ (void)recordSelector:(SEL)aSelector {
    [DTComponentLifeCycleManager.sharedManager.didPerformSelectors addObject:NSStringFromSelector(aSelector)];
}

/// 无参数无返回值的协议方法才通过这种方式来调用
+ (void)performTasksWithSelector:(SEL)aSelector {
    NSAssert(NSThread.isMainThread, @"ComponentLifeCycleManager 相关方法需要在主线程进行调用");
    [DTComponentLifeCycleManager.sharedManager.classes enumerateObjectsUsingBlock:^(Class<IDTComponentLifeCycle>  _Nonnull class, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([class respondsToSelector:aSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performTaskWithClass:class aSelector:aSelector action:^{
                [class performSelector:aSelector];
            }];
#pragma clang diagnostic pop
        }
    }];
    [self recordSelector:aSelector];
}

/// 参数个数为 1 的协议方法
+ (void)performTasksWithSelector:(SEL)aSelector withObject:(id)object {
    NSAssert(NSThread.isMainThread, @"ComponentLifeCycleManager 相关方法需要在主线程进行调用");
    [DTComponentLifeCycleManager.sharedManager.classes enumerateObjectsUsingBlock:^(Class<IDTComponentLifeCycle>  _Nonnull class, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([class respondsToSelector:aSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performTaskWithClass:class aSelector:aSelector action:^{
                [class performSelector:aSelector withObject:object];
            }];
#pragma clang diagnostic pop
        }
    }];
    [self recordSelector:aSelector];
}

/// 参数个数为 2 的协议方法
+ (void)performTasksWithSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2 {
    NSAssert(NSThread.isMainThread, @"ComponentLifeCycleManager 相关方法需要在主线程进行调用");
    [DTComponentLifeCycleManager.sharedManager.classes enumerateObjectsUsingBlock:^(Class<IDTComponentLifeCycle>  _Nonnull class, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([class respondsToSelector:aSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performTaskWithClass:class aSelector:aSelector action:^{
                [class performSelector:aSelector withObject:object1 withObject:object2];
            }];
#pragma clang diagnostic pop
        }
    }];
    [self recordSelector:aSelector];
}


+ (void)performTaskWithClass:(Class)class aSelector:(SEL)aSelector action:(dispatch_block_t)action {
    [DTComponentLifeCycleManager.sharedManager component:class willPerformSelector:aSelector];
    action();
    [DTComponentLifeCycleManager.sharedManager component:class didPerformSelector:aSelector];
}

- (void)component:(Class)class willPerformSelector:(SEL)aSelector {
    [self.metricObservers enumerateObjectsUsingBlock:^(id<IDTComponentLifeMetric>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj component:NSStringFromClass(class) willPerformTask:NSStringFromSelector(aSelector)];
    }];
}

- (void)component:(Class)class didPerformSelector:(SEL)aSelector {
    [self.metricObservers enumerateObjectsUsingBlock:^(id<IDTComponentLifeMetric>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj component:NSStringFromClass(class) didPerformTask:NSStringFromSelector(aSelector)];
    }];
}

@end
