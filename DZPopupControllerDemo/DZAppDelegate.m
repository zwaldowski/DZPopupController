//
//  DZAppDelegate.m
//  DZPopupControllerDemo
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZAppDelegate.h"
#import "DZDemoViewController.h"

@implementation DZAppDelegate

@synthesize window = window_;

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	self.window.rootViewController = [[DZDemoViewController alloc] initWithNibName:nil bundle:nil];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
