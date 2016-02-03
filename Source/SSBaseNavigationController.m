//
//  SSBaseNavigationController.m
//  SSNavigationController
//
//  Created by stevenSu on 16/1/14.
//  Copyright © 2016年 stevenSu. All rights reserved.
//

#import "SSBaseNavigationController.h"


#define SS_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SS_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define SS_DEFAULT_SHADOW_COLOR 0x231815
#define SS_DEFAULT_SHADOW_RADIUS 5
#define SS_DEFAULT_SHADOW_OPACITY 0.8

#define SS_STATUSBAR_HEIGHT 20
#define SS_NAVIGATIONBAR_HEIGHT 44
#define SS_NAVIGATIONBAR_BOTTOM 64

#define SS_ANIMATION_DURATION 0.2
#define SS_SPRING_ANIMATION_DURATION 0.3
#define SS_SPRING_DAMPING 0.7
#define SS_SPRING_VELOCITY 0.05

#define SS_POP_CRITICAL_VALUE SS_SCREEN_WIDTH * 0.3
#define SS_VELOCITY_CRITICAL_VALUE 500
#define SS_PREVIOUS_VIEW_STARTING_POINT -SS_SCREEN_WIDTH * 0.5
#define SS_PREVIOUS_VIEW_OPACITY 0.9

@interface SSBaseNavigationController ()
@property (assign, nonatomic, getter = istransitioning) BOOL transitioning;
@property (weak, nonatomic) UIViewController *previousVc;
@property (assign, nonatomic) CGPoint navTranslation;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIPanGestureRecognizer *pan;
@property (weak, nonatomic) UIWindow *keyWindow;
@end

@implementation SSBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.enabled = NO;

    [self setupPanRecognizedAction];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.keyWindow = [UIApplication sharedApplication].keyWindow;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    self.beforeTransition = nil;
    return [super popViewControllerAnimated:animated];
}

- (void)setupPanRecognizedAction {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognizedAction:)];
    self.pan = pan;
    [self.view addGestureRecognizer:pan];
}

- (void)removePanRecognizedAction {
    [self.view removeGestureRecognizer:self.pan];
}

- (void)panRecognizedAction:(UIPanGestureRecognizer *)sender {
    
    CGPoint translation = [sender translationInView:self.view];
    self.navTranslation = translation;
    
    // start panning
    if (self.viewControllers.count >= 2 && sender.state == UIGestureRecognizerStateBegan) {
        // panning right
        // use velocity.x here instead of translation.x due to a bug on iPhone-6S: translation.x = 0 when start panning on the left side of the screen
        CGPoint velocity = [sender velocityInView:self.view];
        if (velocity.x > self.transitioningCriticalValue) {
            if (self.beforeTransition) {
                self.beforeTransition();
            } else {
                [self transitionStarted];
            }
        }
    }
    
    // panning
    if (sender.state == UIGestureRecognizerStateChanged) {
        if (self.istransitioning) {
            [self transitioning:translation];
        }
    }
    
    // end panning
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.istransitioning) {
            CGPoint velocity = [sender velocityInView:self.view];
            
            CGFloat popCriticalPoint = self.popCriticalValue ? self.popCriticalValue : SS_POP_CRITICAL_VALUE;
            
            CGFloat velocityCriticalPoint = self.velocityCriticalValue ? self.velocityCriticalValue : SS_VELOCITY_CRITICAL_VALUE;
            
            CGFloat criticalPoint = velocity.x > velocityCriticalPoint ? 0 : popCriticalPoint;
            
            if (self.navTranslation.x >= criticalPoint) {
                [self transitionSuccess];
            } else {
                [self transitionRollBack];
            }
        }
    }
}

- (void)showShadow:(BOOL)show {
    if (show) {
        self.view.layer.shadowOffset = [NSValue valueWithCGSize:self.shadowOffset] ? self.shadowOffset : CGSizeZero;
        self.view.layer.shadowRadius = self.shadowRadius != 0 ? self.shadowRadius : SS_DEFAULT_SHADOW_RADIUS;
        self.view.layer.shadowColor = self.shadowColor ? self.shadowColor : [UIColor colorWithRed:((float)((SS_DEFAULT_SHADOW_COLOR & 0xFF0000) >> 16))/255.0
                                                      green:((float)((SS_DEFAULT_SHADOW_COLOR & 0xFF00) >> 8))/255.0
                                                       blue:((float)(SS_DEFAULT_SHADOW_COLOR & 0xFF))/255.0 alpha:1.0].CGColor;
        self.view.layer.shadowOpacity = self.shadowOpacity != 0 ? self.shadowOpacity : SS_DEFAULT_SHADOW_OPACITY;
    } else {
        self.view.layer.shadowOffset = CGSizeZero;
        self.view.layer.shadowRadius = 0;
        self.view.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.view.layer.shadowOpacity = 0;
    }
}

#pragma mark - TransitionMethods
- (void)transitionStarted {
    
    [self.view endEditing:YES];
    
    self.previousVc.view.frame = CGRectMake(SS_PREVIOUS_VIEW_STARTING_POINT, 0, SS_SCREEN_WIDTH, SS_SCREEN_HEIGHT);
    
    [self.previousVc.view addSubview:self.topView];
    
    [self showShadow:YES];
    
    self.transitioning = YES;
}

- (void)transitioning:(CGPoint)translation {

    CGRect presentF = self.view.frame;
    presentF.origin.x = translation.x;
    if (presentF.origin.x < 0) {
        presentF.origin.x = 0;
    }
    self.view.frame = presentF;
    
    CGRect previousF = self.previousVc.view.frame;
    previousF.origin.x = SS_PREVIOUS_VIEW_STARTING_POINT + translation.x * 0.5;
    self.previousVc.view.frame = previousF;
}

- (void)transitionSuccess {
    
    self.transitioning = NO;
    self.view.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:SS_ANIMATION_DURATION animations:^{
        self.view.frame = CGRectMake(SS_SCREEN_WIDTH, 0, SS_SCREEN_WIDTH, SS_SCREEN_HEIGHT);
        
        self.previousVc.view.layer.opacity = 1.0;
        self.topView.layer.opacity = 1.0;
        
        self.previousVc.view.frame = CGRectMake(0, 0, SS_SCREEN_WIDTH, SS_SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        
        [self showShadow:NO];
        
        self.view.frame = CGRectMake(0, 0, SS_SCREEN_WIDTH, SS_SCREEN_HEIGHT);
        self.navigationBar.frame = CGRectMake(-SS_SCREEN_WIDTH, SS_STATUSBAR_HEIGHT, SS_SCREEN_WIDTH, SS_NAVIGATIONBAR_HEIGHT);
        [self popViewControllerAnimated:NO];
        self.previousVc.view.userInteractionEnabled = YES;
        [UIView animateWithDuration:SS_SPRING_ANIMATION_DURATION delay:0 usingSpringWithDamping:SS_SPRING_DAMPING initialSpringVelocity:SS_SPRING_VELOCITY options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            self.navigationBar.frame = CGRectMake(0, SS_STATUSBAR_HEIGHT, SS_SCREEN_WIDTH, SS_NAVIGATIONBAR_HEIGHT);
        } completion:^(BOOL finished) {
            self.previousVc = nil;
            self.navTranslation = CGPointZero;
            [self.topView removeFromSuperview];
            self.topView = nil;
            
            self.view.userInteractionEnabled = YES;
        }];
    }];
}

- (void)transitionRollBack {
    
    self.transitioning = NO;
    self.view.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:SS_ANIMATION_DURATION animations:^{
        self.view.frame = CGRectMake(0, 0, SS_SCREEN_WIDTH, SS_SCREEN_HEIGHT);
        
        self.previousVc.view.frame = CGRectMake(SS_PREVIOUS_VIEW_STARTING_POINT, 0, SS_SCREEN_WIDTH, SS_SCREEN_HEIGHT);
        
        self.topView.layer.opacity = self.previousViewOpacity ? self.previousViewOpacity : SS_PREVIOUS_VIEW_OPACITY;
        self.navigationBar.frame = CGRectMake(0, SS_STATUSBAR_HEIGHT, SS_SCREEN_WIDTH, SS_NAVIGATIONBAR_HEIGHT);
        
    } completion:^(BOOL finished) {
        [self showShadow:NO];
        self.previousVc.view.userInteractionEnabled = YES;
        self.previousVc.view.layer.opacity = 1.0;
        [self.previousVc.view removeFromSuperview];

        self.previousVc = nil;
        
        self.navTranslation = CGPointZero;
        self.topView.layer.opacity = 1.0;
        [self.topView removeFromSuperview];
        self.topView = nil;
        
        self.view.userInteractionEnabled = YES;
    }];
}

#pragma mark - properties
- (UIViewController *)previousVc {
    if (_previousVc == nil) {
        UIViewController *previousVc = self.viewControllers[self.viewControllers.count - 2];
        [self.keyWindow insertSubview:previousVc.view belowSubview:self.view];
        previousVc.view.layer.opacity = self.previousViewOpacity ? self.previousViewOpacity : SS_PREVIOUS_VIEW_OPACITY;
        previousVc.view.userInteractionEnabled = NO;
        _previousVc = previousVc;
    }
    return _previousVc;
}

- (UIView *)topView {
    if (_topView == nil) {
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SS_SCREEN_WIDTH, SS_NAVIGATIONBAR_BOTTOM)];
        topView.backgroundColor = self.navigationBar.barTintColor;
        topView.layer.opacity = self.previousViewOpacity ? self.previousViewOpacity : SS_PREVIOUS_VIEW_OPACITY;
        _topView = topView;
    }
    return _topView;
}

@end

