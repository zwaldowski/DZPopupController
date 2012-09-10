//
//  DZSemiModalPopupController.m
//  DZPopupController
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZSemiModalPopupController.h"
#import "DZPopupControllerFrameView.h"
#import <QuartzCore/QuartzCore.h>

@interface DZPopupController ()

@property (nonatomic, weak) DZPopupControllerFrameView *frameView;
@property (nonatomic, weak) UIControl *backgroundView;
@property (nonatomic, weak) UIWindow *oldKeyWindow;
- (void)closePressed:(UIButton *)closeButton;
- (void)performAnimationWithStyle: (DZPopupTransitionStyle)style entering: (BOOL)entering duration: (NSTimeInterval)duration completion: (void(^)(void))block;

@end

static inline void _DZRaiseUnavailable(Class cls, SEL cmd) {
	[NSException raise: NSInvalidArgumentException format: @"%@ is unavailable on %@", NSStringFromSelector(cmd), NSStringFromClass(cls)];
}

#define DZRaiseUnavailable() _DZRaiseUnavailable([self class], _cmd)

@implementation DZSemiModalPopupController

#pragma mark - Internal super methods

- (void)setDefaultAppearance {
	[super setFrameColor: nil];
}

- (void)configureFrameView {
	self.frameView.decorated = NO;

	id toolbarAppearance = [UIToolbar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
	[toolbarAppearance setBackgroundImage: nil forToolbarPosition: UIToolbarPositionAny barMetrics: UIBarMetricsDefault];
}

- (void)configureInsetView {

}

- (void)configureCloseButton {
	
}

#pragma mark - Restricted subclass methods

- (DZPopupTransitionStyle)entranceStyle {
	return DZPopupTransitionStyleSlideBottom;
}

- (DZPopupTransitionStyle)exitStyle {
	return DZPopupTransitionStyleSlideBottom;
}

- (void)setEntranceStyle:(DZPopupTransitionStyle)entranceStyle {
	DZRaiseUnavailable();
}

- (void)setExitStyle:(DZPopupTransitionStyle)exitStyle {
	DZRaiseUnavailable();
}

- (void)setFrameEdgeInsets:(UIEdgeInsets)frameEdgeInsets animated:(BOOL)animated {
	DZRaiseUnavailable();
}

- (void)setFrameEdgeInsets:(UIEdgeInsets)frameEdgeInsets {
	DZRaiseUnavailable();
}

- (UIEdgeInsets)frameEdgeInsets {
	DZRaiseUnavailable();
	return UIEdgeInsetsZero;
}

#pragma mark - Layout

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.backgroundView addTarget: self action: @selector(closePressed:) forControlEvents: UIControlEventTouchUpInside];
}

- (void)setViewFrameFromMiddle {
	CGRect appFrame = self.view.bounds;
	CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
	CGFloat statusBarHeight = statusBarFrame.size.height == appFrame.size.width ?  statusBarFrame.size.width : statusBarFrame.size.height;
	UIEdgeInsets inset = UIEdgeInsetsMake(appFrame.size.height / 2 - statusBarHeight, 0, 0, 0);
	self.frameView.frame = UIEdgeInsetsInsetRect(appFrame, inset);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self setViewFrameFromMiddle];
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewDidLayoutSubviews {
	[self setViewFrameFromMiddle];
	[super viewDidLayoutSubviews];
}

#pragma mark - Present and dismiss

- (void)performAnimationWithStyle: (DZPopupTransitionStyle)style entering: (BOOL)entering duration: (NSTimeInterval)duration completion: (void(^)(void))block {
	[super performAnimationWithStyle:style entering:entering duration:duration completion:block];

	if (!self.pushesContentBack)
		return;

	CATransform3D t1 = CATransform3DIdentity;
	CATransform3D t2 = CATransform3DIdentity;

	BOOL isPortrait = UIInterfaceOrientationIsPortrait([[self.oldKeyWindow valueForKeyPath: @"interfaceOrientation"] intValue]);

	t1.m34 = t2.m34 = 1.0 / -900;
	t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
	t1 = CATransform3DRotate(t1, 15.0f*M_PI/180.0f, isPortrait ? 1 : 0, isPortrait ? 0 : -1, 0);
	if (isPortrait)
		t2 = CATransform3DTranslate(t2, 0, self.oldKeyWindow.frame.size.height*-0.08, 0);
	else {
		t2 = CATransform3DTranslate(t2, self.oldKeyWindow.frame.size.width*-0.08, 0, 0);
	}
	t2 = CATransform3DScale(t2, 0.8, 0.8, 1);

	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
	animation.toValue = [NSValue valueWithCATransform3D:t1];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

	CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
	animation2.toValue = [NSValue valueWithCATransform3D: entering ? t2 : CATransform3DIdentity];

	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.removedOnCompletion = NO;

	group.fillMode = animation.fillMode = animation2.fillMode = kCAFillModeForwards;
	animation.duration = animation2.beginTime = animation2.duration = duration/2;
	group.duration = duration;

	group.animations = @[ animation, animation2 ];
	
	[self.oldKeyWindow.layer addAnimation: group forKey: nil];
}

@end
