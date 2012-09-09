//
//  DZDemoViewController.m
//  DZPopupControllerDemo
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZDemoViewController.h"
#import "DZPopupController.h"
#import "DZSemiModalPopupController.h"
#import "DZDemoTableViewController.h"

@implementation DZDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)showButtonAction:(id)sender {
	// 1. Prepare a content view controller
	DZDemoTableViewController *demoViewController = [DZDemoTableViewController new];
	UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController: demoViewController];
	contentViewController.toolbarHidden = NO;
	
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action:NULL];
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: nil action:NULL];
	UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target: nil action:NULL];
	demoViewController.toolbarItems = [NSArray arrayWithObjects: refresh, space, share, nil];
	demoViewController.hidesBottomBarWhenPushed = NO;
	
	// 2. Get shared floating controller
	DZPopupController *floatingController = [[DZPopupController alloc] initWithContentViewController: contentViewController];
	floatingController.entranceStyle = DZPopupTransitionStyleSlideRight;
    floatingController.exitStyle = DZPopupTransitionStyleSlideRight;
	// 3. Show floating controller with specified content
	[floatingController present];
}

- (IBAction)showSemiModalButtonAction:(id)sender {
	// 1. Prepare a content view controller
	DZDemoTableViewController *demoViewController = [DZDemoTableViewController new];
	UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController: demoViewController];
	contentViewController.toolbarHidden = NO;

	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action:NULL];
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: nil action:NULL];
	UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target: nil action:NULL];
	demoViewController.toolbarItems = [NSArray arrayWithObjects: refresh, space, share, nil];
	demoViewController.hidesBottomBarWhenPushed = NO;

	// 2. Get shared floating controller
	DZSemiModalPopupController *floatingController = [[DZSemiModalPopupController alloc] initWithContentViewController: contentViewController];
		demoViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: floatingController action: @selector(dismiss)];
	[floatingController present];
}

@end
