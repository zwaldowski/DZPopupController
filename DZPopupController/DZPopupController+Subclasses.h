//
//  DZPopupController_Subclasses.h
//  DZPopupControllerDemo
//
//  Created by Zach Waldowski on 6/22/13.
//  Copyright (c) 2013 Dizzy Technology. All rights reserved.
//

#import "DZPopupController.h"

@interface DZPopupController (SubclassingHooks)

- (UIView *)contentViewForPerformingAnimation;
- (void)performAnimationWithStyle:(DZPopupTransitionStyle)style entering:(BOOL)entering duration:(NSTimeInterval)duration completion:(void(^)(void))block;

@property (nonatomic, weak, readonly) UIWindow *previousKeyWindow;
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, weak, readonly) UIControl *backgroundView;

@end
