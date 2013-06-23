//
//  DZPopupController.m
//  DZPopupController
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZPopupController.h"
#import "DZPopupController+Subclasses.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark Constants

/**
 Determined experimentally against iOS 6.1:
 
 - UIWindowLevelAlert = 1000
 - UIWindowLevelStatusBar = 2000
 - UIWindowLevelNormal = 0
 - Keyboard is arbitrarily above whatever the current key window level,
 iff window level < UIWindowLevelAlert. UIAlertView is not presented at
 UIWindowLevelAlert if it triggers a keyboard.
 - Keyboard window level == 1 when there's only one normal window
 - Keyboard window level == 10 when there's an HBAPopupController.
 */
const UIWindowLevel DZWindowLevelPopup = 5;
const UIWindowLevel DZWindowLevelHUD = 10;
const UIWindowLevel DZWindowLevelAlert = 15;

const CGFloat DZPopupControllerBorderRadius = 8.0f;

const NSTimeInterval DZPopupAnimationDuration = (1./3.);
const NSTimeInterval DZPopupPopEntranceAnimationDuration = 0.5;

#pragma mark - Helper functions;

#if DZPOPUP_HAS_7_SDK
extern BOOL DZPopupUIIsStark() {
    static dispatch_once_t onceToken;
    static BOOL isStark = NO;
    dispatch_once(&onceToken, ^{
		// https://developer.apple.com/library/prerelease/ios/documentation/UserExperience/Conceptual/TransitionGuide/SupportingEarlieriOS.html
		NSUInteger deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
        isStark = (deviceSystemMajorVersion >= 7);
    });
    return isStark;
}
#else
extern BOOL DZPopupUIIsStark() {
    return NO;
}
#endif

static inline CGFloat DZPopupControllerShadowPaddingForBorderRadius(CGFloat radius) {
	CGFloat shadowOffset = radius / 4;
	CGFloat shadowPad = 2 * (radius + (shadowOffset * 2));
	return shadowPad;
}

CGFloat DZPopupControllerShadowPadding(void) {
	return DZPopupControllerShadowPaddingForBorderRadius(DZPopupControllerBorderRadius);
}

static UIView *DZPopupFindFirstResponder(UIView *view) {
    if (view.isFirstResponder)
		return view;
    
    for (UIView *subview in view.subviews) {
		UIView *first = DZPopupFindFirstResponder(subview);
		
		if (first) {
			return first;
		}
	}
	
	return nil;
}

void DZPopupSetFrameDuringTransform(UIView *view, CGRect newFrame) {
	CGPoint newCenter;
	newCenter.x = CGRectGetMidX(newFrame);
	newCenter.y = CGRectGetMidY(newFrame);
	view.center = newCenter;
	
	CGRect newBounds;
	newBounds.origin = CGPointZero;
	newBounds.size = newFrame.size;
	view.bounds = newBounds;
}

#pragma mark - 

@interface DZPopupController ()

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, weak, readwrite) UIWindow *previousKeyWindow;
@property (nonatomic, weak, readwrite) UIControl *backgroundView;
@property (nonatomic, strong, readwrite) UIView *contentView;

@property (nonatomic) UIStatusBarStyle backupStatusBarStyle;
@property (nonatomic, getter = isDismissingViaCustomMethod) BOOL dismissingViaCustomMethod;

@end

@implementation DZPopupController

#pragma mark - Setup and teardown

- (id)initWithContentViewController:(UIViewController *)viewController {
	return [self initWithContentViewController:viewController windowLevel:DZWindowLevelPopup];
}

- (id)initWithContentViewController:(UIViewController *)viewController windowLevel:(UIWindowLevel)level {
	if (self = [super initWithNibName:nil bundle:nil]) {
		NSParameterAssert(viewController);
        
		self.contentViewController = viewController;
		self.windowLevel = level;
	}
	return self;
}

- (void)dealloc {
	self.contentViewController = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	CGFloat alpha = DZPopupUIIsStark() ? 0.3 : 0.6;
	
    UIControl *background = [[UIControl alloc] initWithFrame: self.view.bounds];
	background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	background.backgroundColor = [UIColor colorWithWhite:0.0 alpha:alpha];
	[self.view addSubview: background];
	self.backgroundView = background;
	
	CGRect contentRect = self.view.bounds;
	CGFloat statusBarHeight = self.statusBarHeight;
	contentRect.origin.y += statusBarHeight;
	contentRect.size.height -= statusBarHeight;
	
	UIView *content = [[UIView alloc] initWithFrame: self.view.bounds];
	content.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview: content];
	self.contentView = content;
	
#if DZPOPUP_HAS_7_SDK
	if (DZPopupUIIsStark()) {
		self.edgesForExtendedLayout = UIExtendedEdgeNone;
		self.automaticallyAdjustsScrollViewInsets = NO;
		self.extendedLayoutIncludesOpaqueBars = YES;
	}
#endif
	
	if (!self.contentViewController.view.superview)
		self.contentViewController = self.contentViewController;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	self.backupStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	[[UIApplication sharedApplication] setStatusBarStyle: [self preferredStatusBarStyle] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	if (self.presentingViewController) {
		[self performAnimationWithStyle:self.entranceStyle entering:YES delay:0 completion:NULL];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle: self.backupStatusBarStyle animated:YES];
	
	if (self.presentingViewController && !self.dismissingViaCustomMethod) {
		[self performAnimationWithStyle:self.exitStyle entering:NO delay:0 completion:^{
			if ([self.delegate respondsToSelector:@selector(popupControllerDidDismissPopup:)]) {
				[self.delegate popupControllerDidDismissPopup:self];
			}
		}];
	}
}

#pragma mark - iOS 6 rotation

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

#pragma mark - iOS 5 rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (self.presentingViewController)
		return NO;
    
	BOOL should = (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	
	if (self.contentViewController)
		should &= [self.contentViewController shouldAutorotateToInterfaceOrientation: interfaceOrientation];
	
	return should;
}

#pragma mark - Public methods

- (IBAction)present {
	[self presentWithCompletion: NULL];
}

- (void)dismiss {
	[self dismissWithCompletion: NULL];
}

- (void)presentAfterDelay:(NSTimeInterval)delay completion:(void(^)(void))block {
	if (self.isVisible) return;
	
	self.previousKeyWindow = [[UIApplication sharedApplication] keyWindow];
    [DZPopupFindFirstResponder(self.previousKeyWindow) resignFirstResponder];
	
	UIWindow *window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	window.backgroundColor = [UIColor clearColor];
	window.windowLevel = self.windowLevel;
	window.rootViewController = self;
	[window makeKeyAndVisible];
	self.window = window;
	
    [self performAnimationWithStyle:self.entranceStyle entering:YES delay:delay completion:block];
}

- (void)presentWithCompletion:(void (^)(void))block {
	[self presentAfterDelay:0 completion:block];
}

- (void)dismissWithCompletion:(void (^)(void))block {
	if (!self.isVisible) return;
	
	self.dismissingViaCustomMethod = YES;
	
	if (self.window.isKeyWindow) {
		[self.previousKeyWindow makeKeyWindow];
	} else {
		[self.window resignKeyWindow];
	}
	
	void (^completion)(void) = ^{
		self.dismissingViaCustomMethod = NO;
		
		if ([self.delegate respondsToSelector:@selector(popupControllerDidDismissPopup:)]) {
			[self.delegate popupControllerDidDismissPopup:self];
		}
		
		if (block)
			block();
	};
	
	[self performAnimationWithStyle:self.exitStyle entering:NO delay:0 completion:^{
		if (self.presentingViewController) {
			[self.presentingViewController dismissViewControllerAnimated: NO completion:completion];
		} else {
			self.window = nil;
            completion();
		}
    }];
}

#pragma mark - Transition methods

- (UIView *)contentViewForPerformingAnimation
{
    return self.contentView;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	if (!DZPopupUIIsStark()) {
		return UIStatusBarStyleBlackTranslucent;
	}
	return UIStatusBarStyleDefault;
}

- (void)performAnimationWithStyle:(DZPopupTransitionStyle)style
						 entering:(BOOL)entering
							delay:(NSTimeInterval)delay completion:(void(^)(void))block
{
	if (DZPopupUIIsStark() && style == DZPopupTransitionStylePop) style = DZPopupTransitionStyleZoom;
	const NSTimeInterval duration = [UIView areAnimationsEnabled] ? DZPopupAnimationDuration : 0;
	
	UIView *frame = [self contentViewForPerformingAnimation];
	UIView *background = self.backgroundView;
	
	void (^completion)(void) = NULL;
	if (DZPopupUIIsStark()) {
		completion = block;
	} else {
		frame.layer.shouldRasterize = YES;
		frame.layer.rasterizationScale = frame.window.screen.scale;
		
		completion = ^{
			frame.layer.shouldRasterize = NO;
			
			if (block) block();
		};
	}
    
	CGAffineTransform modified = CGAffineTransformIdentity;
	const CGFloat beginAlpha = entering ? 0 : 1, endAlpha = entering ? 1 : 0;
	CGFloat frameBeginAlpha = 1, frameEndAlpha = 1;

    switch (style) {
		case DZPopupTransitionStyleFade:
		case DZPopupTransitionStyleZoom: {
			if (style == DZPopupTransitionStyleZoom) {
				CGFloat scale = entering ? 1.1 : 0.85;
				modified = CGAffineTransformMakeScale(scale, scale);
			}
			frameBeginAlpha = beginAlpha;
			frameEndAlpha = endAlpha;
			break;
		}
        case DZPopupTransitionStylePop:
			modified = CGAffineTransformMakeScale(0.0001, 0.0001);
			break;
        case DZPopupTransitionStyleSlideBottom:
			modified = CGAffineTransformMakeTranslation(0, frame.bounds.size.height);
            break;
        case DZPopupTransitionStyleSlideTop:
			modified = CGAffineTransformMakeTranslation(0, -CGRectGetMidY(frame.bounds)-frame.center.y);
            break;
        case DZPopupTransitionStyleSlideLeft:
			modified = CGAffineTransformMakeTranslation(-CGRectGetMidX(frame.bounds)-frame.center.x, 0);
            break;
        case DZPopupTransitionStyleSlideRight:
			modified = CGAffineTransformMakeTranslation(frame.bounds.size.width, 0);
            break;
    }
	
	CGAffineTransform begin = entering ? modified : CGAffineTransformIdentity;
	CGAffineTransform end = entering ? CGAffineTransformIdentity : modified;
	
	frame.transform = begin;
	background.alpha = beginAlpha;
	frame.alpha = frameBeginAlpha;
    
    UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState;
    UIViewAnimationOptions chainedOptions = options | UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionOverrideInheritedCurve;
	
	__block BOOL isChained = NO;
	[UIView animateWithDuration:duration delay:delay options:options animations:^{
		background.alpha = endAlpha;
		frame.alpha = frameEndAlpha ;
		
		if (entering && style == DZPopupTransitionStylePop) {
			isChained = YES;
			
			const NSTimeInterval primary = DZPopupPopEntranceAnimationDuration / 2,
								 secondary = DZPopupPopEntranceAnimationDuration / 4;
			const NSTimeInterval popDelay = MAX(duration - primary - delay, 0);
			
			[UIView animateWithDuration:primary delay:popDelay options:chainedOptions animations:^{
				frame.transform = CGAffineTransformMakeScale(1.1, 1.1);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:secondary delay:0 options:chainedOptions animations:^{
					frame.transform = CGAffineTransformMakeScale(0.9, 0.9);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:secondary delay:0 options:chainedOptions animations:^{
						frame.transform = end;
					} completion:^(BOOL finished) {
						if (completion) completion();
					}];
				}];
			}];
		} else {
			frame.transform = end;
		}
	} completion:^(BOOL finished) {
		if (!isChained && completion) completion();
	}];
}

#pragma mark - Accessors

- (void)setContentViewController:(UIViewController *)newController {
	[self setContentViewController: newController animated: NO];
}

- (void)setContentViewController:(UIViewController *)newController animated:(BOOL)animated {
	UIViewController *oldController = self.contentViewController;
	
	if (oldController && oldController.view.superview) {
		if (!animated) {
			[oldController willMoveToParentViewController: nil];
			[oldController.view removeFromSuperview];
			[oldController removeFromParentViewController];
			oldController = nil;
		}
	}
	
	_contentViewController = newController;
	
	if (!newController || !self.isViewLoaded)
		return;
	
	const NSTimeInterval duration = DZPopupAnimationDuration;
	const UIViewAnimationOptions opts = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionCrossDissolve;
	
	void (^addView)(void) = ^{
		newController.view.frame = self.contentView.bounds;
		[self.contentView addSubview: newController.view];
	};
	
	void (^addChild)(BOOL) = ^(BOOL fin){
		[self addChildViewController: newController];
		[newController didMoveToParentViewController: self];
	};
	
	if (animated || !oldController) {
		[UIView transitionWithView:self.contentView duration:duration options:opts animations:addView completion:addChild];
	} else if (!animated || !oldController.view.superview) {
		addView();
		addChild(YES);
	} else {
		[self transitionFromViewController:oldController toViewController:newController duration:duration options:opts animations:^{} completion:^(BOOL finished) {
			[oldController removeFromParentViewController];
			[newController didMoveToParentViewController: self];
		}];
	}
}

- (void)setWindowLevel:(UIWindowLevel)windowLevel {
	_windowLevel = windowLevel;
	if (self.window)
		self.window.windowLevel = _windowLevel;
}

- (BOOL)isVisible
{
	return self.window || (self.presentingViewController && self.view.superview);
}

- (CGFloat)statusBarHeight {
	CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
	CGFloat statusBarHeight = statusBarFrame.size.height == self.view.bounds.size.width ?  statusBarFrame.size.width : statusBarFrame.size.height;
	return statusBarHeight;
}

@end
