//
//  DZDemoViewController.m
//  DZPopupControllerDemo
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZDemoViewController.h"
#import "DZPopupSheetController.h"
#import "DZSemiModalPopupController.h"
#import "DZDemoTableViewController.h"

@implementation DZDemoViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (IBAction)showButtonAction:(id)sender {
	DZDemoTableViewController *demoViewController = [DZDemoTableViewController new];
	UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController: demoViewController];
	contentViewController.toolbarHidden = NO;
	
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action:NULL];
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: nil action:NULL];
	UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target: nil action:NULL];
	demoViewController.toolbarItems = @[refresh, space, share];
	demoViewController.hidesBottomBarWhenPushed = NO;
	
	DZPopupSheetController *floatingController = [[DZPopupSheetController alloc] initWithContentViewController: contentViewController];
	floatingController.entranceStyle = DZPopupTransitionStylePop;
    floatingController.exitStyle = DZPopupTransitionStylePop;
	self.modalPresentationStyle = UIModalPresentationCurrentContext;
	[floatingController present];
	//[self presentViewController: floatingController animated: YES completion: NULL];
}

- (IBAction)showFramelessButtonAction:(id)sender {
    // TODO
}

- (IBAction)showSemiModalButtonAction:(id)sender {
	DZDemoTableViewController *demoViewController = [DZDemoTableViewController new];
	UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController: demoViewController];
	DZSemiModalPopupController *floatingController = [[DZSemiModalPopupController alloc] initWithContentViewController: contentViewController];
	floatingController.height = 216.0f;
	floatingController.pushesContentBack = YES;

	demoViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: floatingController action: @selector(dismiss)];
	
	//[floatingController present];
	self.modalPresentationStyle = UIModalPresentationCurrentContext;
	[self presentViewController: floatingController animated: YES completion: NULL];
}

- (void)dismiss {
	[self dismissViewControllerAnimated: YES completion: NULL];
}

- (IBAction)showSystemModalButtonAction:(id)sender {
	DZDemoTableViewController *demoViewController = [DZDemoTableViewController new];
	UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController: demoViewController];
	contentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
	contentViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	self.modalPresentationStyle = UIModalPresentationFullScreen;
	demoViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector(dismiss)];

	[self presentViewController: contentViewController animated: YES completion: NULL];
}

@end
