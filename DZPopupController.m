//
//  DZPopupController.m
//  DZPopupControllerDemo
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
@property (nonatomic, weak) UIControl *backgroundView;
@property (nonatomic, weak) DZPopupControllerFrameView *frameView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) DZPopupControllerInsetView *insetView;
@property (nonatomic) UIStatusBarStyle backupStatusBarStyle;

@end

@implementation DZPopupController

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

	DZPopupControllerFrameView *frame = [[DZPopupControllerFrameView alloc] initWithFrame: UIEdgeInsetsInsetRect(self.view.bounds, _frameEdgeInsets)];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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
	toolbarHeight = navigationController.toolbarHidden ? 0.0 : navigationController.toolbar.frame.size.height;
	

	if (self.insetView) {
		CGRect cFrame = self.contentView.frame;
		self.insetView.frame = CGRectMake(CGRectGetMinX(cFrame), CGRectGetMinY(cFrame) + navBarHeight - 2, CGRectGetWidth(cFrame), CGRectGetHeight(cFrame) - navBarHeight - toolbarHeight + 4.0f);
	}
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
			
			navigationController.toolbar.clipsToBounds = YES;
			navigationController.navigationBar.clipsToBounds = YES;
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
		[navigationBarAppearance setTintColor: frameColor];
		[toolbarAppearance setBackgroundColor: frameColor];
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
	self.contentView.frame = CGRectInset(self.contentView.frame, 2.0f, 2.0f);
	self.contentView.layer.cornerRadius = 7.0f;
	self.contentView.clipsToBounds = YES;

	id toolbarAppearance = [UIToolbar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
	[toolbarAppearance setBackgroundImage: UIGraphicsGetImageFromCurrentImageContext() forToolbarPosition: UIToolbarPositionAny barMetrics: UIBarMetricsDefault];
	UIGraphicsEndImageContext();
}

- (void)configureInsetView {
	if (self.frameView)
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
	NSUInteger closeIndex = [self.frameView.subviews indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [obj isKindOfClass: [DZPopupControllerCloseButton class]];
	}];

	if (closeIndex != NSNotFound)
		return;

	DZPopupControllerCloseButton *closeButton = [[DZPopupControllerCloseButton alloc] initWithFrame: CGRectMake(-9, -9, 24, 24)];
	closeButton.showsTouchWhenHighlighted = YES;
	[closeButton addTarget: self action:@selector(closePressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.frameView addSubview: closeButton];
}

#pragma mark - Actions

- (IBAction)present {
	[self presentWithCompletion: NULL];
}

- (void)dismiss {
	[self dismissWithCompletion: NULL];
}

- (void)presentWithCompletion:(void (^)(void))block {
	CGRect appBounds = [[UIScreen mainScreen] applicationFrame];
	appBounds.origin = CGPointZero;

	UIWindow *window = [[UIWindow alloc] initWithFrame:appBounds];
	window.backgroundColor = [UIColor clearColor];
	window.windowLevel = UIWindowLevelAlert;
	window.rootViewController = self;
	[window makeKeyAndVisible];
	self.window = window;
	
	self.backupStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackTranslucent animated:YES];
    
    [self performAnimationWithStyle: self.entranceStyle entering: YES duration: (1./3.) completion: block];
}

- (void)dismissWithCompletion:(void (^)(void))block {
	[[UIApplication sharedApplication] setStatusBarStyle: self.backupStatusBarStyle animated:YES];
    
    [self performAnimationWithStyle: self.exitStyle entering: NO duration: (1./3.) completion: ^{
		if (block)
			block();
		
		self.window.rootViewController = nil;
		self.window = nil;
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
    self.backgroundView.alpha = entering ? 0 : 1;
    
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent;
    
    CGRect originalRect = self.frameView.frame;
    CGRect modifiedRect = self.frameView.frame;
    
    switch (style) {
        case DZPopupTransitionStylePop:
            break;
            
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
    
    self.frameView.frame = entering ? modifiedRect : originalRect;
    
    [UIView transitionWithView: self.frameView duration: duration options: options animations: ^{
        self.backgroundView.alpha = entering ? 1 : 0;
        self.frameView.frame = entering ? originalRect : modifiedRect;;
        
        switch (style) {
            case DZPopupTransitionStylePop:
                if (entering) {
                    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
                    scale.duration = 2 * duration;
                    scale.keyTimes = @[@0.0, @0.5, @(2.0f/3.0f), @(5.0f/6.0f), @1.0];
                    scale.values = @[@0.00001f, @1.05f, @0.95f, @1.02f, @1.00f];
                    [self.frameView.layer addAnimation:scale forKey: nil];
                } else {
                    self.frameView.transform = CGAffineTransformScale(self.frameView.transform, 0.00001, 0.00001);
                }
                break;
                
            case DZPopupTransitionStyleSlideBottom:
            case DZPopupTransitionStyleSlideTop:
            case DZPopupTransitionStyleSlideLeft:
            case DZPopupTransitionStyleSlideRight:
                break;
        }
    } completion:^(BOOL finished) {
        if (block)
            block();
    }];
    
    
}

@end
