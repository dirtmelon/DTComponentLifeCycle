//
//  AppDelegate.m
//  DTComponentLifeCycle
//
//  Created by dirtmelon on 2022/1/17.
//

#import "AppDelegate.h"
#import "DTComponentLifeCycleManager.h"

@interface AppDelegate () <IDTComponentLifeMetric>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DTComponentLifeCycleManager registerMetricObservers:@[self]];
    [DTComponentLifeCycleManager application:application
               didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

#pragma mark - IDTComponentLifeMetric

- (void)component:(nonnull NSString *)name willPerformTask:(nonnull NSString *)task {
    NSLog(@"component: %@, willPerformTask: %@", name, task);
}

- (void)component:(nonnull NSString *)name didPerformTask:(nonnull NSString *)task {
    NSLog(@"component: %@, didPerformTask: %@", name, task);
}

@end
