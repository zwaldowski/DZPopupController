//
//  DZPopupController.m
//  DZPopupControllerDemo
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZPopupController.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark -

@interface DZPopupControllerFrameView : UIView

@property (nonatomic, strong) UIColor *baseColor;
@property (nonatomic) BOOL drawsBottomHighlight;
@property (nonatomic) UIBarMetrics barMetrics;

@end

@implementation DZPopupControllerFrameView {
	CGGradientRef _topGradient;
	CGGradientRef _bottomGradient;
}

@synthesize baseColor = _baseColor;
@synthesize drawsBottomHighlight = _drawsBottomHighlight;
@synthesize barMetrics = _barMetrics;

- (void)dealloc {
	if (_topGradient)
		CGGradientRelease(_topGradient); _topGradient = nil;
	if (_bottomGradient)
		CGGradientRelease(_bottomGradient); _bottomGradient = nil;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	const CGFloat radius = 8.0f;
	
	// Create gradients
	if (!_topGradient || !_bottomGradient) {
		CGColorRef startHighlight = [[UIColor colorWithWhite:1.00f alpha:0.40f] CGColor];
		CGColorRef endHighlight = [[UIColor colorWithWhite:1.00f alpha:0.05f] CGColor];
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		
		CFArrayRef topColors = (__bridge_retained CFArrayRef)[NSArray arrayWithObjects:
														   (__bridge id)startHighlight,
														   (__bridge id)endHighlight,
														   nil];
		CGFloat topLocations[] = {0, 1.0f};
		_topGradient = CGGradientCreateWithColors(colorSpace, topColors, topLocations);
		CFRelease(topColors);
		
		CFArrayRef bottomColors = (__bridge_retained CFArrayRef)[NSArray arrayWithObjects:
												(id)[[UIColor clearColor] CGColor],
												(__bridge id)startHighlight,
												(__bridge id)endHighlight,
												nil];
		CGFloat bottomLocations[] = {0, 0.20f, 1.0f};
		_bottomGradient = CGGradientCreateWithColors(colorSpace, bottomColors, bottomLocations);
		CFRelease(bottomColors);
		
		CGColorSpaceRelease(colorSpace);
	}
	
	// Shadow location
	self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect: self.bounds cornerRadius: 8.0f] CGPath];
	
	// Light border
	[[UIColor colorWithWhite:1.00f alpha:0.10f] setFill];
	[[UIBezierPath bezierPathWithRoundedRect: self.bounds cornerRadius: radius + 1.0f] fill];
	
	// Base
	[self.baseColor setFill];
	[[UIBezierPath bezierPathWithRoundedRect: CGRectInset(self.bounds, 1.0f, 1.0f) cornerRadius: radius] fill];
	
	// Highlight
	CGContextSaveGState(context);
	CGFloat topHighlightHeight = self.barMetrics == UIBarMetricsDefault ? 26.0f : 21.0f;
	CGRect highlightRect = CGRectMake(2.0f, 2.0f, CGRectGetWidth(rect) - 4.0f, topHighlightHeight);
	CGSize highlightRadii = CGSizeMake(radius - 1.0f, radius - 1.0f);
	
	[[UIBezierPath bezierPathWithRoundedRect: highlightRect byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: highlightRadii] addClip];
	CGContextDrawLinearGradient(context, _topGradient, CGPointMake(0, 2.0f), CGPointMake(0, topHighlightHeight), 0);
	
	CGContextRestoreGState(context);
	
	if (self.drawsBottomHighlight) {
		CGContextSaveGState(context);
		
		CGFloat bottomHighlightHeight = self.barMetrics == UIBarMetricsDefault ? 28.0f : 20.0f;
		CGRect bottomHighlightRect = CGRectMake(4.0f, CGRectGetMaxY(rect) - bottomHighlightHeight * 2, CGRectGetWidth(rect) - 8.0f, bottomHighlightHeight);
		
		[[UIBezierPath bezierPathWithRect: bottomHighlightRect] addClip];
		CGContextDrawLinearGradient(context, _bottomGradient, CGPointMake(2.0f, CGRectGetMinY(bottomHighlightRect)), CGPointMake(2.0f, CGRectGetMaxY(bottomHighlightRect)), 0);
		CGContextRestoreGState(context);
	}
}

@end

#pragma mark -

@interface DZPopupControllerInsetView : UIView

@property (nonatomic, strong) UIColor *baseColor;
@property (nonatomic) UIRectCorner filledCorners;

@end

@implementation DZPopupControllerInsetView

@synthesize baseColor = _baseColor;
@synthesize filledCorners = _filledCorners;

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	const CGFloat radius = self.layer.cornerRadius;
	const CGFloat frameWidth = 3.0f;
	
	UIBezierPath *outerRect = [UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, frameWidth - 3, frameWidth - 3) byRoundingCorners: self.filledCorners cornerRadii: CGSizeMake(radius+3, radius+3)];
	UIBezierPath *innerRect = [UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, frameWidth, frameWidth) cornerRadius: radius];
	UIBezierPath *fillRect = [outerRect copy];
	[fillRect appendPath: innerRect];
	[fillRect setUsesEvenOddFillRule: YES];
	
	CGContextSaveGState(context);
	
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1), radius, [[UIColor colorWithWhite:0 alpha:0.8f] CGColor]);
	
	[outerRect addClip];
	[self.baseColor setFill];
	[fillRect fill];
	
	CGContextRestoreGState(context);
}

@end

#pragma mark -

@interface DZPopupControllerCloseButton : UIButton

@end

@implementation DZPopupControllerCloseButton

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextFillEllipseInRect(context, rect);
	
	CGFloat w = CGRectGetWidth(rect) - 4;
	CGAffineTransform xTransform = CGAffineTransformMakeScale(0.01 * w, 0.01 * w);
	CGAffineTransform translation = CGAffineTransformMakeTranslation(2, 2);
	[[UIColor whiteColor] setFill];
	
	UIBezierPath* leftCross = [UIBezierPath bezierPath];
	
	[leftCross moveToPoint: CGPointMake(25, 36)];
	[leftCross addCurveToPoint: CGPointMake(25, 25) controlPoint1: CGPointMake(22, 33) controlPoint2: CGPointMake(22, 28)];
	[leftCross addCurveToPoint: CGPointMake(36, 25) controlPoint1: CGPointMake(28, 22) controlPoint2: CGPointMake(33, 22)];
	[leftCross addLineToPoint: CGPointMake(75, 64)];
	[leftCross addCurveToPoint: CGPointMake(75, 75) controlPoint1: CGPointMake(78, 67) controlPoint2: CGPointMake(78, 72)];
	[leftCross addCurveToPoint: CGPointMake(64, 75) controlPoint1: CGPointMake(72, 78) controlPoint2: CGPointMake(67, 78)];
	[leftCross addLineToPoint: CGPointMake(25, 36)];
	[leftCross closePath];
	
	UIBezierPath* rightCross = [UIBezierPath bezierPath];
	
	[rightCross moveToPoint: CGPointMake(75, 36)];
	[rightCross addCurveToPoint: CGPointMake(75, 25) controlPoint1: CGPointMake(78, 33) controlPoint2: CGPointMake(78, 28)];
	[rightCross addCurveToPoint: CGPointMake(64, 25) controlPoint1: CGPointMake(72, 22) controlPoint2: CGPointMake(67, 22)];
	[rightCross addLineToPoint: CGPointMake(25, 64)];
	[rightCross addCurveToPoint: CGPointMake(25, 75) controlPoint1: CGPointMake(22, 67) controlPoint2: CGPointMake(22, 72)];
	[rightCross addCurveToPoint: CGPointMake(36, 75) controlPoint1: CGPointMake(28, 78) controlPoint2: CGPointMake(33, 78)];
	[rightCross addLineToPoint: CGPointMake(75, 36)];
	[rightCross closePath];
	
	[leftCross applyTransform:xTransform];
	[rightCross applyTransform:xTransform];
	
	[leftCross applyTransform:translation];
	[rightCross applyTransform:translation];
	
	[leftCross fill];
	[rightCross fill];
}

@end

#pragma mark -

static inline UIImage *CQMCreateBlankImage(void) {
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
	UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return ret;
}

@interface DZPopupController ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) DZPopupControllerFrameView *frameView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) DZPopupControllerInsetView *contentOverlayView;
@property (nonatomic) UIStatusBarStyle backupStatusBarStyle;

- (void)resizeContentOverlay;

@end

@implementation DZPopupController

@synthesize window = _window;
@synthesize contentViewController = _contentViewController;
@synthesize frameView = _frameView;
@synthesize contentView = _contentView;
@synthesize contentOverlayView = _contentOverlayView;
@synthesize frameSize = _frameSize;
@synthesize frameColor = _frameColor;
@synthesize backupStatusBarStyle = _backupStatusBarStyle;

#pragma mark - Setup and teardown

- (id)initWithContentViewController:(UIViewController *)viewController {
	if (self = [super initWithNibName:nil bundle:nil]) {
		NSParameterAssert(viewController);
		
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

		_frameColor = [UIColor colorWithRed:0.10f green:0.12f blue:0.16f alpha:1.00f];
		_frameSize = CGSizeMake(254, 394);
		
		UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		window.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		window.windowLevel = UIWindowLevelAlert;
		window.userInteractionEnabled = NO;
		window.hidden = YES;
		self.window = window;
		
		self.contentViewController = viewController;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
		
	CGFloat insetX = floor(CGRectGetMidX(self.view.bounds) - _frameSize.width / 2), insetY = floor(CGRectGetMidY(self.view.bounds) - _frameSize.height / 2);
	DZPopupControllerFrameView *frame = [[DZPopupControllerFrameView alloc] initWithFrame: CGRectInset(self.view.bounds, insetX, insetY)];
	frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	frame.backgroundColor = [UIColor clearColor];
	frame.contentMode = UIViewContentModeRedraw;
	frame.layer.cornerRadius = 8.0f;
	frame.layer.shadowOffset = CGSizeMake(0, 2);
	frame.layer.shadowOpacity = 0.7f;
	frame.layer.shadowRadius = 10.0f;
	frame.baseColor = _frameColor;
	[self.view addSubview: frame];
	self.frameView = frame;
	
	UIView *contentContainer = [[UIView alloc] initWithFrame: frame.bounds];
	contentContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	contentContainer.clipsToBounds = YES;
	contentContainer.layer.cornerRadius = 8.0f;
	contentContainer.layer.masksToBounds = 8.0f;
	[frame addSubview: contentContainer];
	
	// Content
	UIView *content = [[UIView alloc] initWithFrame: CGRectInset(frame.bounds, 5.0f, 5.0f)];
	content.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[contentContainer addSubview: content];
	self.contentView = content;
	
	DZPopupControllerInsetView *overlay = [[DZPopupControllerInsetView alloc] initWithFrame: content.bounds];
	overlay.backgroundColor = [UIColor clearColor];
	overlay.contentMode = UIViewContentModeRedraw;
	overlay.userInteractionEnabled = NO;
	overlay.layer.cornerRadius = 5.0f;
	overlay.baseColor = _frameColor;
	[contentContainer addSubview: overlay];
	self.contentOverlayView = overlay;
	
	UIButton *closeButton = [DZPopupControllerCloseButton buttonWithType: UIButtonTypeCustom];
	closeButton.frame = CGRectMake(-8, -8, 22, 22);
	[closeButton addTarget: self action:@selector(closePressed:) forControlEvents:UIControlEventTouchUpInside];
	closeButton.layer.borderColor = [[UIColor whiteColor] CGColor];
	closeButton.layer.borderWidth = 2.0f;
	closeButton.layer.shadowColor = [[UIColor blackColor] CGColor];
	closeButton.layer.shadowOffset = CGSizeMake(0,4);
	closeButton.layer.shadowOpacity = 0.3;
	closeButton.layer.cornerRadius = 11.0f;
	closeButton.backgroundColor = [UIColor clearColor];
	closeButton.showsTouchWhenHighlighted = YES;
	[frame addSubview: closeButton];
	
	if (!_contentViewController.view.superview)
		self.contentViewController = _contentViewController;
}

- (void)dealloc {
	self.contentViewController = nil;
}

#pragma mark - UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	self.frameView.barMetrics = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? UIBarMetricsLandscapePhone : UIBarMetricsDefault;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	[self resizeContentOverlay];
}

#pragma mark - Properties

- (UIViewController *)contentViewController {
	return _contentViewController;
}

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
			
			self.frameView.drawsBottomHighlight = (!navigationController.toolbarHidden);
		} else {
			self.frameView.drawsBottomHighlight = NO;
		}
		
		[self.frameView setNeedsDisplay];
		[self resizeContentOverlay];
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

- (void)setFrameSize:(CGSize)frameSize {
	[self setFrameSize: frameSize animated: NO];
}

- (void)setFrameSize:(CGSize)frameSize animated:(BOOL)animated {
	if (CGSizeEqualToSize(_frameSize, frameSize))
		return;
	
	_frameSize = frameSize;
	
	if (!self.isViewLoaded)
		return;
	
	[UIView animateWithDuration: animated ? 1./3. : 0 delay: 0 options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews animations: ^{
		CGFloat insetX = floor(CGRectGetMidX(self.view.bounds) - _frameSize.width / 2), insetY = floor(CGRectGetMidY(self.view.bounds) - _frameSize.height / 2);
		self.frameView.frame = CGRectInset(self.view.bounds, insetX, insetY);
	} completion: NULL];
}

- (void)setFrameColor:(UIColor*)frameColor {
	[self setFrameColor: frameColor animated: NO];
}

- (void)setFrameColor:(UIColor*)frameColor animated:(BOOL)animated {
	if ([_frameColor isEqual: frameColor])
		return;
	
	_frameColor = frameColor;
	
	[UIView transitionWithView: self.frameView duration: animated ? 1./3. : 0 options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations: ^{
		self.frameView.baseColor = _frameColor;
		self.contentOverlayView.baseColor = _frameColor;
		[self.frameView setNeedsDisplay];
		[self.contentOverlayView setNeedsDisplay];
	} completion: NULL];
}

- (BOOL)isVisible {
	return !!self.view.superview;
}

#pragma mark - Actions

- (IBAction)present {
	[self presentWithCompletion: NULL];
}

- (void)dismiss {
	[self dismissWithCompletion: NULL];
}

- (void)presentWithCompletion:(void (^)(void))block {
	self.window.rootViewController = self;
	self.view.userInteractionEnabled = NO;
	
	self.window.hidden = NO;
	self.window.userInteractionEnabled = YES;
	
	self.backupStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackTranslucent animated:YES];
	
	CABasicAnimation *alpha = [CABasicAnimation animationWithKeyPath:@"opacity"];
	alpha.fromValue = [NSNumber numberWithDouble:0.0];
	alpha.toValue = [NSNumber numberWithDouble:1.0];
	alpha.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
	alpha.duration = (1./3.);
	
	CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	scale.duration = 0.7f;
	scale.keyTimes = [NSArray arrayWithObjects:
					  [NSNumber numberWithDouble:0.0],
					  [NSNumber numberWithDouble:0.5],
					  [NSNumber numberWithDouble:(2.0f/3.0f)],
					  [NSNumber numberWithDouble:(5.0f/6.0f)],
					  [NSNumber numberWithDouble:1.0f],
					  nil];
	scale.values = [NSArray arrayWithObjects:
					[NSNumber numberWithFloat:0.00001],
					[NSNumber numberWithFloat:1.05],
					[NSNumber numberWithFloat:0.95],
					[NSNumber numberWithFloat:1.02],
					[NSNumber numberWithFloat:1.00],
					nil];
	
	CAMediaTimingFunction *easeIn = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
	CAMediaTimingFunction *easeOut = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseOut];
	scale.timingFunctions = [NSArray arrayWithObjects: easeIn, easeOut, easeIn, easeOut, nil];
	
	[CATransaction begin];
	[CATransaction setCompletionBlock: ^{
		[self.window makeKeyAndVisible];
		
		self.view.userInteractionEnabled = YES;
		
		if (block)
			block();
	}];
	[self.window.layer addAnimation:alpha forKey: nil];
	[self.view.layer addAnimation:scale forKey: nil];
	[CATransaction commit];
}

- (void)dismissWithCompletion:(void (^)(void))block {
	self.view.userInteractionEnabled = NO;
	
	[[UIApplication sharedApplication] setStatusBarStyle: self.backupStatusBarStyle animated:YES];
	
	[UIView animateWithDuration: (1./3.) delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent animations:^{
		self.window.alpha = 0.0001;
		self.view.transform = CGAffineTransformScale(self.view.transform, 0.00001, 0.00001);
	} completion:^(BOOL finished) {
		if (block)
			block();
		
		self.view.userInteractionEnabled = YES;
		self.window.hidden = YES;
		self.window.userInteractionEnabled = NO;
		self.window.rootViewController = nil;
	}];
}

#pragma mark - Internal

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([object isEqual: self.contentViewController]) {
		[self resizeContentOverlay];
		
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ([object isToolbarHidden] ? 1./3. : 0) * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			self.frameView.drawsBottomHighlight = (![object isToolbarHidden]);
			[self.frameView setNeedsDisplay];
		});
		
		return;
	}
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)resizeContentOverlay {
	if (![self.contentViewController isKindOfClass: [UINavigationController class]])
		return;
	
	CGSize contentSize = self.contentView.frame.size;
	UINavigationController *navigationController = (id)self.contentViewController;
	
	// Navigation	
	CGFloat navBarHeight = navigationController.navigationBarHidden ? 0.0 : navigationController.navigationBar.frame.size.height - 1,
	toolbarHeight = navigationController.toolbarHidden ? 0.0 : navigationController.toolbar.frame.size.height;
	
	self.frameView.drawsBottomHighlight = (!navigationController.toolbarHidden);
	
	// Content overlay
	DZPopupControllerInsetView *contentOverlay = self.contentOverlayView;
	
	UIRectCorner corners = 0;
	if (!navigationController.navigationBarHidden)
		corners |= UIRectCornerTopLeft | UIRectCornerTopRight;
	if (!navigationController.toolbarHidden)
		corners |= UIRectCornerBottomLeft | UIRectCornerBottomRight;
	contentOverlay.filledCorners = corners;
	
	const CGFloat frameWidth = 3.0f;
	contentOverlay.frame = CGRectMake(5.0f - frameWidth, 5.0f - frameWidth + navBarHeight, contentSize.width + frameWidth * 2, contentSize.height - navBarHeight - toolbarHeight + frameWidth * 2);
}

- (void)closePressed:(UIButton *)closeButton {
	[self dismissWithCompletion: NULL];
}

@end
