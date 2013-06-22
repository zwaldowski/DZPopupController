//
//  DZDemoTableViewController.m
//  DZPopupControllerDemo
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZDemoTableViewController.h"
#import "DZDemoDetailViewController.h"

static NSString *const kCellIdentifier = @"PopupDemoCell";

@interface DZDemoTableViewController()

@property (nonatomic, readonly, strong) NSArray *texts;

@end

@implementation DZDemoTableViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.texts.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
	}
	
    cell.textLabel.text = self.texts[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	DZDemoDetailViewController *detailViewController = [DZDemoDetailViewController new];
	NSString *text = [self.texts objectAtIndex:[indexPath row]];
	detailViewController.title = text;
	detailViewController.labelText = text;
	detailViewController.hidesBottomBarWhenPushed = NO;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.navigationItem.title = @"Demo";
	
	NSMutableArray *data = [NSMutableArray array];
	
	for (unichar ch = 'A'; ch <= 'Z'; ch++) {
		[data addObject: [NSString stringWithFormat:@"%C%C%C", ch, ch, ch]];
	}
	
	_texts = data;
}


@end
