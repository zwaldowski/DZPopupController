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
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
		self.layer.shadowOffset = CGSizeMake(0, 2);
		self.layer.shadowOpacity = 0.7f;
		self.layer.shadowRadius = 10.0f;
		self.layer.cornerRadius = 0.0f;
	}
	return self;
}

- (void)setDecorated:(BOOL)decorated {
	if (_decorated != decorated) {
		self.layer.cornerRadius = decorated ? 8.0f : 0;
	}
	_decorated = decorated;
}

- (void)layoutSubviews {
	self.layer.shadowPath = [[UIBezierPath bezierPathWithRect: self.bounds] CGPath];
}

- (void)drawRect:(CGRect)rect {
	if (self.decorated) {
		const CGFloat radius = self.layer.cornerRadius;

		[[UIColor colorWithWhite:1.00f alpha:0.10f] setStroke];
		[[UIBezierPath bezierPathWithRoundedRect: rect cornerRadius: radius+1] stroke];

		[self.baseColor setFill];
		[[UIBezierPath bezierPathWithRoundedRect: CGRectInset(rect, 1.0f, 1.0f) cornerRadius: radius] fill];
	}
}

@end