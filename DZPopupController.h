//
//  DZPopupController.h
//  DZPopupControllerDemo
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

typedef enum {
    DZPopupTransitionStylePop,
    DZPopupTransitionStyleSlideBottom,
    DZPopupTransitionStyleSlideTop,
    DZPopupTransitionStyleSlideLeft,
    DZPopupTransitionStyleSlideRight,
} DZPopupTransitionStyle;

@interface DZPopupController : UIViewController <UIAppearanceContainer>

- (id)initWithContentViewController:(UIViewController *)viewController;

@property (nonatomic, strong) UIViewController *contentViewController;
- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated;

@property (nonatomic) UIEdgeInsets frameEdgeInsets;
- (void)setFrameEdgeInsets:(UIEdgeInsets)frameEdgeInsets animated:(BOOL)animated;

@property (nonatomic, strong) UIColor *frameColor;
- (void)setFrameColor:(UIColor*)frameColor animated:(BOOL)animated;

@property (nonatomic, readonly, getter = isVisible) BOOL visible;

@property (nonatomic) DZPopupTransitionStyle entranceStyle;
@property (nonatomic) DZPopupTransitionStyle exitStyle;

- (IBAction)present;
- (IBAction)dismiss;

- (void)presentWithCompletion:(void(^)(void))block;
- (void)dismissWithCompletion:(void(^)(void))block;

@end

@interface DZPopupController (SubclassMethods)

- (void)setDefaultAppearance;
- (void)configureFrameView;
- (void)configureInsetView;
- (void)configureCloseButton;

@end