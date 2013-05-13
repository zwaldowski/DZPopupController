//
//  CALayer+DZPopupController.h
//  DZPopupControllerDemo
//
//  Created by Zach Waldowski on 5/13/13.
//  Copyright (c) 2013 Dizzy Technology. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (DZPopupController)

- (void)dzp_addBasicAnimation:(NSString *)key withDuration:(CFTimeInterval)duration from:(id)fromValue to:(id)toValue timing:(CAMediaTimingFunction *)function fillMode:(NSString *)fillMode completion:(void(^)(CALayer *layer, BOOL finished))completion;

@end
