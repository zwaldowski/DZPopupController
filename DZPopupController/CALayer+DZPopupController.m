//
//  CALayer+DZPopupController.m
//  DZPopupControllerDemo
//
//  Created by Zach Waldowski on 5/13/13.
//  Copyright (c) 2013 Dizzy Technology. All rights reserved.
//

#import "CALayer+DZPopupController.h"

@interface DZPAnimationDelegate : NSObject

@property (nonatomic, copy) void(^didStartBlock)(CAAnimation *);
@property (nonatomic, copy) void(^didStopBlock)(CAAnimation *, BOOL);

@end

@implementation DZPAnimationDelegate

- (void)animationDidStart:(CAAnimation *)animation {
	if (_didStartBlock)
		_didStartBlock(animation);
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
	if (_didStopBlock)
		_didStopBlock(animation, flag);
}

@end

@implementation CALayer (DZPopupController)

- (void)dzp_addBasicAnimation:(NSString *)key withDuration:(CFTimeInterval)duration from:(id)fromValue to:(id)toValue timing:(CAMediaTimingFunction *)function fillMode:(NSString *)fillMode completion:(void(^)(CALayer *layer, BOOL finished))completion {
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath: key];
	anim.duration = duration;
	anim.fromValue = fromValue;
	anim.toValue = toValue;
	anim.timingFunction = function;
	anim.fillMode = fillMode;
	
	if (completion) {
		__weak CALayer *layer = self;
		DZPAnimationDelegate *delegate = [DZPAnimationDelegate new];
		delegate.didStopBlock = ^(CAAnimation *foo, BOOL finished) {
			__strong CALayer *strongLayer = layer;
			completion(strongLayer, finished);
		};
		anim.delegate = delegate;
	}
	
	[self addAnimation:anim forKey:nil];
}

@end
