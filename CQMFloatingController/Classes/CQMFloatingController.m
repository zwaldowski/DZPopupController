//
// CQMFloatingController.m
// Created by cocopon on 2011/05/19.
//
// Copyright (c) 2012 cocopon <cocopon@me.com>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "CQMFloatingController.h"
#import "CQMFloatingContentOverlayView.h"
#import "CQMFloatingFrameView.h"
#import "CQMPathUtilities.h"

#define kDefaultMaskColor  [UIColor colorWithWhite:0 alpha:0.5]
#define kDefaultFrameColor [UIColor colorWithRed:0.10f green:0.12f blue:0.16f alpha:1.00f]
#define kDefaultFrameSize  CGSizeMake(320 - 66, 460 - 66)
#define kFramePadding      5.0f
#define kRootKey           @"root"
#define kAnimationDuration 0.3f


@interface CQMFloatingController()

@property (nonatomic, weak) CQMFloatingFrameView *frameView;
@property (nonatomic, readonly, strong) UIView *contentView;
@property (nonatomic, weak) CQMFloatingContentOverlayView *contentOverlayView;
@property (nonatomic, strong) UIImageView *shadowView;

@end

@implementation CQMFloatingController

@synthesize frameView, contentView = contentView_, contentOverlayView = _contentOverlayView, contentViewController = contentViewController_, shadowView = shadowView_, frameSize = _frameSize, frameColor = _frameColor;

- (id)init {
	if (self = [super init]) {
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			UIImage *blank = CQMCreateBlankImage();
			id navigationBarAppearance = [UINavigationBar appearanceWhenContainedIn: [self class], nil];
			id toolbarAppearance = [UIToolbar appearanceWhenContainedIn: [self class], nil];
			[navigationBarAppearance setBarStyle: UIBarStyleBlack];
			[navigationBarAppearance setBackgroundImage: blank forBarMetrics: UIBarMetricsDefault];
			[navigationBarAppearance setBackgroundImage: blank forBarMetrics: UIBarMetricsLandscapePhone];
			[toolbarAppearance setBarStyle: UIBarStyleBlack];
			[toolbarAppearance setBackgroundImage: blank forToolbarPosition: UIToolbarPositionAny barMetrics: UIBarMetricsDefault];
			[toolbarAppearance setBackgroundImage: blank forToolbarPosition: UIToolbarPositionAny barMetrics: UIBarMetricsLandscapePhone];
		});
		_frameSize = kDefaultFrameSize;
		[self setFrameColor:kDefaultFrameColor];
	}
	return self;
}




#pragma mark -
#pragma mark Property


- (void)setFrameSize:(CGSize)frameSize {
	if (!CGSizeEqualToSize(_frameSize, frameSize)) {
		_frameSize = frameSize;
		
		if (self.isViewLoaded) {
			CGRect frame = self.frameView.frame;
			frame.size = frameSize;
			self.frameView.frame = frame;
		}
	}
}

- (void)setFrameColor:(UIColor*)frameColor {
	if (![_frameColor isEqual: frameColor]) {
		_frameColor = frameColor;
		
		if (self.isViewLoaded) {
			[self.frameView setBaseColor:frameColor];
			[self.frameView setNeedsDisplay];
			[self.contentOverlayView setEdgeColor:frameColor];
			[self.contentOverlayView setNeedsDisplay];
		}
	}
}

- (UIView*)contentView {
	if (contentView_ == nil) {
		contentView_ = [[UIView alloc] init];
		contentView_.clipsToBounds = YES;
		contentView_.layer.cornerRadius = 5.0f;
		contentView_.layer.masksToBounds = YES;
	}
	return contentView_;
}

- (void)setContentViewController:(UIViewController *)newController {
	UIViewController *oldController = self.contentViewController;
	if (oldController) {
		[oldController willMoveToParentViewController: nil];
		[oldController.view removeFromSuperview];
		[oldController removeFromParentViewController];
	}
	
	contentViewController_ = newController;
	
	if (newController) {
		newController.view.frame = self.contentView.bounds;
		newController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview: newController.view];
		[self addChildViewController: newController];
		[newController didMoveToParentViewController: self];
	}
}

- (void)setContentViewController:(UIViewController *)newController animated:(BOOL)animated {
	if (!animated)
		[self setContentViewController: newController];
	
	UIViewController *oldController = self.contentViewController;
	
	if (!oldController) {
		[UIView transitionWithView: newController.view duration: (1./3.) options: UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionCrossDissolve animations:^{
			newController.view.frame = self.contentView.bounds;
			newController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[self.contentView addSubview: newController.view];
		} completion:^(BOOL finished) {
			[self addChildViewController: newController];
			[newController didMoveToParentViewController: self];
		}];
		return;
	} else {
		[self transitionFromViewController: oldController toViewController: newController duration: (1./3.) options: UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionCrossDissolve animations:^{} completion:^(BOOL finished) {
			[oldController removeFromParentViewController];
			[newController didMoveToParentViewController: self];
		}];
	}
	
	contentViewController_ = newController;
}

#pragma mark -

static char windowRetainCycle;

- (void)presentWithContentViewController:(UIViewController*)viewController animated:(BOOL)animated {
	[self.view setAlpha:0];
	
	self.contentViewController = viewController;
	
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	[self.view setFrame:[window convertRect:appFrame fromView:nil]];
	[window addSubview:[self view]];
	objc_setAssociatedObject(window, &windowRetainCycle, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	__weak CQMFloatingController *me = self;
	[UIView animateWithDuration:(animated ? kAnimationDuration : 0)
					 animations:
	 ^{
		 [me.view setAlpha:1.0f];
	 }];
}


- (void)dismissAnimated:(BOOL)animated {
	[UIView animateWithDuration: (animated ? kAnimationDuration : 0)
					 animations: ^{
		[self.view setAlpha:0];
	 } completion: ^(BOOL finished){
		 if (!finished)
			 return;
		 
		 UIWindow *window = self.view.window;
		[self.view removeFromSuperview];
		objc_setAssociatedObject(window, &windowRetainCycle, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	 }];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLayoutSubviews {
	// Content
	UIView *contentView = [self contentView];
	CGSize contentSize = CGSizeMake(self.frameView.frame.size.width - kFramePadding * 2,
									self.frameView.frame.size.height - kFramePadding * 2);
	[contentView setFrame: (CGRect){{kFramePadding, kFramePadding}, contentSize}];
	
	
	// Navigation	
	CGFloat navBarHeight = 0.0, toolbarHeight = 0.0;
	if ([self.contentViewController isKindOfClass: [UINavigationController class]]) {
		UINavigationController *navigationController = (id)self.contentViewController;
		navBarHeight = navigationController.navigationBar.frame.size.height;
		if (!navigationController.toolbarHidden && navigationController.topViewController.toolbarItems.count)
			toolbarHeight = navigationController.toolbar.frame.size.height;
	}
	
	// Content overlay
	UIView *contentOverlay = self.contentOverlayView;
	CGFloat contentFrameWidth = [[contentOverlay class] frameWidth];
	[contentOverlay setFrame:CGRectMake(kFramePadding - contentFrameWidth,
										kFramePadding - contentFrameWidth + navBarHeight ,
										contentSize.width  + contentFrameWidth * 2,
										contentSize.height - navBarHeight - toolbarHeight + contentFrameWidth * 2)];
	[contentOverlay.superview bringSubviewToFront:contentOverlay];
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = kDefaultMaskColor;
	
	CQMFloatingFrameView *frame = [[CQMFloatingFrameView alloc] initWithFrame: CGRectMake(ceil((CGRectGetWidth(self.view.frame) - _frameSize.width) / 2), ceil((CGRectGetHeight(self.view.frame) - _frameSize.height) / 2), _frameSize.width, _frameSize.height)];
	[self.view addSubview: frame];
	self.frameView = frame;
	
	[self.frameView addSubview:[self contentView]];
	
	CQMFloatingContentOverlayView *overlay = [[CQMFloatingContentOverlayView alloc] initWithFrame: CGRectZero];
	[frame addSubview: overlay];
	self.contentOverlayView = overlay;
}


@end
