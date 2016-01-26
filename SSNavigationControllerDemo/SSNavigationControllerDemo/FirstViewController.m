//
//  FirstViewController.m
//  SSNavigationControllerDemo
//
//  Created by stevenSu on 16/1/14.
//  Copyright © 2016年 stevenSu. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [NSString stringWithFormat:@"Page-%lu", self.navigationController.viewControllers.count];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupUI {
    UIButton *nextPageBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextPageBtn setTitle:[NSString stringWithFormat:@"gotoPage%lu", self.navigationController.viewControllers.count + 1] forState:UIControlStateNormal];
    nextPageBtn.center = self.view.center;
    nextPageBtn.bounds = CGRectMake(0, 0, 100, 100);
    [nextPageBtn addTarget:self action:@selector(jumpToNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextPageBtn];
    
}

- (void)jumpToNext {
    FirstViewController *vc = [[FirstViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
