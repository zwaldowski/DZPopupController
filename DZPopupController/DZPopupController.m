//
//  DZPopupController.m
//  DZPopupController
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZPopupController.h"
#import "DZPopupControllerFrameView.h"
#import "DZPopupControllerInsetView.h"
#import "DZPopupControllerCloseButton.h"
#import <QuartzCore/QuartzCore.h>

@interface DZPopupController ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) UIWindow *oldKeyWindow;
@property (nonatomic, weak) UIControl *backgroundView;
@property (nonatomic, strong) DZPopupControllerFrameView *frameView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) DZPopupControllerInsetView *insetView;
@property (nonatomic, weak) DZPopupControllerCloseButton *closeButton;
@property (nonatomic) UIStatusBarStyle backupStatusBarStyle;

@end

@implementation DZPopupController {
	BOOL _dismissingViaOurMethod;
}

#pragma mark - Setup and teardown

- (id)initWithContentViewController:(UIViewController *)viewController {
	if (self = [super initWithNibName:nil bundle:nil]) {
		NSParameterAssert(viewController);

		[self setDefaultAppearance];
		
		self.contentViewController = viewController;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
    UIControl *background = [[UIControl alloc] initWithFrame: self.view.bounds];
	background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	background.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	[self.view addSubview: background];
	self.backgroundView = background;
	
	CGFloat shadowPad = 24;
	CGRect frameVisualRect = UIEdgeInsetsInsetRect(self.view.bounds, _frameEdgeInsets);
	CGRect frameOuterRect = CGRectInset(frameVisualRect, -shadowPad, -shadowPad);

	DZPopupControllerFrameView *frame = [[DZPopupControllerFrameView alloc] initWithFrame:frameOuterRect];
	frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	frame.baseColor = self.frameColor;
	[self.view addSubview: frame];
	self.frameView = frame;
	
	UIView *content = [[UIView alloc] initWithFrame: frame.bounds];
	content.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[frame addSubview: content];
	self.contentView = content;

	[self configureFrameView];
	[self configureInsetView];
	[self configureCloseButton];
	
	if (!self.contentViewController.view.superview)
		self.contentViewController = self.contentViewController;
}

- (void)dealloc {
	self.contentViewController = nil;
}

#pragma mark - UIViewController

- (NSUInteger)supportedInterfaceOrientations
{
	if (self.presentingViewController)
		return UIInterfaceOrientationMaskPortrait;
	if (self.contentViewController)
		return self.contentViewController.supportedInterfaceOrientations;
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
	if (self.presentingViewController)
		return NO;
	if (self.contentViewController)
		return [self.contentViewController shouldAutorotate];
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (self.presentingViewController)
		return NO;

	BOOL should = (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	
	if (self.contentViewController)
		should &= [self.contentViewController shouldAutorotateToInterfaceOrientation: interfaceOrientation];
	
	return should;
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.backupStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackTranslucent animated:YES];

	if (self.presentingViewController) {
		[self performAnimationWithStyle: self.entranceStyle entering: YES duration: animated ? (1./3.) : 0 completion: NULL];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle: self.backupStatusBarStyle animated:YES];
	
	if (self.presentingViewController && !_dismissingViaOurMethod) {
		[self performAnimationWithStyle: self.exitStyle entering: NO duration: animated ? (1./3.) : 0 completion:^{
			if ([self.delegate respondsToSelector:@selector(popupControllerDidDismissPopup:)]) {
				[self.delegate popupControllerDidDismissPopup:self];
			}
		}];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

#pragma mark - Properties

- (void)setContentViewController:(UIViewController *)newController {
	[self setContentViewController: newController animated: NO];
}

- (void)setContentViewController:(UIViewController *)newController animated:(BOOL)animated {
	UIViewController *oldController = self.contentViewController;
	
	if (oldController && oldController.view.superview) {
		if ([oldController isKindOfClass: [UINavigationController class]]) {
			[oldController removeObserver: self forKeyPath: @"toolbar.bounds"];
			[oldController removeObserver: self forKeyPath: @"navigationBar.bounds"];
		}
		
		if (!animated) {
			[oldController willMoveToParentViewController: nil];
			[oldController.view removeFromSuperview];
			[oldController removeFromParentViewController];
		}
	}
	
	_contentViewController = newController;
	
	if (!newController || !self.isViewLoaded)
		return;
	
	void (^addObservers)(void) = ^{
		[newController didMoveToParentViewController: self];
		
		if ([newController isKindOfClass: [UINavigationController class]]) {
			UINavigationController *navigationController = (id)newController;
			[navigationController addObserver: self forKeyPath: @"toolbar.bounds" options: NSKeyValueObservingOptionNew context: NULL];
			[navigationController addObserver: self forKeyPath: @"navigationBar.bounds" options: 0 context: NULL];
		}
		
		[self.frameView setNeedsDisplay];
		[self.view setNeedsLayout];
	};
	
	if (!oldController) {
		[UIView transitionWithView: self.contentView duration: (1./3.) options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionCrossDissolve animations:^{
			newController.view.frame = self.contentView.bounds;
			[self.contentView addSubview: newController.view];
		} completion:^(BOOL finished) {
			[self addChildViewController: newController];
			
			addObservers();
		}];
	} else if (!oldController.view.superview) {
		newController.view.frame = self.contentView.bounds;
		[self.contentView addSubview: newController.view];
		[self addChildViewController: newController];
		
		addObservers();
	} else {
		[self transitionFromViewController: oldController toViewController: newController duration: (1./3.) options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionCrossDissolve animations:^{} completion:^(BOOL finished) {
			[oldController removeFromParentViewController];
			
			addObservers();
		}];
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

- (BOOL)isVisible {
	return !!self.view.superview;
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

#pragma mark - Actions

- (IBAction)present {
	[self presentWithCompletion: NULL];
}

- (void)dismiss {
	[self dismissWithCompletion: NULL];
}

- (void)presentWithCompletion:(void (^)(void))block {
	self.oldKeyWindow = [[UIApplication sharedApplication] keyWindow];
	[[DZPopupController findFirstResponder: self.oldKeyWindow] resignFirstResponder];

	UIWindow *window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	window.backgroundColor = [UIColor clearColor];
	window.windowLevel = 5;
	window.rootViewController = self;
	[window makeKeyAndVisible];
	self.window = window;
    
    [self performAnimationWithStyle: self.entranceStyle entering: YES duration: (1./3.) completion: block];
}

- (void)dismissWithCompletion:(void (^)(void))block {
	_dismissingViaOurMethod = YES;
	
	[self.oldKeyWindow makeKeyWindow];

    [self performAnimationWithStyle: self.exitStyle entering: NO duration: (1./3.) completion: ^{
		if (self.presentingViewController) {
			[self.presentingViewController dismissViewControllerAnimated: NO completion: ^{
				_dismissingViaOurMethod = NO;

				if ([self.delegate respondsToSelector:@selector(popupControllerDidDismissPopup:)]) {
					[self.delegate popupControllerDidDismissPopup:self];
				}

				if (block)
					block();
			}];
		} else {
			self.window = nil;

			_dismissingViaOurMethod = NO;

			if ([self.delegate respondsToSelector:@selector(popupControllerDidDismissPopup:)]) {
				[self.delegate popupControllerDidDismissPopup:self];
			}

			if (block)
				block();
		}
    }];
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

- (void)performAnimationWithStyle: (DZPopupTransitionStyle)style entering: (BOOL)entering duration: (NSTimeInterval)duration completion: (void(^)(void))block {
	UIView *frame = self.frameView;
	
    self.backgroundView.alpha = entering ? 0 : 1;
    
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut;
    UIViewAnimationOptions chainedOptions = options | UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionOverrideInheritedCurve;
    
    CGRect originalRect = frame.frame, modifiedRect = frame.frame;
    
    switch (style) {
        case DZPopupTransitionStylePop:	break;
        case DZPopupTransitionStyleSlideBottom:
            modifiedRect.origin.y = CGRectGetMaxY(self.view.bounds);
            break;
        case DZPopupTransitionStyleSlideTop:
            modifiedRect.origin.y = CGRectGetMinY(self.view.bounds) - CGRectGetHeight(modifiedRect);
            break;
        case DZPopupTransitionStyleSlideLeft:
            modifiedRect.origin.x = CGRectGetMinX(self.view.bounds) - CGRectGetWidth(modifiedRect);
            break;
        case DZPopupTransitionStyleSlideRight:
            modifiedRect.origin.x = CGRectGetMaxX(self.view.bounds);
            break;
    }
    
    frame.frame = entering ? modifiedRect : originalRect;

	BOOL isChainedAnimation = (entering && style == DZPopupTransitionStylePop);

	if (isChainedAnimation) {
		frame.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
	}
	
	[UIView animateWithDuration:duration delay:0.0 options:options animations:^{
		self.backgroundView.alpha = entering ? 1 : 0;
		
		if (style == DZPopupTransitionStylePop) {
			if (entering) {
				NSTimeInterval firstAnimDiff = MAX(duration - 0.25, 0);				
				[UIView animateWithDuration:0.25 delay:firstAnimDiff options:chainedOptions animations:^{
					frame.transform = CGAffineTransformMakeScale(1.1, 1.1);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.125 delay:0 options:chainedOptions animations:^{
						frame.transform = CGAffineTransformMakeScale(0.9, 0.9);
					} completion:^(BOOL finished) {
						[UIView animateWithDuration:0.125 delay:0 options:chainedOptions animations:^{
							frame.transform = CGAffineTransformIdentity;
						} completion:^(BOOL finished) {
							if (block) block();
						}];
					}];
				}];
			} else {
				frame.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
			}
		} else {
			frame.frame = entering ? originalRect : modifiedRect;
		}
	} completion:^(BOOL finished) {
		if (!isChainedAnimation && block) {
			block();
		}
	}];
}

+ (UIView *)findFirstResponder:(UIView *)view {
	if (view.isFirstResponder)
		return view;
	
	for (UIView *subView in view.subviews) {
		UIView *firstResponder = [self findFirstResponder:subView];
		
		if (firstResponder != nil) {
			return firstResponder;
		}
	}
	
	return nil;
}

@end
