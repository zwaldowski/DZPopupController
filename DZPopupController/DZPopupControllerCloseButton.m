//
//  DZPopupControllerCloseButton.m
//  DZPopupController
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
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

	const CGFloat black[4] = {0, 0, 0, 1};
	const CGFloat white[4] = {1, 1, 1, 1};

	CGContextSaveGState(context);
	CGContextSetLineWidth(context, 2.0f);
	CGContextSetFillColor(context, black);
	CGContextSetStrokeColor(context, white);
	CGContextFillEllipseInRect(context, rect);
	CGContextStrokeEllipseInRect(context, rect);
	CGContextRestoreGState(context);

	const CGFloat crossSize = 18;
	const CGFloat crossDelta = ((rect.size.width - crossSize)) / 2 + 2;

	CGContextTranslateCTM(context, crossDelta, crossDelta);
	CGContextScaleCTM(context, crossSize / 100, crossSize / 100);
	CGContextSetFillColor(context, white);

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

- (NSString *)accessibilityLabel {
	return NSLocalizedString(@"Close", @"VoiceOver descriptor for a graphics-only close button");
}

@end
