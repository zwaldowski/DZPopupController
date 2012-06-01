//
// CQMFloatingContentOverlayView.m
// Created by cocopon on 2012/05/15.
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

#import "CQMFloatingContentOverlayView.h"
#import "CQMPathUtilities.h"
#import <QuartzCore/QuartzCore.h>

#define kCornerRadius        5.0f
#define kShadowOffset        CGSizeMake(0, 1.0f)
#define kShadowBlur          3.0f
#define kShadowColor         [UIColor colorWithWhite:0 alpha:0.8f]


@implementation CQMFloatingContentOverlayView

@synthesize edgeColor = _edgeColor;

- (id)init {
	if (self = [super init]) {
		self.layer.cornerRadius = kCornerRadius;
		self.layer.masksToBounds = YES;
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = NO;
	}
	return self;
}

#pragma mark - Properties

+ (CGFloat)frameWidth {
	return kShadowBlur;
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	const CGFloat radius = kCornerRadius;
	const CGFloat frameWidth = kShadowBlur;
	
	CGContextSaveGState(context);
	
	UIBezierPath *outerRect = [UIBezierPath bezierPathWithRect:rect];
	UIBezierPath *roundRect = [UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, frameWidth, frameWidth) cornerRadius: radius];
	UIBezierPath *innerShadowRect = [outerRect copy];
	[innerShadowRect appendPath: roundRect];
	[innerShadowRect setUsesEvenOddFillRule: YES];
	CGContextSetShadowWithColor(context, kShadowOffset, kShadowBlur, [kShadowColor CGColor]);
	[roundRect addClip];
	[innerShadowRect fill];
	
	CGContextRestoreGState(context);
}

@end
