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
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) CQMFloatingContentOverlayView *contentOverlayView;
@property (nonatomic, strong) UIImageView *shadowView;

@end

@implementation CQMFloatingController

@synthesize frameView, contentView = contentView_, contentOverlayView = _contentOverlayView, contentViewController = contentViewController_, shadowView = shadowView_, frameSize = _frameSize, frameColor = _frameColor;

- (id)initWithContentViewController:(UIViewController *)viewController {
	if (self = [super initWithNibName:nil bundle:nil]) {
		NSParameterAssert(viewController);
		
		contentViewController_ = viewController;
		
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
		_frameColor = kDefaultFrameColor;
		[self setFrameColor:kDefaultFrameColor];
		
		self.view.backgroundColor = kDefaultMaskColor;
		
		CQMFloatingFrameView *frame = [[CQMFloatingFrameView alloc] initWithFrame: CGRectMake(ceil((CGRectGetWidth(self.view.frame) - _frameSize.width) / 2), ceil((CGRectGetHeight(self.view.frame) - _frameSize.height) / 2), _frameSize.width, _frameSize.height)];
		frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		frame.baseColor = _frameColor;
		[self.view addSubview: frame];
		self.frameView = frame;
		
		UIView *content = [UIView new];
		content.clipsToBounds = YES;
		content.layer.cornerRadius = 5.0f;
		content.layer.masksToBounds = YES;
		[frame addSubview: content];
		self.contentView = content;
		
		viewController.view.frame = self.contentView.bounds;
		viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[content addSubview: viewController.view];
		[self addChildViewController: viewController];
		[viewController didMoveToParentViewController: self];
		
		CQMFloatingContentOverlayView *overlay = [[CQMFloatingContentOverlayView alloc] init];
		[self.contentOverlayView setEdgeColor: _frameColor];
		[frame addSubview: overlay];
		self.contentOverlayView = overlay;
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

#pragma mark -

static char windowRetainCycle;

- (void)show {
	self.view.alpha = 0.0f;
	
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	[self.view setFrame:[window convertRect:appFrame fromView:nil]];
	[window addSubview:[self view]];
	
	objc_setAssociatedObject(window, &windowRetainCycle, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	[UIView animateWithDuration: kAnimationDuration animations: ^{
		 self.view.alpha = 1.0f;
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
	
}

@end
