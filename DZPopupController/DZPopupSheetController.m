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

@property (nonatomic, weak) DZPopupControllerFrameView *frameView;
@property (nonatomic, weak) DZPopupControllerInsetView *insetView;
@property (nonatomic, weak) DZPopupControllerCloseButton *closeButton;

@end

@implementation DZPopupSheetController

- (void)viewDidLoad {
	[super viewDidLoad];
 
	self.frameColor = [UIColor colorWithRed:0.10f green:0.12f blue:0.16f alpha:1.00f];
	self.frameEdgeInsets = UIEdgeInsetsMake(33, 33, 33, 33);
	self.frameStyle = DZPopupUIIsStark() ? DZPopupSheetFrameStyleStark : DZPopupSheetFrameStyleAll;
    
    CGRect frameViewFrame = [self frameForFrameView];

	DZPopupControllerFrameView *frame = [[DZPopupControllerFrameView alloc] initWithFrame:frameViewFrame];
	frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	frame.baseColor = self.frameColor;
	[self.view addSubview: frame];
	self.frameView = frame;
    
    self.contentView.frame = frame.bounds;
    [frame addSubview:self.contentView];
    
	[self configureFrameStyle];
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

#pragma mark - Accessors

- (void)setContentViewController:(UIViewController *)newController animated:(BOOL)animated {
	UIViewController *oldController = self.contentViewController;
	
	if (oldController) {
		if ([oldController isKindOfClass: [UINavigationController class]]) {
			[oldController removeObserver: self forKeyPath: @"toolbar.bounds"];
			[oldController removeObserver: self forKeyPath: @"navigationBar.bounds"];
		}
	}
    
    [super setContentViewController:newController animated:animated];
    
    [self.frameView setNeedsDisplay];
    
    if (newController) {
        if ([newController isKindOfClass: [UINavigationController class]]) {
			UINavigationController *navigationController = (id)newController;
			[navigationController addObserver: self forKeyPath: @"toolbar.bounds" options: 0 context: NULL];
			[navigationController addObserver: self forKeyPath: @"navigationBar.bounds" options: 0 context: NULL];
		}
		
		[self.view setNeedsLayout];
    }
}

- (void)setFrameEdgeInsets:(UIEdgeInsets)frameEdgeInsets {
	[self setFrameEdgeInsets: frameEdgeInsets animated: NO];
}

- (void)setFrameEdgeInsets:(UIEdgeInsets)frameEdgeInsets animated:(BOOL)animated {
	_frameEdgeInsets = frameEdgeInsets;

	if (!self.isViewLoaded)
		return;

	void (^animations)(void) = ^{
        self.frameView.frame = [self frameForFrameView];
	};

	if (animated) {
		UIViewAnimationOptions opts = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState;
		[UIView animateWithDuration:DZPopupAnimationDuration delay:0 options:opts animations:animations completion:NULL];
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
		if (DZPopupUIIsStark()) {
			id barButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationController class], [self class], nil];
			[barButtonItem setTintColor: frameColor];
		} else {
			id toolbarAppearance = [UIToolbar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
			id navigationBarAppearance = [UINavigationBar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
			id specialToolbarAppearance = [UIToolbar appearanceWhenContainedIn: [UINavigationBar class], [UINavigationController class], [self class], nil];

			[navigationBarAppearance setTintColor: frameColor];
			[toolbarAppearance setTintColor: frameColor];
			[toolbarAppearance setBackgroundColor: frameColor];
			[specialToolbarAppearance setBackgroundColor: nil];
			[specialToolbarAppearance setTintColor: nil];
		}
	};

	if (self.frameView && animated) {
		UIViewAnimationOptions opts = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionBeginFromCurrentState;
		[UIView transitionWithView:self.frameView duration:DZPopupAnimationDuration options:opts animations:^{
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

- (void)setFrameStyle:(DZPopupSheetFrameStyle)frameStyle
{
    [self setFrameStyle:frameStyle animated:NO];
}

- (void)setFrameStyle:(DZPopupSheetFrameStyle)frameStyle animated:(BOOL)animated
{
    if (!self.isViewLoaded || _frameStyle == frameStyle) return;
    
    _frameStyle = frameStyle;
    
    if (!self.frameView) return;
    
    void (^configure)(void) = ^{
        [self configureFrameStyle];
		self.frameView.frame = [self frameForFrameView];
    };
    
    if (animated) {
        UIViewAnimationOptions opts = UIViewAnimationOptionLayoutSubviews |
                                    UIViewAnimationOptionBeginFromCurrentState |
                                    UIViewAnimationOptionCurveEaseInOut |
                                    UIViewAnimationOptionTransitionCrossDissolve;
        [UIView transitionWithView:self.view duration:DZPopupAnimationDuration options:opts animations:configure completion:NULL];
    } else {
        configure();
    }
}

#pragma mark - Internal

- (UIView *)contentViewForPerformingAnimation
{
    return self.frameView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([object isEqual: self.contentViewController]) {
		[self.view setNeedsLayout];
		return;
	}
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (CGRect)frameForFrameView
{
    const CGFloat shadowPad = DZPopupControllerShadowPadding();
	CGRect frameVisualRect = UIEdgeInsetsInsetRect(self.view.bounds, self.frameEdgeInsets);
	CGRect frameOuterRect = CGRectInset(frameVisualRect, -shadowPad, -shadowPad);
    return frameOuterRect;
}

- (void)configureFrameStyle {
	const DZPopupSheetFrameStyle frameStyle = self.frameStyle;
	const BOOL hasShadow = (frameStyle & DZPopupSheetFrameStyleShadowed),
	hasBorder = (frameStyle & DZPopupSheetFrameStyleBordered),
	hasBezel = (frameStyle & DZPopupSheetFrameStyleBezel && !DZPopupUIIsStark()),
	hasClose = (frameStyle & DZPopupSheetFrameStyleCloseButton);

	UIScreen *screen = self.view.window ? self.view.window.screen : [UIScreen mainScreen];
	const CGFloat scale = screen.scale;
	
	CGFloat inset = DZPopupControllerShadowPadding();
	if (hasShadow) {
		if (DZPopupUIIsStark()) {
			inset -= 0.5f;
		} else {
			inset += 0.5f;
		}
	}	
	if (hasBorder) inset += 1.5f;
	inset = roundf(inset * scale) / scale;
	
	self.contentView.frame = CGRectInset(self.frameView.bounds, inset, inset);
	self.contentView.layer.cornerRadius = DZPopupControllerBorderRadius - 1.0f;
	self.contentView.clipsToBounds = YES;
	self.frameView.shadowed = hasShadow;
	self.frameView.bordered = hasBorder;
	
	if (!DZPopupUIIsStark()) {
		UIImage *toolbarBG = nil;
		if (hasBezel) {
			UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
			toolbarBG = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
		}
		UIToolbar *toolbarAppearance = [UIToolbar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
		[toolbarAppearance setBackgroundImage: toolbarBG forToolbarPosition: UIToolbarPositionAny barMetrics: UIBarMetricsDefault];
		UIGraphicsEndImageContext();
	}
	
	if (hasClose) {
		if (!self.closeButton) {
			DZPopupControllerCloseButton *closeButton = [[DZPopupControllerCloseButton alloc] initWithFrame: CGRectMake(14, 14, 26, 26)];
			closeButton.showsTouchWhenHighlighted = YES;
			[closeButton addTarget: self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
			[self.frameView addSubview: closeButton];
			self.closeButton = closeButton;
		}
	} else {
		if (self.closeButton) {
			[self.closeButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
			[self.closeButton removeFromSuperview];
		}
	}
	
	if (hasBezel) {
		if (!self.insetView) {
			DZPopupControllerInsetView *overlay = [DZPopupControllerInsetView new];
			overlay.backgroundColor = [UIColor clearColor];
			overlay.contentMode = UIViewContentModeRedraw;
			overlay.userInteractionEnabled = NO;
			overlay.baseColor = self.frameColor;
			[self.frameView addSubview: overlay];
			self.insetView = overlay;
		}
	} else {
		if (self.insetView) {
			[self.insetView removeFromSuperview];
		}
	}
}


@end
