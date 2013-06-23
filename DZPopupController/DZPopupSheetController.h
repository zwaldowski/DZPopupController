//
//  DZPopupSheetController.h
//  DZPopupController
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZPopupController+Subclasses.h"

typedef NS_OPTIONS(NSUInteger, DZPopupSheetFrameStyle) {
    DZPopupSheetFrameStyleNone			= 0,
    DZPopupSheetFrameStyleCloseButton	= 1 << 0,
    DZPopupSheetFrameStyleShadowed		= 1 << 1,
    DZPopupSheetFrameStyleBordered		= 1 << 2,
    DZPopupSheetFrameStyleBezel			= 1 << 3, // ignored on iOS 7
    DZPopupSheetFrameStyleAlert			= DZPopupSheetFrameStyleShadowed |
										  DZPopupSheetFrameStyleBordered |
										  DZPopupSheetFrameStyleBezel,
    DZPopupSheetFrameStyleHUD			= DZPopupSheetFrameStyleShadowed |
										  DZPopupSheetFrameStyleBordered,
    DZPopupSheetFrameStyleStark			= DZPopupSheetFrameStyleShadowed, // iOS 7 default
    DZPopupSheetFrameStyleAll			= DZPopupSheetFrameStyleCloseButton |
										  DZPopupSheetFrameStyleShadowed |
										  DZPopupSheetFrameStyleBordered |
										  DZPopupSheetFrameStyleBezel // iOS 6 default
};

@interface DZPopupSheetController : DZPopupController

@property (nonatomic) UIEdgeInsets frameEdgeInsets;
- (void)setFrameEdgeInsets:(UIEdgeInsets)frameEdgeInsets animated:(BOOL)animated;

@property (nonatomic, strong) UIColor *frameColor;
- (void)setFrameColor:(UIColor*)frameColor animated:(BOOL)animated;

@property (nonatomic) DZPopupSheetFrameStyle frameStyle;
- (void)setFrameStyle:(DZPopupSheetFrameStyle)frameStyle animated:(BOOL)animated;

@end