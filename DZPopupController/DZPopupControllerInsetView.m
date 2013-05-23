//
//  DZPopupControllerInsetView.m
//  DZPopupController
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZPopupControllerInsetView.h"

@implementation DZPopupControllerInsetView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame: frame])) {
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (void)setBackgroundImage {
	const CGFloat radius = 6.0f;
	const CGFloat radiusInset = radius + 3;
	
	CGFloat width = (radiusInset * 2) + 1;
	CGRect rect = CGRectMake(0, 0, width, width + 2);
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect insetRect = CGRectInset(rect, 2.0f, 2.0f);
	insetRect.origin.y += 1.0f;
	insetRect.size.height -= 1.0f;
		
	if (_clippedDrawing) {
		CGContextAddPath(context, [[UIBezierPath bezierPathWithRoundedRect: rect byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: CGSizeMake(radius, radius)] CGPath]);
		CGContextClip(context);
	}
	CGContextAddPath(context, [[UIBezierPath bezierPathWithRect: rect] CGPath]);
	CGContextAddPath(context, [[UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius: radius] CGPath]);
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1), radius, [[UIColor colorWithWhite:0 alpha: 0.8f] CGColor]);
	CGContextSetFillColorWithColor(context, _baseColor.CGColor);
	CGContextEOFillPath(context);
	
	UIImage *unstretched = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	self.image = [unstretched resizableImageWithCapInsets:UIEdgeInsetsMake(radiusInset + 2, radiusInset, radiusInset, radiusInset)];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
	[super willMoveToWindow:newWindow];
	if (!self.image) [self setBackgroundImage];
}

- (void)setBaseColor:(UIColor *)baseColor {
	_baseColor = baseColor;
	self.image = nil;
	if (self.superview) [self setBackgroundImage];
}

- (void)setClippedDrawing:(BOOL)clippedDrawing {
	if (clippedDrawing != _clippedDrawing) {
		_clippedDrawing = clippedDrawing;
		self.image = nil;
		if (self.superview) [self setBackgroundImage];
	}
}

@end
