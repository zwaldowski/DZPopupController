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

+ (NSSet *)keyPathsForValuesAffectingImage {
	return [NSSet setWithArray:@[ @"baseColor", @"clippedDrawing" ]];
}

- (UIImage *)drawImage {
	const CGFloat radius = 6.0f;
	const CGFloat radiusInset = radius + 3;
	
	CGFloat width = (radiusInset * 2) + 1;
	CGRect rect = CGRectMake(0, 0, width, width + 2);
	
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect insetRect = CGRectInset(rect, 2.0f, 2.0f);
	insetRect.origin.y += 1.0f;
	insetRect.size.height -= 1.0f;
		
	if (self.clippedDrawing) {
		CGContextAddPath(context, [[UIBezierPath bezierPathWithRoundedRect: rect byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: CGSizeMake(radius, radius)] CGPath]);
		CGContextClip(context);
	}
	CGContextAddPath(context, [[UIBezierPath bezierPathWithRect: rect] CGPath]);
	CGContextAddPath(context, [[UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius: radius] CGPath]);
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1), radius, [[UIColor colorWithWhite:0 alpha: 0.8f] CGColor]);
	CGContextSetFillColorWithColor(context, self.baseColor.CGColor);
	CGContextEOFillPath(context);
	
	UIImage *unstretched = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return [unstretched resizableImageWithCapInsets:UIEdgeInsetsMake(radiusInset + 2, radiusInset, radiusInset, radiusInset)];
}

@end
