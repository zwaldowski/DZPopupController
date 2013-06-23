//
//  DZPopupController.h
//  DZPopupController
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
#define DZPOPUP_HAS_7_SDK 0
#else
#define DZPOPUP_HAS_7_SDK 1
#endif

extern BOOL DZPopupUIIsStark();

@protocol DZPopupControllerDelegate;

typedef NS_ENUM(NSUInteger, DZPopupTransitionStyle) {
    DZPopupTransitionStyleFade,
    DZPopupTransitionStylePop, // zoom is used on iOS 7
	DZPopupTransitionStyleZoom,
    DZPopupTransitionStyleSlideBottom,
    DZPopupTransitionStyleSlideTop,
    DZPopupTransitionStyleSlideLeft,
    DZPopupTransitionStyleSlideRight,
};

/**
 In placing the popup window, the standard window levels can't be used because
 `UIWindowLevelAlert` is technically over the keyboard. We don't have a keyboard window
 level because it is arbitrarily assigned to be above whoever the current key window is.
 
 The value of this constant is extremely low, only just enough to be always above your
 normal content layer (including `UIPopoverController`) but under the keyboard, native
 alert views, and any HUD view you can/would be using.
 */
extern const UIWindowLevel DZWindowLevelPopup;

/**
 Similarly to `HBAWindowLevelPopup`, this window level displays above content, but below
 popup windows
 */
extern const UIWindowLevel DZWindowLevelHUD;

/**
 This window level displays above content and above popup windows, but below any
 keyboards and system dialogs such as status bars.
 */
extern const UIWindowLevel DZWindowLevelAlert;

/**
 The value used for common UIKit transitions, including modal animations in particular.
 */
extern const NSTimeInterval DZPopupAnimationDuration;

@interface DZPopupController : UIViewController <UIAppearanceContainer>

- (id)initWithContentViewController:(UIViewController *)viewController;
- (id)initWithContentViewController:(UIViewController *)viewController windowLevel:(UIWindowLevel)level;

@property (nonatomic, strong) UIViewController *contentViewController;
- (void)setContentViewController:(UIViewController *)viewController animated:(BOOL)animated;

@property (nonatomic, weak) id <DZPopupControllerDelegate> delegate;

@property (nonatomic, readonly, getter = isVisible) BOOL visible;

@property (nonatomic) DZPopupTransitionStyle entranceStyle;
@property (nonatomic) DZPopupTransitionStyle exitStyle;

@property (nonatomic) UIWindowLevel windowLevel;

- (IBAction)present;
- (IBAction)dismiss;

- (void)presentWithCompletion:(void(^)(void))block;
- (void)dismissWithCompletion:(void(^)(void))block;

@end

@protocol DZPopupControllerDelegate <NSObject>

- (void)popupControllerDidDismissPopup:(DZPopupController *)popupController;

@end