//
//  DZSemiModalPopupController.h
//  DZPopupControllerDemo
//
//  Created by Zachary Waldowski on 9/9/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZPopupController.h"

@interface DZSemiModalPopupController : DZPopupController

@property (nonatomic) DZPopupTransitionStyle entranceStyle NS_UNAVAILABLE;
@property (nonatomic) DZPopupTransitionStyle exitStyle NS_UNAVAILABLE;

@property (nonatomic) UIEdgeInsets frameEdgeInsets NS_UNAVAILABLE;
- (void)setFrameEdgeInsets:(UIEdgeInsets)frameEdgeInsets animated:(BOOL)animated NS_UNAVAILABLE;

@property (nonatomic) BOOL pushesContentBack;

@end
