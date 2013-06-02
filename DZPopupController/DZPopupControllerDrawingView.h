//
//  DZPopupControllerDrawingView.h
//  DZPopupController
//
//  Created by Zachary Waldowski on 6/1/13.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012-2013 Dizzy Technology. All rights reserved.
//

@interface DZPopupControllerDrawingView : UIImageView

+ (NSSet *)keyPathsForValuesAffectingImage;

- (UIImage *)drawImage;

@end
