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

static void DZSemiModalMakePushBackTransforms(CGSize frameSize, UIInterfaceOrientation orient, BOOL entering, CATransform3D *step1, CATransform3D *step2) {
	BOOL isPortrait = UIInterfaceOrientationIsPortrait(orient);
	CATransform3D t1 = CATransform3DIdentity;
	t1.m34 = 1.0 / -900;
	t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
	t1 = CATransform3DRotate(t1, 15.0f*M_PI/180.0f, isPortrait ? 1 : 0, isPortrait ? 0 : -1, 0);
	CATransform3D t2 = entering ? DZSemiModalTranslationForFrameSize(frameSize, orient) : CATransform3DIdentity;
	if (step1) *step1 = t1;
	if (step2) *step2 = t2;
}

@implementation DZSemiModalPopupController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.contentView.layer.shadowOffset = CGSizeMake(0, -2);
	self.contentView.layer.shadowOpacity = 0.7f;
	self.contentView.layer.shadowRadius = 10.0f;
	self.contentView.layer.shouldRasterize = YES;
	self.contentView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    [self.backgroundView addTarget: self action: @selector(dismiss) forControlEvents: UIControlEventTouchUpInside];
    
	id toolbarAppearance = [UIToolbar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
	[toolbarAppearance setBackgroundImage: nil forToolbarPosition: UIToolbarPositionAny barMetrics: UIBarMetricsDefault];
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

- (void)setViewFrameFromMiddle {
	CGRect appFrame = self.view.bounds;
	CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
	CGFloat statusBarHeight = statusBarFrame.size.height == appFrame.size.width ?  statusBarFrame.size.width : statusBarFrame.size.height;
	if (!self.height)
		_height = appFrame.size.height / 2;
	CGFloat topInset = MAX(appFrame.size.height - self.height, statusBarHeight);
	UIEdgeInsets inset = UIEdgeInsetsMake(topInset, 0, 0, 0);
	self.contentView.frame = UIEdgeInsetsInsetRect(appFrame, inset);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[self setViewFrameFromMiddle];

	UIView *view = nil;
	BOOL pushesContentBack = self.pushesContentBack;

	if (pushesContentBack) {
		UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
		if (self.presentingViewController) {
			view = self.presentingViewController.view;
			orient = self.presentingViewController.interfaceOrientation;
		} else {
			view = self.previousKeyWindow;
			orient = [[self.previousKeyWindow valueForKeyPath: @"interfaceOrientation"] intValue];
		}

		if (view) {
			CGSize frameSize = view.bounds.size;
			UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut;
			[UIView animateWithDuration:duration delay:0 options:opt animations:^{
				view.layer.transform = DZSemiModalTranslationForFrameSize(frameSize, orient);
			} completion:NULL];
		}
	}
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
	if (animated) {
		[UIView animateWithDuration:(1./3.) delay:0 options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
			self.height = height;
		} completion: NULL];
	} else {
		self.height = height;
	}
}

#pragma mark - Present and dismiss

- (void)performAnimationWithStyle: (DZPopupTransitionStyle)style entering: (BOOL)entering duration: (NSTimeInterval)duration completion: (void(^)(void))block {
	UIView *view = nil;
	BOOL pushesContentBack = self.pushesContentBack;
	
	if (pushesContentBack) {
		UIInterfaceOrientation orient = UIInterfaceOrientationPortrait;
		if (self.presentingViewController) {
			view = self.presentingViewController.view;
			orient = self.presentingViewController.interfaceOrientation;
		} else {
			view = self.previousKeyWindow;
			orient = [[self.previousKeyWindow valueForKeyPath: @"interfaceOrientation"] intValue];
		}

		if (view) {
			CGSize frameSize = view.bounds.size;
			
			if (entering) {
				view.layer.zPosition = -100;
			}

			NSTimeInterval pushDuration = duration / 2;
			CATransform3D t1, t2;
			DZSemiModalMakePushBackTransforms(frameSize, orient, entering, &t1, &t2);

			UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut;
			[UIView animateWithDuration:pushDuration delay:0 options:opt animations:^{
				view.layer.transform = t1;
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:pushDuration delay:0 options:opt animations:^{
					view.layer.transform = t2;
				} completion:NULL];
			}];
		}
	}

	[super performAnimationWithStyle:style entering:entering duration:duration completion:^{
		if (!entering && pushesContentBack && view) {
			view.layer.transform = CATransform3DIdentity;
			view.layer.zPosition = 0;
		}

		if (block) block();
	}];
}

@end
