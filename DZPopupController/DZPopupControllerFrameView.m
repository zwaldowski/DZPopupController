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

@implementation DZPopupControllerFrameView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame: frame])) {
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (void)setBackgroundImage {
	const CGFloat radius = 8.0f;
	const CGFloat currentRadius = _decorated ? radius : 0;
	
	const CGFloat shadowOffset = radius / 4;
	const CGFloat uniqueLength = ((currentRadius + 3) * 2) + 1, shadowPad = radius + (shadowOffset * 2);
	const CGFloat size = uniqueLength + (shadowPad * 2);
	const CGFloat cap = (size - 1) / 2;
	
	CGRect rect = (CGRect){CGPointZero, {size, size}};
	UIGraphicsBeginImageContextWithOptions((CGSize){size, size}, NO, 0);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	rect = CGRectInset(rect, shadowPad, shadowPad);
	
	[[UIColor colorWithWhite:1.00f alpha:0.2] setStroke];
	[[UIBezierPath bezierPathWithRoundedRect: rect cornerRadius: currentRadius+1] stroke];
	
	CGContextSetShadowWithColor(ctx, CGSizeMake(0, shadowOffset), radius, [[UIColor colorWithWhite:0 alpha:0.7] CGColor]);
	[self.baseColor setFill];
	[[UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, 1.0f, 1.0f) cornerRadius: currentRadius] fill];
	
	UIImage *unstretched = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	self.image = [unstretched resizableImageWithCapInsets:UIEdgeInsetsMake(cap, cap, cap, cap)];
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

- (void)setDecorated:(BOOL)decorated {
	if (_decorated != decorated) {
		_decorated = decorated;
		self.image = nil;
		if (self.decorated && self.superview) [self setBackgroundImage];
	}
}

@end