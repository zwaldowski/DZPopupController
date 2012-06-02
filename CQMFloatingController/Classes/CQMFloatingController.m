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

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame: frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.layer.shadowOffset = CGSizeMake(0, 2);
		self.layer.shadowOpacity = 0.7f;
		self.layer.shadowRadius = 10.0f;
		self.layer.cornerRadius = 8.0f;
		
		CGColorRef startHighlight = [[UIColor colorWithWhite:1.00f alpha:0.40f] CGColor];
		CGColorRef endHighlight = [[UIColor colorWithWhite:1.00f alpha:0.05f] CGColor];
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CFArrayRef colors = (__bridge_retained CFArrayRef)[NSArray arrayWithObjects:
														   (__bridge id)startHighlight,
														   (__bridge id)endHighlight,
														   nil];
		CGFloat topLocations[] = {0, 1.0f};
		_topGradient = CGGradientCreateWithColors(colorSpace, colors, topLocations);
		CFRelease(colors);
		colors = (__bridge_retained CFArrayRef)[NSArray arrayWithObjects:
												(id)[[UIColor clearColor] CGColor],
												(__bridge id)startHighlight,
												(__bridge id)endHighlight,
												nil];
		CGFloat bottomLocations[] = {0, 0.20f, 1.0f};
		_bottomGradient = CGGradientCreateWithColors(colorSpace, colors, bottomLocations);
		CFRelease(colors);
		CGColorSpaceRelease(colorSpace);
	}
	return self;
}

- (void)dealloc {
	CGGradientRelease(_topGradient);
	CGGradientRelease(_bottomGradient);
}

- (void)layoutSubviews {
	self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect: self.bounds cornerRadius: 8.0f] CGPath];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	const CGFloat radius = 8.0f;
	
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

- (void)setDrawsBottomHighlight:(BOOL)drawsBottomHighlight {
	_drawsBottomHighlight = drawsBottomHighlight;
	[self setNeedsDisplay];
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

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.layer.cornerRadius = 5.0f;
		self.layer.masksToBounds = YES;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	const CGFloat radius = self.layer.cornerRadius;
	const CGFloat frameWidth = 3.0f;
	
	CGContextSaveGState(context);
	
	UIBezierPath *outerRect = [UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, frameWidth - 2, frameWidth - 2) byRoundingCorners: self.filledCorners cornerRadii: CGSizeMake(radius + 2, radius + 2)];
	UIBezierPath *innerRect = [UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, frameWidth, frameWidth) cornerRadius: radius];
	UIBezierPath *innerShadowRect = [outerRect copy];
	[innerShadowRect appendPath: innerRect];
	[innerShadowRect setUsesEvenOddFillRule: YES];
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1), frameWidth, [[UIColor colorWithWhite:0 alpha:0.8f] CGColor]);
	[outerRect addClip];
	[self.baseColor setFill];
	[innerShadowRect fill];
	
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

@interface CQMFloatingController()

@property (nonatomic, weak) CQMFloatingFrameView *frameView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) CQMFloatingContentOverlayView *contentOverlayView;

- (void)cqm_resizeContentOverlay;

@end

@implementation CQMFloatingController

@synthesize frameView = _frameView;
@synthesize contentView = _contentView;
@synthesize contentOverlayView = _contentOverlayView;
@synthesize contentViewController = _contentViewController;
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
		
		_frameSize = CGSizeMake(254, 394);
		_frameColor = [UIColor colorWithRed:0.10f green:0.12f blue:0.16f alpha:1.00f];
		self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
		
		CQMFloatingFrameView *frame = [[CQMFloatingFrameView alloc] initWithFrame: CGRectMake(ceil((CGRectGetWidth(self.view.frame) - _frameSize.width) / 2), ceil((CGRectGetHeight(self.view.frame) - _frameSize.height) / 2), _frameSize.width, _frameSize.height)];
		frame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
		content.layer.cornerRadius = 5.0f;
		[contentContainer addSubview: content];
		self.contentView = content;
		
		viewController.view.frame = self.contentView.bounds;
		viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[content addSubview: viewController.view];
		_contentViewController = viewController;
		[self addChildViewController: viewController];
		[viewController didMoveToParentViewController: self];
		
		CQMFloatingContentOverlayView *overlay = [[CQMFloatingContentOverlayView alloc] initWithFrame: CGRectZero];
		overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		overlay.baseColor = _frameColor;
		[contentContainer addSubview: overlay];
		self.contentOverlayView = overlay;
		
		if ([viewController isKindOfClass: [UINavigationController class]]) {
			UINavigationController *navigationController = (id)viewController;
			[navigationController addObserver: self forKeyPath: @"toolbar.bounds" options: NSKeyValueObservingOptionNew context: NULL];
			[navigationController addObserver: self forKeyPath: @"navigationBar.bounds" options: 0 context: NULL];
			
			self.frameView.drawsBottomHighlight = (!navigationController.toolbarHidden);
			
			[self cqm_resizeContentOverlay];
		}
	}
	return self;
}

- (void)setFrameSize:(CGSize)frameSize {
	if (!CGSizeEqualToSize(_frameSize, frameSize)) {
		_frameSize = frameSize;
		
		CGRect frame = self.frameView.frame;
		frame.size = _frameSize;
		self.frameView.frame = frame;
	}
}

- (void)setFrameColor:(UIColor*)frameColor {
	if (![_frameColor isEqual: frameColor]) {
		_frameColor = frameColor;
		
		self.frameView.baseColor = _frameColor;
		self.contentOverlayView.baseColor = _frameColor;
		[self.frameView setNeedsDisplay];
		[self.contentOverlayView setNeedsDisplay];
	}
}

static char windowRetainCycle;

- (void)show {
	self.view.alpha = 0.0f;
	
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
	[self.view setFrame:[window convertRect:appFrame fromView:nil]];
	[window addSubview:[self view]];
	
	objc_setAssociatedObject(window, &windowRetainCycle, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	[UIView animateWithDuration: 1./3. animations: ^{
		 self.view.alpha = 1.0f;
	}];
}

- (void)hide {
	[UIView animateWithDuration: 1./3. animations: ^{
		self.view.alpha = 0.0f;
	} completion: ^(BOOL finished){
		 if (!finished)
			 return;
		 
		UIWindow *window = self.view.window;
		[self.view removeFromSuperview];
		objc_setAssociatedObject(window, &windowRetainCycle, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	 }];
}

- (void)cqm_resizeContentOverlay {
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
		[self cqm_resizeContentOverlay];
		
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ([object isToolbarHidden] ? 1./3. : 0) * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			self.frameView.drawsBottomHighlight = (![object isToolbarHidden]);
		});
		
		return;
	}
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
