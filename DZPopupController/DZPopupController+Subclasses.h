//
//  DZPopupController_Subclasses.h
//  DZPopupControllerDemo
//
//  Created by Zach Waldowski on 6/22/13.
//  Copyright (c) 2013 Dizzy Technology. All rights reserved.
//

#import "DZPopupController.h"

extern const CGFloat DZPopupControllerBorderRadius;
extern CGFloat DZPopupControllerShadowPadding(void);

extern void DZPopupSetFrameDuringTransform(UIView *view, CGRect newFrame);

@interface DZPopupController (SubclassingHooks)

- (CGFloat)statusBarHeight;

- (UIView *)contentViewForPerformingAnimation;
- (void)performAnimationWithStyle:(DZPopupTransitionStyle)style entering:(BOOL)entering
							delay:(NSTimeInterval)delay completion:(void(^)(void))block;

@property (nonatomic, weak, readonly) UIWindow *previousKeyWindow;
@property (nonatomic, weak, readonly) UIControl *backgroundView;
@property (nonatomic, strong, readonly) UIView *contentView;

@end
