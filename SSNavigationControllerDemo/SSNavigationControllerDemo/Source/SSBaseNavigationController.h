//
//  SSBaseNavigationController.h
//  SSNavigationController
//
//  Created by stevenSu on 16/1/14.
//  Copyright © 2016年 stevenSu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSBaseNavigationController : UINavigationController

/// shadow properties
@property (assign, nonatomic) CGSize shadowOffset;
@property (assign, nonatomic) CGFloat shadowRadius;
@property (assign, nonatomic) CGColorRef shadowColor;
@property (assign, nonatomic) float shadowOpacity;

/// start transitioning critical x value, default is 0
@property (assign, nonatomic) CGFloat transitioningCriticalValue;

/// distance critical value to decide if should pop to previous viewcontroller, default is screenWidth * 0.3
@property (assign, nonatomic) CGFloat popCriticalValue;

/// velocity critical value to decide if should pop to previous viewcontroller, default is 500
@property (assign, nonatomic) CGFloat velocityCriticalValue;

/// previous viewcontroller's opacity, default is 0.9
@property (assign, nonatomic) CGFloat previousViewOpacity;

/// default is nil. This block will be detected before transition started, if it's not nil the transition will not begin and will execute the block instead
@property (copy, nonatomic) void ((^beforeTransition)());


/// setup pan action
- (void)setupPanRecognizedAction;
/// remove pan action
- (void)removePanRecognizedAction;
@end
