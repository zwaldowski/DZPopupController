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

static CATransform3D DZSemiModalTranslationForFrameSize(CGSize frameSize, UIInterfaceOrientation orientation) {
	BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
	CATransform3D translation = CATransform3DIdentity;
	translation.m34 = 1.0 / -900;
	if (isPortrait) {
		CGFloat factor = (orientation == UIInterfaceOrientationPortrait) ? -0.08 : 0.08;
		translation = CATransform3DTranslate(translation, 0, frameSize.height*factor, 0);
	} else {
		CGFloat factor = (orientation == UIInterfaceOrientationLandscapeLeft) ? -0.08 : 0.08;
		translation = CATransform3DTranslate(translation, frameSize.width*factor, 0, 0);
	}
	return CATransform3DScale(translation, 0.8, 0.8, 1);
}

static CAAnimationGroup *DZSemiModalPushBackAnimationForFrameSize(CGSize frameSize, UIInterfaceOrientation orientation, NSTimeInterval duration, BOOL entering) {
	BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
	CATransform3D t1 = CATransform3DIdentity;
	t1.m34 = 1.0 / -900;
	t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
	t1 = CATransform3DRotate(t1, 15.0f*M_PI/180.0f, isPortrait ? 1 : 0, isPortrait ? 0 : -1, 0);
	CATransform3D t2 = DZSemiModalTranslationForFrameSize(frameSize, orientation);

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

	return group;
}

@interface DZPopupController ()

@property (nonatomic, weak) DZPopupControllerFrameView *frameView;
@property (nonatomic, weak) UIControl *backgroundView;
@property (nonatomic, weak) UIWindow *oldKeyWindow;
- (void)closePressed:(UIButton *)closeButton;
- (void)performAnimationWithStyle: (DZPopupTransitionStyle)style entering: (BOOL)entering duration: (NSTimeInterval)duration completion: (void(^)(void))block;

@end

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
	[self doesNotRecognizeSelector: _cmd];
}

- (void)setExitStyle:(DZPopupTransitionStyle)exitStyle {
	[self doesNotRecognizeSelector: _cmd];
}

- (void)setFrameEdgeInsets:(UIEdgeInsets)frameEdgeInsets animated:(BOOL)animated {
	[self doesNotRecognizeSelector: _cmd];
}

- (void)setFrameEdgeInsets:(UIEdgeInsets)frameEdgeInsets {
	[self doesNotRecognizeSelector: _cmd];
}

- (UIEdgeInsets)frameEdgeInsets {
	[self doesNotRecognizeSelector: _cmd];
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
	if (!self.height)
		_height = appFrame.size.height / 2;
	CGFloat topInset = MIN(appFrame.size.height - self.height, statusBarHeight);
	UIEdgeInsets inset = UIEdgeInsetsMake(topInset, 0, 0, 0);
	self.frameView.frame = UIEdgeInsetsInsetRect(appFrame, inset);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self setViewFrameFromMiddle];

	if (!self.pushesContentBack)
		return;

	CGSize frameSize = self.oldKeyWindow.frame.size;
	UIInterfaceOrientation orient = [[self.oldKeyWindow valueForKeyPath: @"interfaceOrientation"] intValue];
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
	animation.toValue = [NSValue valueWithCATransform3D: DZSemiModalTranslationForFrameSize(frameSize, orient)];
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	animation.duration = duration;
	[self.oldKeyWindow.layer addAnimation: animation forKey: nil];
}

- (void)viewDidLayoutSubviews {
	[self setViewFrameFromMiddle];
	[super viewDidLayoutSubviews];
}

- (void)setHeight:(CGFloat)height {
	_height = height;
	[self.view setNeedsLayout];
}

- (void)setHeight:(CGFloat)height animated:(BOOL)animated {
	[UIView animateWithDuration: (1./3.) delay: 0.0 options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionCurveEaseInOut animations:^{
		self.height = height;
	} completion: NULL];
}

#pragma mark - Present and dismiss

- (void)performAnimationWithStyle: (DZPopupTransitionStyle)style entering: (BOOL)entering duration: (NSTimeInterval)duration completion: (void(^)(void))block {
	if (self.pushesContentBack) {
		CGSize frameSize = self.oldKeyWindow.frame.size;
		UIInterfaceOrientation orient = [[self.oldKeyWindow valueForKeyPath: @"interfaceOrientation"] intValue];
		[self.oldKeyWindow.layer addAnimation: DZSemiModalPushBackAnimationForFrameSize(frameSize, orient, duration, entering) forKey: nil];
	}

	[super performAnimationWithStyle:style entering:entering duration:duration completion:block];
}

@end
