//
//  DZPopupControllerFrameView.m
//  DZPopupController
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZPopupControllerFrameView.h"
#import <QuartzCore/QuartzCore.h>

@implementation DZPopupControllerFrameView {
	CGFloat _cornerRadius;
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame: frame])) {
		self.userInteractionEnabled = YES;
		self.layer.shadowOffset = CGSizeMake(0, 2);
		self.layer.shadowOpacity = 0.7f;
		self.layer.shadowRadius = 10.0f;
		self.layer.shouldRasterize = YES;
		self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
	}
	return self;
}

- (void)setDecorated:(BOOL)decorated {
	if (_decorated != decorated) {
		_cornerRadius = decorated ? 8.0f : 0;
		self.image = nil;
		if (self.decorated && self.superview) [self setBackgroundImage];
	}
	_decorated = decorated;
}

- (void)setBackgroundImage {
	const CGFloat radius = _cornerRadius;
	CGFloat size = ((radius + 1) * 2) + 1;
	CGRect rect = CGRectMake(0, 0, size, size);
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0);
	[[UIColor colorWithWhite:1.00f alpha:0.10f] setStroke];
	[[UIBezierPath bezierPathWithRoundedRect: rect cornerRadius: radius+1] stroke];
	
	[self.baseColor setFill];
	[[UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, 1.0f, 1.0f) cornerRadius: radius] fill];

	
	UIImage *unstretched = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	self.image = [unstretched resizableImageWithCapInsets:UIEdgeInsetsMake(radius, radius, radius, radius)];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
	[super willMoveToWindow:newWindow];
	if (!self.image && self.decorated) [self setBackgroundImage];
}

- (void)setBaseColor:(UIColor *)baseColor {
	_baseColor = baseColor;
	self.image = nil;
	if (self.decorated && self.superview) [self setBackgroundImage];
}

@end