//
//  DZDemoDetailViewController.m
//  DZPopupControllerDemo
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZDemoDetailViewController.h"

@interface DZDemoDetailViewController ()

@property (nonatomic, weak) IBOutlet UILabel *textLabel;

@end

@implementation DZDemoDetailViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
	
	UILabel *label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:30.0f];
    label.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    label.shadowOffset = CGSizeMake(0, 1.0f);
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.text = self.labelText;
	[self.view addSubview:label];
    self.textLabel = label;
}

@end
