//
//  DTAComponent.m
//  DTComponentLifeCycle
//
//  Created by dirtmelon on 2022/1/17.
//

#import "DTAComponent.h"
#import "DTComponentLifeCycleManager.h"
#import "IDTComponentLifeCycle.h"

DT_REGIST_COMPONENT_CLASS(DTAComponent)

@interface DTAComponent () <IDTComponentLifeCycle>

@end

@implementation DTAComponent

#pragma mark - IDTComponentLifeCycle

+ (DTComponentPriority)priority {
    return DTComponentPriorityMedium;
}

+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    NSLog(@"%s", __func__);
}

+ (void)homePageViewDidLoad {
    sleep(3);
    NSLog(@"%s", __func__);
}

@end
