//
//  UIScrollView+AllowPanGestureEventPass.m
//  SSNavigationController
//
//  Created by stevenSu on 16/1/14.
//  Copyright © 2016年 stevenSu. All rights reserved.
//

#import "UIScrollView+AllowPanGestureEventPass.h"

@implementation UIScrollView (AllowPanGestureEventPass)
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([self isKindOfClass:[UITableView class]]) {
        return NO;
    }
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && self.contentOffset.x <= 0) {
        
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)otherGestureRecognizer;
        CGPoint translation = [gesture translationInView:self];
        
        if (fabs(translation.y) > fabs(translation.x)) {
            return  NO;
        } else {
            if (translation.x > 0) {
                return YES;
            }
            return NO;
        }
    } else {
        return NO;
    }
}
@end
