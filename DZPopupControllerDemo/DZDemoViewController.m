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
	DZDemoTableViewController *demoViewController = [DZDemoTableViewController new];
	UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController: demoViewController];
	contentViewController.toolbarHidden = NO;
	
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action:NULL];
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: nil action:NULL];
	UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target: nil action:NULL];
	demoViewController.toolbarItems = @[refresh, space, share];
	demoViewController.hidesBottomBarWhenPushed = NO;
	
	DZPopupController *floatingController = [[DZPopupController alloc] initWithContentViewController: contentViewController];
	floatingController.entranceStyle = DZPopupTransitionStylePop;
    floatingController.exitStyle = DZPopupTransitionStylePop;
	[floatingController present];
}

- (IBAction)showSemiModalButtonAction:(id)sender {
	DZDemoTableViewController *demoViewController = [DZDemoTableViewController new];
	UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController: demoViewController];
	DZSemiModalPopupController *floatingController = [[DZSemiModalPopupController alloc] initWithContentViewController: contentViewController];
	floatingController.height = 216.0f;
	floatingController.pushesContentBack = YES;

	demoViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: floatingController action: @selector(dismiss)];
	
	[floatingController present];
}

- (void)dismiss {
	[self dismissViewControllerAnimated: YES completion: NULL];
}

- (IBAction)showSystemModalButtonAction:(id)sender {
	DZDemoTableViewController *demoViewController = [DZDemoTableViewController new];
	UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController: demoViewController];
	contentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
	contentViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

	demoViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone target: self action: @selector(dismiss)];

	[self presentViewController: contentViewController animated: YES completion: NULL];
}

@end
