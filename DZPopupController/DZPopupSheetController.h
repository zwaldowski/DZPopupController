//
//  DZPopupSheetController.h
//  DZPopupController
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZPopupController+Subclasses.h"

@interface DZPopupSheetController : DZPopupController

@property (nonatomic) UIEdgeInsets frameEdgeInsets;
- (void)setFrameEdgeInsets:(UIEdgeInsets)frameEdgeInsets animated:(BOOL)animated;

@property (nonatomic, strong) UIColor *frameColor;
- (void)setFrameColor:(UIColor*)frameColor animated:(BOOL)animated;

@end

@interface DZPopupSheetController (SubclassMethods)

- (void)setDefaultAppearance;
- (void)configureFrameView;
- (void)configureInsetView;
- (void)configureCloseButton;

- (void)closePressed:(UIButton *)closeButton;

@end