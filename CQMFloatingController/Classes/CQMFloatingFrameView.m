//
// CQMFloatingFrameView.m
// Created by cocopon on 2012/05/14.
//
// Copyright (c) 2012 cocopon <cocopon@me.com>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "CQMFloatingFrameView.h"
#import <QuartzCore/QuartzCore.h>

#define kStartHighlightColor [UIColor colorWithWhite:1.00f alpha:0.40f]
#define kEndHighlightColor   [UIColor colorWithWhite:1.00f alpha:0.05f]

@implementation CQMFloatingFrameView {
	CGGradientRef _topGradient;
	CGGradientRef _bottomGradient;
}

@synthesize baseColor = _baseColor, drawsBottomHighlight = _drawsBottomHighlight;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame: frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.layer.shadowOffset = CGSizeMake(0, 2);
		self.layer.shadowOpacity = 0.7f;
		self.layer.shadowRadius = 10.0f;
		self.layer.cornerRadius = 8.0f;
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CFArrayRef colors = (__bridge_retained CFArrayRef)[NSArray arrayWithObjects:
														   (id)[kStartHighlightColor CGColor],
														   (id)[kEndHighlightColor CGColor],
														   nil];
		CGFloat locations[] = {0, 1.0f};
		_topGradient = CGGradientCreateWithColors(colorSpace, colors, locations);
		CFRelease(colors);
		colors = (__bridge_retained CFArrayRef)[NSArray arrayWithObjects:
														   (id)[[UIColor clearColor] CGColor],
														   (id)[kStartHighlightColor CGColor],
														   (id)[kEndHighlightColor CGColor],
														   nil];
		CGFloat locations2[] = {0, 0.20f, 1.0f};
		_bottomGradient = CGGradientCreateWithColors(colorSpace, colors, locations2);
		CFRelease(colors);
		CGColorSpaceRelease(colorSpace);
	}
	return self;
}

- (void)dealloc {
	CGGradientRelease(_topGradient);
	CGGradientRelease(_bottomGradient);
}

- (void)setDrawsBottomHighlight:(BOOL)drawsBottomHighlight {
	_drawsBottomHighlight = drawsBottomHighlight;
	[self setNeedsDisplay];
}

#pragma mark - UIView

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

- (void)layoutSubviews {
	self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect: self.bounds cornerRadius: 8.0f] CGPath];
}

@end
