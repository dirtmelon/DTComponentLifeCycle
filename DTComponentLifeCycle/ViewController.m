//
//  ViewController.m
//  DTComponentLifeCycle
//
//  Created by dirtmelon on 2022/1/17.
//

#import "ViewController.h"
#import "DTComponentLifeCycleManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [DTComponentLifeCycleManager homePageViewDidLoad];
}


@end
