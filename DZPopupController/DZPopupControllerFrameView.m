//
//  DZPopupControllerFrameView.m
//  DZPopupController
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZPopupControllerFrameView.h"
#import "DZPopupSheetController.h"

@implementation DZPopupControllerFrameView

+ (NSSet *)keyPathsForValuesAffectingImage {
	return [NSSet setWithArray:@[ @"baseColor", @"bordered", @"shadowed" ]];
}

- (UIImage *)drawImage {
	if (!self.bordered && !self.shadowed) return nil;
	
	const CGFloat radius = DZPopupSheetBorderRadius;

	const CGFloat uniqueLength = ((radius + 3) * 2) + 1, shadowPad = DZPopupSheetShadowPaddingForBorderRadius(radius);
	const CGFloat size = uniqueLength + (shadowPad * 2);
	const CGFloat cap = (size - 1) / 2;

	CGRect rect = (CGRect){CGPointZero, {size, size}};
	UIGraphicsBeginImageContextWithOptions((CGSize){size, size}, NO, 0);

	rect = CGRectInset(rect, shadowPad, shadowPad);
	
	if (self.bordered) {
		UIScreen *screen = self.window ? self.window.screen : [UIScreen mainScreen];
		const CGFloat hairline = 1.0f / screen.scale;
		
		[[UIColor colorWithWhite:1.00f alpha:0.2] setStroke];
		UIBezierPath *outerRing = [UIBezierPath bezierPathWithRoundedRect: rect cornerRadius: radius];
		outerRing.lineWidth = hairline;
		[outerRing stroke];
	}

	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect: rect cornerRadius: radius-1];
	
	if (self.shadowed) {
		CGFloat shadowOffset = radius / 4;
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSetShadowWithColor(ctx, CGSizeMake(0, shadowOffset), 10, [[UIColor colorWithWhite:0 alpha:1] CGColor]);
	}
	
	[self.baseColor setFill];
	[path fill];
	[path stroke];

	UIImage *unstretched = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return [unstretched resizableImageWithCapInsets:UIEdgeInsetsMake(cap, cap, cap, cap)];
}

@end