//
//  BaseNavigationController.m
//  SSNavigationControllerDemo
//
//  Created by stevenSu on 16/1/14.
//  Copyright © 2016年 stevenSu. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = [UIColor yellowColor];
//    self.transitioningCriticalValue = 20;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
