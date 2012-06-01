//
//  CQMViewController.m
//  CQMFloatingController
//
//  Created by Zachary Waldowski on 6/1/12.
//
//

#import "CQMViewController.h"
#import "CQMFloatingController.h"
#import "DemoTableViewController.h"

@implementation CQMViewController

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
	// To use CQMFloatingController:
	
	// 1. Prepare a content view controller
	DemoTableViewController *demoViewController = [DemoTableViewController new];
	UINavigationController *contentViewController = [[UINavigationController alloc] initWithRootViewController: demoViewController];
	contentViewController.toolbarHidden = NO;
	
	// 2. Get shared floating controller
	CQMFloatingController *floatingController = [CQMFloatingController new];
	
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action:NULL];
	UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: nil action:NULL];
	UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAction target: nil action:NULL];
	demoViewController.toolbarItems = [NSArray arrayWithObjects: refresh, space, share, nil];
	demoViewController.hidesBottomBarWhenPushed = NO;
	
	// 3. Show floating controller with specified content
	[floatingController presentWithContentViewController: contentViewController
												animated:YES];
}

@end
