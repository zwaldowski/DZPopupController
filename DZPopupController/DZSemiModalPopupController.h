//
//  DZSemiModalPopupController.h
//  DZPopupController
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
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
