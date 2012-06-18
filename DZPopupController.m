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

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
		self.layer.shadowOffset = CGSizeMake(0, 2);
		self.layer.shadowOpacity = 0.7f;
		self.layer.shadowRadius = 10.0f;
		self.layer.borderWidth = 1.0f;
		self.layer.borderColor = [[UIColor colorWithWhite:1.00f alpha:0.10f] CGColor];
		self.layer.cornerRadius = 8.0f;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[self.baseColor setFill];
	[[UIBezierPath bezierPathWithRoundedRect: CGRectInset(self.bounds, 1.0f, 1.0f) cornerRadius: 8.0f] fill];
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
	
	UIBezierPath *outerRect = [UIBezierPath bezierPathWithRoundedRect: rect byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: CGSizeMake(2.0f, 2.0f)];
	UIBezierPath *innerRect = [UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, 2.0f, 3.0f) cornerRadius: radius];
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
	
	rect = CGRectInset(rect, 13, 13);
	
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0,4), 3.0, [[UIColor colorWithWhite: 0 alpha:0.3] CGColor]);
	CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
	CGContextFillEllipseInRect(context, rect);
	CGContextRestoreGState(context);
	
	CGContextSaveGState(context);
	CGContextSetLineWidth(context, 2.0f);
	CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextStrokeEllipseInRect(context, rect);
	CGContextRestoreGState(context);
	
	CGFloat w = CGRectGetWidth(rect) - 4;
	CGAffineTransform xTransform = CGAffineTransformMakeScale(0.013 * w, 0.013 * w);
	CGAffineTransform translation = CGAffineTransformMakeTranslation(13, 13);
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

@interface DZPopupController ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, weak) DZPopupControllerFrameView *frameView;
@property (nonatomic) UIStatusBarStyle backupStatusBarStyle;

@end

@implementation DZPopupController

@synthesize window = _window;
@synthesize contentViewController = _contentViewController;
@synthesize frameView = _frameView;
@synthesize backupStatusBarStyle = _backupStatusBarStyle;

@synthesize frameSize = _frameSize;
@synthesize frameColor = _frameColor;

#pragma mark - Setup and teardown

static const NSInteger kContentViewTag = 'CNTN';
static const NSInteger kContentInsetTag = 'OVRL';

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
		
	DZPopupControllerFrameView *frame = [[DZPopupControllerFrameView alloc] initWithFrame: (CGRect){{ floor(CGRectGetMidX(self.view.bounds) - self.frameSize.width / 2), floor(CGRectGetMidY(self.view.bounds) - self.frameSize.height / 2) }, self.frameSize }];
	frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	frame.baseColor = _frameColor;
	[self.view addSubview: frame];
	self.frameView = frame;
	
	// Content
	UIView *content = [[UIView alloc] initWithFrame: CGRectInset(frame.bounds, 2.0f, 2.0f)];
	content.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	content.layer.cornerRadius = 7.0f;
	content.clipsToBounds = YES;
	content.tag = kContentViewTag;
	[frame addSubview: content];
	
	DZPopupControllerInsetView *overlay = [DZPopupControllerInsetView new];
	overlay.backgroundColor = [UIColor clearColor];
	overlay.contentMode = UIViewContentModeRedraw;
	overlay.userInteractionEnabled = NO;
	overlay.baseColor = _frameColor;
	overlay.tag = kContentInsetTag;
	[frame addSubview: overlay];

	DZPopupControllerCloseButton *closeButton = [[DZPopupControllerCloseButton alloc] initWithFrame: CGRectMake(-21, -21, 44, 44)];
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
	
	UIView *contentView = [self.view viewWithTag: kContentViewTag];
		
	CGSize contentSize = contentView.frame.size;
	UINavigationController *navigationController = (id)self.contentViewController;
	
	// Navigation	
	CGFloat navBarHeight = navigationController.navigationBarHidden ? 0.0 : navigationController.navigationBar.frame.size.height,
	toolbarHeight = navigationController.toolbarHidden ? 0.0 : navigationController.toolbar.frame.size.height;
		
	// Content inset
	UIView *contentInset = [self.view viewWithTag:kContentInsetTag];
	
	contentInset.frame = CGRectMake(2.0f, 1.0f + navBarHeight, contentSize.width, contentSize.height - navBarHeight - toolbarHeight + 3.0f);
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
	
	UIView *contentView = [self.view viewWithTag:kContentViewTag];
	
	if (!oldController) {
		[UIView transitionWithView: contentView duration: (1./3.) options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionTransitionCrossDissolve animations:^{
			newController.view.frame = contentView.bounds;
			[contentView addSubview: newController.view];
		} completion:^(BOOL finished) {
			[self addChildViewController: newController];
			
			addObservers();
		}];
	} else if (!oldController.view.superview) {
		newController.view.frame = contentView.bounds;
		[contentView addSubview: newController.view];
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
		self.frameView.frame = (CGRect){{ floor(CGRectGetMidX(self.view.bounds) - self.frameSize.width / 2), floor(CGRectGetMidY(self.view.bounds) - self.frameSize.height / 2) }, self.frameSize };
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
		[self.frameView setNeedsDisplay];
		UIView *contentInsetView = [self.view viewWithTag: kContentInsetTag];
		[(id)contentInsetView setBaseColor: _frameColor];
		[contentInsetView setNeedsDisplay];
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
