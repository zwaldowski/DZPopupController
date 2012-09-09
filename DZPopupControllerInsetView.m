//
//  DZPopupControllerInsetView.m
//  DZPopupControllerDemo
//
//  Created by Zachary Waldowski on 9/9/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZPopupControllerInsetView.h"

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
