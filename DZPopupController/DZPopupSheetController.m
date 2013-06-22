//
//  DZPopupSheetController.m
//  DZPopupController
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZPopupSheetController.h"
#import "DZPopupControllerFrameView.h"
#import "DZPopupControllerInsetView.h"
#import "DZPopupControllerCloseButton.h"
#import <QuartzCore/QuartzCore.h>

@interface DZPopupSheetController ()

@property (nonatomic, strong) DZPopupControllerFrameView *frameView;
@property (nonatomic, weak) DZPopupControllerInsetView *insetView;
@property (nonatomic, weak) DZPopupControllerCloseButton *closeButton;
@property (nonatomic) UIStatusBarStyle backupStatusBarStyle;


@end

@implementation DZPopupSheetController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	CGFloat shadowPad = 24;
	CGRect frameVisualRect = UIEdgeInsetsInsetRect(self.view.bounds, _frameEdgeInsets);
	CGRect frameOuterRect = CGRectInset(frameVisualRect, -shadowPad, -shadowPad);

	DZPopupControllerFrameView *frame = [[DZPopupControllerFrameView alloc] initWithFrame:frameOuterRect];
	frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	frame.baseColor = self.frameColor;
	[self.view addSubview: frame];
	self.frameView = frame;
    
	[self configureFrameView];
	[self configureInsetView];
	[self configureCloseButton];
    
    self.contentView.frame = frame.bounds;
    [frame addSubview:self.contentView];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	if (![self.contentViewController isKindOfClass: [UINavigationController class]])
		return;
			
	UINavigationController *navigationController = (id)self.contentViewController;
	
	// Navigation	
	CGFloat navBarHeight = navigationController.navigationBarHidden ? 0.0 : navigationController.navigationBar.frame.size.height,
	toolbarHeight = navigationController.toolbarHidden ? 2.0 : navigationController.toolbar.frame.size.height;

	if (self.insetView) {
		CGRect cFrame = self.contentView.frame;
		self.insetView.frame = CGRectMake(CGRectGetMinX(cFrame), CGRectGetMinY(cFrame) + navBarHeight - 2, CGRectGetWidth(cFrame), CGRectGetHeight(cFrame) - navBarHeight - toolbarHeight + 4.0f);
		self.insetView.clippedDrawing = navigationController.toolbarHidden;
	}
}

#pragma mark - Properties

- (void)setContentViewController:(UIViewController *)newController animated:(BOOL)animated {
    [super setContentViewController:newController animated:animated];
    [self.frameView setNeedsDisplay];
}

- (void)setFrameEdgeInsets:(UIEdgeInsets)frameEdgeInsets {
	[self setFrameEdgeInsets: frameEdgeInsets animated: NO];
}

- (void)setFrameEdgeInsets:(UIEdgeInsets)frameEdgeInsets animated:(BOOL)animated {
	_frameEdgeInsets = frameEdgeInsets;

	if (!self.isViewLoaded)
		return;

	void (^animations)(void) = ^{
		CGRect superViewBounds = [[UIScreen mainScreen] applicationFrame];
		superViewBounds.origin = CGPointZero;
		self.frameView.frame = UIEdgeInsetsInsetRect(superViewBounds, self.frameEdgeInsets);
	};

	if (animated) {
		[UIView animateWithDuration: animated ? 1./3. : 0 delay: 0 options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews animations: animations completion: NULL];
	} else {
		animations();
	}
}

- (void)setFrameColor:(UIColor*)frameColor {
	[self setFrameColor: frameColor animated: NO];
}

- (void)setFrameColor:(UIColor*)frameColor animated:(BOOL)animated {
	if ([self.frameColor isEqual: frameColor])
		return;
	
	_frameColor = frameColor;

	void (^configureAppearance)(void) = ^{
		id toolbarAppearance = [UIToolbar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
		id navigationBarAppearance = [UINavigationBar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
		id specialToolbarAppearance = [UIToolbar appearanceWhenContainedIn: [UINavigationBar class], [UINavigationController class], [self class], nil];
		[navigationBarAppearance setTintColor: frameColor];
		[toolbarAppearance setBackgroundColor: frameColor];
		[specialToolbarAppearance setBackgroundColor: nil];
		[specialToolbarAppearance setTintColor: nil];
	};

	if (self.frameView) {
		[UIView transitionWithView: self.frameView duration: animated ? 1./3. : 0 options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations: ^{
			self.frameView.baseColor = frameColor;
			[self.frameView setNeedsDisplay];

			if (self.insetView) {
				self.insetView.baseColor = frameColor;
				[self.insetView setNeedsDisplay];
			}

			configureAppearance();
		} completion: NULL];
	} else {
		configureAppearance();
	}
}

#pragma mark - Subclassable methods

- (void)setDefaultAppearance {
	self.frameColor = [UIColor colorWithRed:0.10f green:0.12f blue:0.16f alpha:1.00f];
	self.frameEdgeInsets = UIEdgeInsetsMake(33, 33, 33, 33);
}

- (void)configureFrameView {
	self.frameView.decorated = YES;
	self.contentView.frame = CGRectInset(self.frameView.bounds, 26, 26);
	self.contentView.layer.cornerRadius = 7.0f;
	self.contentView.clipsToBounds = YES;

	id toolbarAppearance = [UIToolbar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
	[toolbarAppearance setBackgroundImage: UIGraphicsGetImageFromCurrentImageContext() forToolbarPosition: UIToolbarPositionAny barMetrics: UIBarMetricsDefault];
	UIGraphicsEndImageContext();
}

- (void)configureInsetView {
	if (self.insetView)
		return;

	DZPopupControllerInsetView *overlay = [DZPopupControllerInsetView new];
	overlay.backgroundColor = [UIColor clearColor];
	overlay.contentMode = UIViewContentModeRedraw;
	overlay.userInteractionEnabled = NO;
	overlay.baseColor = self.frameColor;
	[self.frameView addSubview: overlay];
	self.insetView = overlay;
}

- (void)configureCloseButton {
	if (self.closeButton) return;

	DZPopupControllerCloseButton *closeButton = [[DZPopupControllerCloseButton alloc] initWithFrame: CGRectMake(12, 12, 26, 26)];
	closeButton.showsTouchWhenHighlighted = YES;
	[closeButton addTarget: self action:@selector(closePressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.frameView addSubview: closeButton];
	self.closeButton = closeButton;
}

#pragma mark - Internal

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([object isEqual: self.contentViewController]) {
		[self.view setNeedsLayout];
		return;
	}
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)closePressed:(UIButton *)closeButton {
	[self dismissWithCompletion: NULL];
}

- (UIView *)contentViewForPerformingAnimation {
    return self.frameView;
}

@end
