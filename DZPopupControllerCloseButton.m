//
//  DZPopupControllerCloseButton.m
//  DZPopupControllerDemo
//
//  Created by Zachary Waldowski on 9/9/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZPopupControllerCloseButton.h"
#import <QuartzCore/QuartzCore.h>

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