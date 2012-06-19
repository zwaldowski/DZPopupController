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

@end

@implementation DZPopupControllerFrameView

@synthesize baseColor = _baseColor;

- (id)init {
	if ((self = [super initWithFrame: CGRectZero])) {
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
		self.layer.shadowOffset = CGSizeMake(0, 2);
		self.layer.shadowOpacity = 0.7f;
		self.layer.shadowRadius = 10.0f;
		self.layer.cornerRadius = 8.0f;
	}
	return self;
}

- (void)layoutSubviews {
	self.layer.shadowPath = [[UIBezierPath bezierPathWithRect: self.bounds] CGPath];
}

- (void)drawRect:(CGRect)rect {
	const CGFloat radius = self.layer.cornerRadius;
	
	[[UIColor colorWithWhite:1.00f alpha:0.10f] setStroke];
	[[UIBezierPath bezierPathWithRoundedRect: rect cornerRadius: radius+1] stroke];
	
	[self.baseColor setFill];
	[[UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, 1.0f, 1.0f) cornerRadius: radius] fill];
}

@end

#pragma mark -

@interface DZPopupControllerInsetView : UIView

@property (nonatomic, strong) UIColor *baseColor;

@end

@implementation DZPopupControllerInsetView

@synthesize baseColor = _baseColor;

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	const CGFloat radius = 4.0f;
	
	CGContextSaveGState(context);
	
	CGContextAddPath(context, [[UIBezierPath bezierPathWithRoundedRect: rect byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: CGSizeMake(2.0f, 2.0f)] CGPath]);
	CGContextAddPath(context, [[UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, 2.0f, 3.0f) cornerRadius: radius] CGPath]);
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1), radius, [[UIColor colorWithWhite:0  alpha: 0.8f] CGColor]);
	CGContextSetFillColorWithColor(context, self.baseColor.CGColor);
	CGContextEOFillPath(context);
	
	CGContextRestoreGState(context);
}

@end

#pragma mark -

@interface DZPopupControllerCloseButton : UIButton

@end

@implementation DZPopupControllerCloseButton

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
		self.layer.shadowColor = [[UIColor blackColor] CGColor];
		self.layer.shadowOffset = CGSizeMake(0,4);
		self.layer.shadowOpacity = 0.3;
		self.layer.cornerRadius = frame.size.width / 2;
		
	}
	return self;
}

- (void)layoutSubviews{
	self.layer.shadowPath = [[UIBezierPath bezierPathWithOvalInRect: self.bounds] CGPath];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	rect = CGRectInset(rect, 2, 2);
	
	CGContextSaveGState(context);
	CGContextSetLineWidth(context, 2.0f);
	CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
	CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextFillEllipseInRect(context, rect);
	CGContextStrokeEllipseInRect(context, rect);
	CGContextRestoreGState(context);
	
	CGContextTranslateCTM(context, 3, 3);
	CGContextScaleCTM(context, 0.18, 0.18);
	CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
	
	CGContextMoveToPoint(context, 25, 36);
	CGContextAddCurveToPoint(context, 22, 33, 22, 28, 25, 25);
	CGContextAddCurveToPoint(context, 28, 22, 33, 22, 36, 25);
	CGContextAddLineToPoint(context, 75, 64);
	CGContextAddCurveToPoint(context, 78, 67, 78, 72, 75, 75);
	CGContextAddCurveToPoint(context, 72, 78, 67, 78, 64, 75);
	CGContextAddLineToPoint(context, 25, 36);
	CGContextClosePath(context);
	CGContextFillPath(context);
	
	CGContextMoveToPoint(context, 75, 36);
	CGContextAddCurveToPoint(context, 78, 33, 78, 28, 75, 25);
	CGContextAddCurveToPoint(context, 72, 22, 67, 22, 64, 25);
	CGContextAddLineToPoint(context, 25, 64);
	CGContextAddCurveToPoint(context, 22, 67, 22, 72, 25, 75);
	CGContextAddCurveToPoint(context, 28, 78, 33, 78, 36, 75);
	CGContextAddLineToPoint(context, 75, 36);
	CGContextClosePath(context);
	CGContextFillPath(context);
}

@end

#pragma mark -

@interface DZPopupController ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) DZPopupControllerFrameView *frameView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) DZPopupControllerInsetView *insetView;
@property (nonatomic) UIStatusBarStyle backupStatusBarStyle;

@end

@implementation DZPopupController

@synthesize window = _window, contentViewController = _contentViewController;
@synthesize frameView = _frameView, contentView = _contentView, insetView = _insetView;
@synthesize backupStatusBarStyle = _backupStatusBarStyle;

@synthesize frameSize = _frameSize;
@synthesize frameColor = _frameColor;

#pragma mark - Setup and teardown

- (id)initWithContentViewController:(UIViewController *)viewController {
	if (self = [super initWithNibName:nil bundle:nil]) {
		NSParameterAssert(viewController);

		_frameColor = [UIColor colorWithRed:0.10f green:0.12f blue:0.16f alpha:1.00f];
		_frameSize = CGSizeMake(254, 394);
		
		id navigationBarAppearance = [UINavigationBar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
		[navigationBarAppearance setTintColor: _frameColor];
		
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 0.0);
		UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		id toolbarAppearance = [UIToolbar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
		[toolbarAppearance setBackgroundColor: _frameColor];
		[toolbarAppearance setBackgroundImage: ret forToolbarPosition: UIToolbarPositionAny barMetrics: UIBarMetricsDefault];
		
		self.contentViewController = viewController;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		
	DZPopupControllerFrameView *frame = [DZPopupControllerFrameView new];
	frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	frame.baseColor = _frameColor;
	[self.view addSubview: frame];
	self.frameView = frame;
	self.frameSize = _frameSize;
	
	// Content
	UIView *content = [[UIView alloc] initWithFrame: CGRectInset(frame.bounds, 2.0f, 2.0f)];
	content.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	content.layer.cornerRadius = 7.0f;
	content.clipsToBounds = YES;
	[frame addSubview: content];
	self.contentView = content;
	
	DZPopupControllerInsetView *overlay = [DZPopupControllerInsetView new];
	overlay.backgroundColor = [UIColor clearColor];
	overlay.contentMode = UIViewContentModeRedraw;
	overlay.userInteractionEnabled = NO;
	overlay.baseColor = _frameColor;
	[frame addSubview: overlay];
	self.insetView = overlay;

	DZPopupControllerCloseButton *closeButton = [[DZPopupControllerCloseButton alloc] initWithFrame: CGRectMake(-9, -9, 24, 24)];
	closeButton.showsTouchWhenHighlighted = YES;
	[closeButton addTarget: self action:@selector(closePressed:) forControlEvents:UIControlEventTouchUpInside];
	[frame addSubview: closeButton];
	
	if (!_contentViewController.view.superview)
		self.contentViewController = _contentViewController;
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
	
	CGRect cFrame = self.contentView.frame;
	self.insetView.frame = CGRectMake(CGRectGetMinX(cFrame), CGRectGetMinY(cFrame) + navBarHeight - 2, CGRectGetWidth(cFrame), CGRectGetHeight(cFrame) - navBarHeight - toolbarHeight + 4.0f);
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

- (void)setFrameSize:(CGSize)frameSize {
	[self setFrameSize: frameSize animated: NO];
}

- (void)setFrameSize:(CGSize)frameSize animated:(BOOL)animated {
	_frameSize = frameSize;
	
	if (!self.isViewLoaded)
		return;
	
	void (^animations)(void) = ^{
		self.frameView.frame = (CGRect){{ floor(CGRectGetMidX(self.view.bounds) - self.frameSize.width / 2), floor(CGRectGetMidY(self.view.bounds) - self.frameSize.height / 2) }, self.frameSize };
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
	if ([_frameColor isEqual: frameColor])
		return;
	
	_frameColor = frameColor;
	
	[UIView transitionWithView: self.frameView duration: animated ? 1./3. : 0 options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve animations: ^{
		self.frameView.baseColor = _frameColor;
		[self.frameView setNeedsDisplay];
		self.insetView.baseColor = _frameColor;
		[self.insetView setNeedsDisplay];
		id toolbarAppearance = [UIToolbar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
		id navigationBarAppearance = [UINavigationBar appearanceWhenContainedIn: [UINavigationController class], [self class], nil];
		[navigationBarAppearance setTintColor: _frameColor];
		[toolbarAppearance setBackgroundColor: _frameColor];
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
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.backgroundColor = [UIColor clearColor];
	window.windowLevel = UIWindowLevelAlert;
	window.rootViewController = self;
	[window makeKeyAndVisible];
	self.window = window;
	
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
	[CATransaction setCompletionBlock: block];
	[self.view.layer addAnimation:alpha forKey: nil];
	[self.frameView.layer addAnimation:scale forKey: nil];
	[CATransaction commit];
}

- (void)dismissWithCompletion:(void (^)(void))block {
	[[UIApplication sharedApplication] setStatusBarStyle: self.backupStatusBarStyle animated:YES];
	
	[UIView animateWithDuration: (1./3.) delay: 0.0 options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent animations:^{
		self.view.alpha = 0.0001;
		self.frameView.transform = CGAffineTransformScale(self.frameView.transform, 0.00001, 0.00001);
	} completion:^(BOOL finished) {
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

@end
