//
//  DZSemiModalPopupController.m
//  DZPopupControllerDemo
//
//  Created by Zachary Waldowski on 9/9/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZSemiModalPopupController.h"
#import "DZPopupControllerFrameView.h"

@interface DZPopupController ()

@property (nonatomic, weak) DZPopupControllerFrameView *frameView;
@property (nonatomic, weak) UIControl *backgroundView;
- (void)closePressed:(UIButton *)closeButton;

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

@end
