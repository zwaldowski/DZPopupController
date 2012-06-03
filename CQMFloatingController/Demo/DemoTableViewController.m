//
// DemoTableViewController.m
// Created by cocopon on 2012/05/15.
//
// Copyright (c) 2012 cocopon <cocopon@me.com>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "DemoTableViewController.h"
#import "DemoDetailViewController.h"


#define kCellIdentifier  @"UITableViewCell"
#define kNavigationTitle @"Demo"

@interface DemoTableViewController()

@property (nonatomic, readonly, strong) NSArray *texts;

@end

@implementation DemoTableViewController

@synthesize texts = _texts;

#pragma mark - UITableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.texts count];
}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:kCellIdentifier];
	}
	
	NSString *text = [self.texts objectAtIndex:[indexPath row]];
	[cell.textLabel setText:text];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
	return cell;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	DemoDetailViewController *detailViewController = [[DemoDetailViewController alloc] init];
	NSString *text = [self.texts objectAtIndex:[indexPath row]];
	detailViewController.title = text;
	detailViewController.textLabel.text = text;
	detailViewController.hidesBottomBarWhenPushed = NO;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.navigationItem setTitle:kNavigationTitle];
	
	NSMutableArray *data = [NSMutableArray new];
	
	for (unichar ch = 'A'; ch <= 'Z'; ch++) {
		[data addObject: [NSString stringWithFormat:@"%C%C%C", ch, ch, ch]];
	}
	
	_texts = data;
}


@end
