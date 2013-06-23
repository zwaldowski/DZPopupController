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

const NSTimeInterval DZPopupAnimationDuration = (1./3.);

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

@interface DZPopupController ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak, readwrite) UIWindow *previousKeyWindow;
@property (nonatomic, strong, readwrite) UIView *contentView;
@property (nonatomic, weak, readwrite) UIControl *backgroundView;
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
	
    UIControl *background = [[UIControl alloc] initWithFrame: self.view.bounds];
	background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	background.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
	[self.view addSubview: background];
	self.backgroundView = background;
	
	UIView *content = [[UIView alloc] initWithFrame: self.view.bounds];
	content.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview: content];
	self.contentView = content;
	
	if (!self.contentViewController.view.superview)
		self.contentViewController = self.contentViewController;
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
	
	if (self.presentingViewController && !self.dismissingViaCustomMethod) {
		[self performAnimationWithStyle: self.exitStyle entering: NO duration: animated ? (1./3.) : 0 completion:^{
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

- (void)presentWithCompletion:(void (^)(void))block {
	self.previousKeyWindow = [[UIApplication sharedApplication] keyWindow];
    [DZPopupFindFirstResponder(self.previousKeyWindow) resignFirstResponder];
    
	UIWindow *window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
	window.backgroundColor = [UIColor clearColor];
	window.windowLevel = self.windowLevel;
	window.rootViewController = self;
	[window makeKeyAndVisible];
	self.window = window;
    
    [self performAnimationWithStyle: self.entranceStyle entering: YES duration: (1./3.) completion: block];
}

- (void)dismissWithCompletion:(void (^)(void))block {
	self.dismissingViaCustomMethod = YES;
	
	[self.previousKeyWindow makeKeyWindow];
    
    [self performAnimationWithStyle: self.exitStyle entering: NO duration: (1./3.) completion: ^{
		if (self.presentingViewController) {
			[self.presentingViewController dismissViewControllerAnimated: NO completion: ^{
				self.dismissingViaCustomMethod = NO;
                
				if ([self.delegate respondsToSelector:@selector(popupControllerDidDismissPopup:)]) {
					[self.delegate popupControllerDidDismissPopup:self];
				}
                
				if (block)
					block();
			}];
		} else {
			self.window = nil;
            
			self.dismissingViaCustomMethod = NO;
            
			if ([self.delegate respondsToSelector:@selector(popupControllerDidDismissPopup:)]) {
				[self.delegate popupControllerDidDismissPopup:self];
			}
            
			if (block)
				block();
		}
    }];
}

#pragma mark - Transition methods

- (UIView *)contentViewForPerformingAnimation
{
    return self.contentView;
}

- (void)performAnimationWithStyle: (DZPopupTransitionStyle)style entering: (BOOL)entering duration: (NSTimeInterval)duration completion: (void(^)(void))block {
	UIView *frame = [self contentViewForPerformingAnimation];
	
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
	self.contentView.layer.shouldRasterize = YES;
	self.contentView.layer.rasterizationScale = frame.window.screen.scale;
	
	void (^completion)(void) = ^{
		self.contentView.layer.shouldRasterize = NO;
		self.contentView.layer.rasterizationScale = frame.window.screen.scale;
		
		if (block) block();
	};
    
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
							completion();
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
		if (!isChainedAnimation) completion();
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
		}
	}
	
	_contentViewController = newController;
	
	if (!newController || !self.isViewLoaded)
		return;
	
	if (!oldController) {
		[UIView transitionWithView: self.contentView duration: (1./3.) options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionCrossDissolve animations:^{
			newController.view.frame = self.contentView.bounds;
			[self.contentView addSubview: newController.view];
		} completion:^(BOOL finished) {
			[self addChildViewController: newController];
			[newController didMoveToParentViewController: self];
		}];
	} else if (!oldController.view.superview) {
		newController.view.frame = self.contentView.bounds;
		[self.contentView addSubview: newController.view];
		[self addChildViewController: newController];
		[newController didMoveToParentViewController: self];
	} else {
		[self transitionFromViewController: oldController toViewController: newController duration: (1./3.) options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionCrossDissolve animations:^{} completion:^(BOOL finished) {
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

- (BOOL)isVisible {
	return !!self.view.superview;
}


@end
