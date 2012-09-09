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

- (BOOL)dz_shouldUseCloseButton {
	return NO;
}

- (BOOL)dz_shouldUseInset {
	return NO;
}

- (BOOL)dz_shouldUseDecoratedFrame {
	return NO;
}

- (void)dz_configureDefaultAppearance {
	[super setFrameColor: nil];
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
	[super setFrameEdgeInsets: UIEdgeInsetsMake(appFrame.size.height / 2 - statusBarFrame.size.height, 0, 0, 0) animated: NO];
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

- (void)dz_setFrameFromMiddle {
	CGRect appFrame = self.view.bounds;
	CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
	CGFloat statusBarHeight = statusBarFrame.size.height == appFrame.size.width ?  statusBarFrame.size.width : statusBarFrame.size.height;
	UIEdgeInsets inset = UIEdgeInsetsMake(appFrame.size.height / 2 - statusBarHeight, 0, 0, 0);
	self.frameView.frame = UIEdgeInsetsInsetRect(appFrame, inset);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self dz_setFrameFromMiddle];
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewDidLayoutSubviews {
	[self dz_setFrameFromMiddle];
	[super viewDidLayoutSubviews];
}

@end
