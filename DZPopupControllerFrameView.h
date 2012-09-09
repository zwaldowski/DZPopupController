//
//  DZPopupControllerFrameView.h
//  DZPopupControllerDemo
//
//  Created by Zachary Waldowski on 9/9/12.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DZPopupControllerFrameView : UIView

@property (nonatomic, strong) UIColor *baseColor;
@property (nonatomic, getter = isDecorated) BOOL decorated;

@end