//
//  DZPopupControllerDrawingView.m
//  DZPopupController
//
//  Created by Zachary Waldowski on 6/1/13.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012-2013 Dizzy Technology. All rights reserved.
//

#import "DZPopupControllerDrawingView.h"

static char imageRegenerationContextKey;

@implementation DZPopupControllerDrawingView

+ (NSSet *)keyPathsForValuesAffectingImage {
	return [NSSet set];
}

- (void)sharedInit {
	self.userInteractionEnabled = YES;
	for (NSString *keyPath in [[self class] keyPathsForValuesAffectingImage]) {
		[self addObserver:self forKeyPath:keyPath options:0 context:&imageRegenerationContextKey];
	}
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame: frame])) {
		[self sharedInit];
	}
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self sharedInit];
}

- (void)dealloc {
	for (NSString *keyPath in [[self class] keyPathsForValuesAffectingImage]) {
		[self removeObserver:self forKeyPath:keyPath context:&imageRegenerationContextKey];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &imageRegenerationContextKey) {
		self.image = nil;
		if (self.superview) {
			self.image = [self drawImage];
		}
		return;
	}
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (UIImage *)drawImage {
	return nil;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
	[super willMoveToWindow:newWindow];
	if (!self.image) {
		self.image = [self drawImage];
	}
}

@end
