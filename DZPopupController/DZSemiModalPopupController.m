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
#import "DZPopupSheetController.h"
#import <QuartzCore/QuartzCore.h>

static CATransform3D DZSemiModalTranslationForFrameSize(CGSize frameSize, UIInterfaceOrientation orientation) {
	BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
	CATransform3D translation = CATransform3DIdentity;
	translation.m34 = 1.0 / -900;
	CGFloat extra = DZPopupUIIsStark() ? [[UIApplication sharedApplication] statusBarFrame].size.height / 2 : 0;
	if (isPortrait) {
		CGFloat factor = (orientation == UIInterfaceOrientationPortrait) ? -0.08 : 0.08;
		translation = CATransform3DTranslate(translation, 0, frameSize.height*factor + extra, 0);
	} else {
		CGFloat factor = (orientation == UIInterfaceOrientationLandscapeLeft) ? -0.08 : 0.08;
		translation = CATransform3DTranslate(translation, frameSize.width*factor, 0 + extra, 0);
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

@interface DZSemiModalPopupController ()

@property (nonatomic, weak) UIView *frameView;

@end

@implementation DZSemiModalPopupController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIView *frame = [[UIView alloc] initWithFrame:self.frameForFrameView];
	frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview: frame];
	self.frameView = frame;
	
	CGRect contentFrame = frame.bounds;
	CGFloat inset = DZPopupControllerShadowPadding();
	contentFrame.origin.y += inset;
	contentFrame.size.height -= inset;
    self.contentView.frame = contentFrame;
	
	self.contentView.layer.shadowOffset = CGSizeMake(0, -2);
	self.contentView.layer.shadowOpacity = 0.7f;
	self.contentView.layer.shadowRadius = 10.0f;
	if (!DZPopupUIIsStark()) {
		self.contentView.layer.shouldRasterize = YES;
		self.contentView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
	}

    [frame addSubview:self.contentView];
    
    [self.backgroundView addTarget: self action: @selector(dismiss) forControlEvents: UIControlEventTouchUpInside];
    
	id toolbarAppearance = [UIToolbar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
	[toolbarAppearance setBackgroundImage: nil forToolbarPosition: UIToolbarPositionAny barMetrics: UIBarMetricsDefault];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	DZPopupSetFrameDuringTransform(self.frameView, self.frameForFrameView);
	
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

#pragma mark - Restricted

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

#pragma mark - Internal

- (CGRect)frameForFrameView {
	CGRect appFrame = self.view.bounds;
	CGFloat appHeight = appFrame.size.height;
	
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && !self.view.window) {
		// initializing in landscape mode
		appHeight = appFrame.size.width;
	}
	
	CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
	CGFloat statusBarHeight = statusBarFrame.size.height == appFrame.size.width ?  statusBarFrame.size.width : statusBarFrame.size.height;
	
	if (!self.height)
		_height = appHeight / 2;
	
	CGFloat topInset = MAX(appFrame.size.height - self.height, statusBarHeight) - DZPopupControllerShadowPadding();
	
	CGRect newFrame = appFrame;
	newFrame.origin.y += topInset;
	newFrame.size.height -= topInset;
	
	return newFrame;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return self.pushesContentBack ? UIStatusBarStyleBlackTranslucent : [super preferredStatusBarStyle];
}

- (UIView *)contentViewForPerformingAnimation
{
    return self.frameView;
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	DZPopupSetFrameDuringTransform(self.frameView, self.frameForFrameView);
}

#pragma mark - Accessors

- (void)setHeight:(CGFloat)height {
	[self setHeight:height animated:NO];
}

- (void)setHeight:(CGFloat)height animated:(BOOL)animated {
	_height = height;
	
	if (!self.isViewLoaded)
		return;
	
	void (^animations)(void) = ^{
        DZPopupSetFrameDuringTransform(self.frameView, self.frameForFrameView);
	};
	
	if (animated) {
		UIViewAnimationOptions opts = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState;
		[UIView animateWithDuration:DZPopupAnimationDuration delay:0 options:opts animations:animations completion:NULL];
	} else {
		animations();
	}
}


#pragma mark - Present and dismiss

- (void)performAnimationWithStyle:(DZPopupTransitionStyle)style
						 entering:(BOOL)entering
							delay:(NSTimeInterval)delay
					   completion:(void (^)(void))block
{
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
			
			NSTimeInterval pushDuration = DZPopupAnimationDuration / 2;
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
	
	[super performAnimationWithStyle:style entering:entering delay:delay completion:^{
		if (!entering && pushesContentBack && view) {
			view.layer.transform = CATransform3DIdentity;
			view.layer.zPosition = 0;
		}
		
		if (block) block();
	}];
}

@end
