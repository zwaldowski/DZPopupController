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
#import "CQMPathUtilities.h"

#define kCornerRadius        8.0f
#define kLightBorderWidth    1.0f
#define kHighlightHeight     22.0f
#define kHighlightMargin     1.0f
#define kLightBorderColor    [UIColor colorWithWhite:1.00f alpha:0.10f]
#define kStartHighlightColor [UIColor colorWithWhite:1.00f alpha:0.40f]
#define kEndHighlightColor   [UIColor colorWithWhite:1.00f alpha:0.05f]

@implementation CQMFloatingFrameView {
	CGGradientRef _gradient;
}

@synthesize baseColor = _baseColor;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame: frame]) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor clearColor];
		self.layer.shadowColor = [[UIColor blackColor] CGColor];
		self.layer.shadowOffset = CGSizeMake(0, 2);
		self.layer.shadowOpacity = 0.7;
		self.layer.shadowRadius = 10;
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CFArrayRef colors = (__bridge_retained CFArrayRef)[[NSArray alloc] initWithObjects:
														   (id)[kStartHighlightColor CGColor],
														   (id)[kEndHighlightColor CGColor],
														   nil];
		CGFloat locations[] = {0, 1.0f};
		_gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
		CFRelease(colors);
		CGColorSpaceRelease(colorSpace);
	}
	return self;
}

- (void)dealloc {
	CGGradientRelease(_gradient);
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	const CGFloat radius = kCornerRadius;
	
	// Light border
	[kLightBorderColor setFill];
	[[UIBezierPath bezierPathWithRoundedRect: self.bounds cornerRadius: radius + kLightBorderWidth] fill];
	
	// Base
	[self.baseColor setFill];
	[[UIBezierPath bezierPathWithRoundedRect: CGRectInset(self.bounds, kLightBorderWidth, kLightBorderWidth) cornerRadius: radius] fill];
	
	// Highlight
	CGFloat highlightMargin = kLightBorderWidth + kHighlightMargin;
	CGRect highlightRect = CGRectMake(highlightMargin, highlightMargin,
									  CGRectGetWidth(rect) - highlightMargin * 2,
									  kHighlightHeight);
	CGFloat highlightRadius = radius - kHighlightMargin;
	
	CGContextSaveGState(context);
	
	[[UIBezierPath bezierPathWithRoundedRect: highlightRect byRoundingCorners: UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(highlightRadius, highlightRadius)] addClip];
	CGContextDrawLinearGradient(context, _gradient, CGPointZero, CGPointMake(0, kHighlightHeight), 0);
	CGContextRestoreGState(context);
}

- (void)layoutSubviews {
	self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius: kCornerRadius] CGPath];
}

@end
