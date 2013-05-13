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

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	const CGFloat radius = 6.0f;
	
	CGRect insetRect = CGRectInset(rect, 2.0f, 2.0f);
	insetRect.origin.y += 1.0f;
	insetRect.size.height -= 1.0f;


	CGContextSaveGState(context);
	
	if (_clippedDrawing) {
		CGContextAddPath(context, [[UIBezierPath bezierPathWithRoundedRect: rect byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: CGSizeMake(radius, radius)] CGPath]);
		CGContextClip(context);
	}
	CGContextAddPath(context, [[UIBezierPath bezierPathWithRect: rect] CGPath]);
	CGContextAddPath(context, [[UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius: radius] CGPath]);
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1), radius, [[UIColor colorWithWhite:0 alpha: 0.8f] CGColor]);
	CGContextSetFillColorWithColor(context, _baseColor.CGColor);
	CGContextEOFillPath(context);
	CGContextRestoreGState(context);
}

@end
