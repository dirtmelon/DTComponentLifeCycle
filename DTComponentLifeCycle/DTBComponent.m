//
//  DTBComponent.m
//  DTComponentLifeCycle
//
//  Created by dirtmelon on 2022/1/17.
//

#import "DTBComponent.h"
#import "DTComponentLifeCycleManager.h"
#import "IDTComponentLifeCycle.h"

DT_REGIST_COMPONENT_CLASS(DTBComponent)

@interface DTBComponent () <IDTComponentLifeCycle>

@end

@implementation DTBComponent

#pragma mark - IDTComponentLifeCycle
+ (DTComponentPriority)priority {
    return DTComponentPriorityHigh;
}

+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    NSLog(@"%s", __func__);
}

@end
