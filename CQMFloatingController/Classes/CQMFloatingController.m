//
// CQMFloatingController.m
// CQMFloatingController
//

#import "CQMFloatingController.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#pragma mark -

@interface CQMFloatingFrameView : UIView

@property (nonatomic, strong) UIColor *baseColor;
@property (nonatomic) BOOL drawsBottomHighlight;

@end

@implementation CQMFloatingFrameView {
	CGGradientRef _topGradient;
	CGGradientRef _bottomGradient;
}

@synthesize baseColor = _baseColor;
@synthesize drawsBottomHighlight = _drawsBottomHighlight;

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
	CGRect highlightRect = CGRectMake(2.0f, 2.0f, CGRectGetWidth(rect) - 4.0f, 26.0f);
	CGSize highlightRadii = CGSizeMake(radius - 1.0f, radius - 1.0f);
	
	CGContextSaveGState(context);
	
	[[UIBezierPath bezierPathWithRoundedRect: highlightRect byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: highlightRadii] addClip];
	CGContextDrawLinearGradient(context, _topGradient, CGPointMake(0, 2.0f), CGPointMake(0, 26.0f), 0);
	
	CGContextRestoreGState(context);
	
	if (self.drawsBottomHighlight) {
		CGContextSaveGState(context);
		
		CGRect bottomHighlightRect = CGRectMake(4.0f, CGRectGetMaxY(rect) - 55.0f, CGRectGetWidth(rect) - 8.0f, 30.0f);
		
		[[UIBezierPath bezierPathWithRect: bottomHighlightRect] addClip];
		CGContextDrawLinearGradient(context, _bottomGradient, CGPointMake(2.0f, CGRectGetMinY(bottomHighlightRect)), CGPointMake(2.0f, CGRectGetMaxY(bottomHighlightRect)), 0);
		CGContextRestoreGState(context);
	}
}

@end

#pragma mark -

@interface CQMFloatingContentOverlayView : UIView

@property (nonatomic, strong) UIColor *baseColor;
@property (nonatomic) UIRectCorner filledCorners;

@end

@implementation CQMFloatingContentOverlayView

@synthesize baseColor = _baseColor;
@synthesize filledCorners = _filledCorners;

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	const CGFloat radius = self.layer.cornerRadius;
	const CGFloat frameWidth = 3.0f;
	
	UIBezierPath *outerRect = [UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, frameWidth - 2, frameWidth - 2) byRoundingCorners: self.filledCorners cornerRadii: CGSizeMake(radius + 2, radius + 2)];
	UIBezierPath *innerRect = [UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, frameWidth, frameWidth) cornerRadius: radius];
	UIBezierPath *fillRect = [outerRect copy];
	[fillRect appendPath: innerRect];
	[fillRect setUsesEvenOddFillRule: YES];
	
	CGContextSaveGState(context);
	
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1), frameWidth, [[UIColor colorWithWhite:0 alpha:0.8f] CGColor]);
	
	[outerRect addClip];
	[self.baseColor setFill];
	[fillRect fill];
	
	CGContextRestoreGState(context);
}

@end

#pragma mark -

static inline UIImage *CQMCreateBlankImage(void) {
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
	UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return ret;
}

@interface CQMFloatingController () {
	UIStatusBarStyle _backupStyle;
	__weak UIViewController *_contentViewController;
}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) CQMFloatingFrameView *frameView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) CQMFloatingContentOverlayView *contentOverlayView;

- (void)resizeContentOverlay;

@end

@implementation CQMFloatingController

@synthesize window = _window;
@synthesize frameView = _frameView;
@synthesize contentView = _contentView;
@synthesize contentOverlayView = _contentOverlayView;
@synthesize frameSize = _frameSize;
@synthesize frameColor = _frameColor;

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
		
		UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		window.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		window.windowLevel = UIWindowLevelNormal;
		window.userInteractionEnabled = NO;
		window.hidden = YES;
		self.window = window;
		
		CQMFloatingFrameView *frame = [CQMFloatingFrameView new];
		frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		frame.backgroundColor = [UIColor clearColor];
		frame.contentMode = UIViewContentModeRedraw;
		frame.layer.cornerRadius = 8.0f;
		frame.layer.shadowOffset = CGSizeMake(0, 2);
		frame.layer.shadowOpacity = 0.7f;
		frame.layer.shadowRadius = 10.0f;
		[self.view addSubview: frame];
		self.frameView = frame;
		
		self.frameSize = CGSizeMake(254, 394);
		
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
		
		CQMFloatingContentOverlayView *overlay = [[CQMFloatingContentOverlayView alloc] initWithFrame: content.bounds];
		overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		overlay.backgroundColor = [UIColor clearColor];
		overlay.contentMode = UIViewContentModeRedraw;
		overlay.userInteractionEnabled = NO;
		overlay.layer.cornerRadius = 5.0f;
		overlay.layer.masksToBounds = YES;
		[contentContainer addSubview: overlay];
		self.contentOverlayView = overlay;
		
		UIButton *closeButton = [UIButton buttonWithType: UIButtonTypeCustom];
		closeButton.frame = CGRectMake(-20, -20, 44, 44);
		[closeButton setImage: [UIImage imageNamed:@"close.png"] forState: UIControlStateNormal];
		[closeButton addTarget: self action:@selector(closePressed:) forControlEvents:UIControlEventTouchUpInside];
		closeButton.layer.shadowColor = [[UIColor blackColor] CGColor];
		closeButton.layer.shadowOffset = CGSizeMake(0,4);
		closeButton.layer.shadowOpacity = 0.3;
		[frame addSubview: closeButton];
		
		self.frameColor = [UIColor colorWithRed:0.10f green:0.12f blue:0.16f alpha:1.00f];
		
		self.contentViewController = viewController;
	}
	return self;
}

- (void)dealloc {
	self.contentViewController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown) && [[[[UIApplication sharedApplication] keyWindow] rootViewController] shouldAutorotateToInterfaceOrientation: interfaceOrientation];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear: animated];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(orientationDidChange:) name: UIApplicationDidChangeStatusBarOrientationNotification object: nil];
	[self resizeContentOverlay];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear: animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidChangeStatusBarOrientationNotification object: nil];
}

- (UIViewController *)contentViewController {
	return _contentViewController;
}

- (void)setContentViewController:(UIViewController *)newController {
	[self setContentViewController: newController animated: NO];
}

- (void)setContentViewController:(UIViewController *)newController animated:(BOOL)animated {
	UIViewController *oldController = self.contentViewController;
	
	if (oldController) {
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
	
	if (!newController)
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
			newController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[self.contentView addSubview: newController.view];
		} completion:^(BOOL finished) {
			[self addChildViewController: newController];
			
			addObservers();
		}];
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
	
	_backupStyle = [[UIApplication sharedApplication] statusBarStyle];
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
	
	[[UIApplication sharedApplication] setStatusBarStyle: _backupStyle animated:YES];
	
	[UIView animateWithDuration: (1./3.) delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent animations:^{
		self.window.alpha = 0.0001;
		self.view.transform = CGAffineTransformMakeScale(0.00001, 0.00001);
	} completion:^(BOOL finished) {
		if (block)
			block();
		
		self.view.userInteractionEnabled = YES;
		self.window.hidden = YES;
		self.window.userInteractionEnabled = NO;
		self.window.rootViewController = nil;
	}];
}

#pragma mark -

- (void)resizeContentOverlay {
	if (![self.contentViewController isKindOfClass: [UINavigationController class]])
		return;
	
	CGSize contentSize = self.contentView.frame.size;
	UINavigationController *navigationController = (id)self.contentViewController;
	
	// Navigation	
	CGFloat navBarHeight = navigationController.navigationBarHidden ? 0.0 : navigationController.navigationBar.frame.size.height - 1,
	toolbarHeight = navigationController.toolbarHidden ? 0.0 : navigationController.toolbar.frame.size.height;
	
	// Content overlay
	CQMFloatingContentOverlayView *contentOverlay = self.contentOverlayView;
	
	UIRectCorner corners = 0;
	if (!navigationController.navigationBarHidden)
		corners |= UIRectCornerTopLeft | UIRectCornerTopRight;
	if (!navigationController.toolbarHidden)
		corners |= UIRectCornerBottomLeft | UIRectCornerBottomRight;
	contentOverlay.filledCorners = corners;
	
	const CGFloat frameWidth = 3.0f;
	[UIView animateWithDuration: 0.0 animations:^{
		contentOverlay.frame = CGRectMake(5.0f - frameWidth, 5.0f - frameWidth + navBarHeight, contentSize.width + frameWidth * 2, contentSize.height - navBarHeight - toolbarHeight + frameWidth * 2);
	}];
}

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

- (void)closePressed:(UIButton *)closeButton {
	[self dismissWithCompletion: NULL];
}

- (void) orientationDidChange: (NSNotification *) note {
	self.window.frame = [[UIScreen mainScreen] bounds];
}

@end
