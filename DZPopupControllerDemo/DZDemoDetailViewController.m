//
//  DZDemoDetailViewController.m
//  DZPopupControllerDemo
//
//  Created by cocopon on 5/14/12. Modified by Zachary Waldowski.
//  Copyright (c) 2012 cocopon. All rights reserved.
//  Copyright (c) 2012 Dizzy Technology. All rights reserved.
//

#import "DZDemoDetailViewController.h"

#define kBackgroundColor [UIColor colorWithWhite:0.8f alpha:1.0f]
#define kLabelFont       [UIFont boldSystemFontOfSize:30.0f]
#define kShadowOffset    CGSizeMake(0, 1.0f)
#define kTextColor       [UIColor blackColor]
#define kTextShadowColor [UIColor colorWithWhite:1.0f alpha:0.5f]

@implementation DZDemoDetailViewController

@synthesize textLabel = _textLabel;

#pragma mark - Properties

- (UILabel*)textLabel {
	if (!_textLabel) {
		_textLabel = [[UILabel alloc] init];
		[_textLabel setBackgroundColor:[UIColor clearColor]];
		[_textLabel setFont:kLabelFont];
		[_textLabel setShadowColor:kTextShadowColor];
		[_textLabel setShadowOffset:kShadowOffset];
		[_textLabel setTextAlignment:UITextAlignmentCenter];
		[_textLabel setTextColor:kTextColor];
	}
	return _textLabel;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.view setBackgroundColor:kBackgroundColor];
	
	UILabel *label = [self textLabel];
	CGSize viewSize = [self.view frame].size;
	[label setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	[label setFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
	[self.view addSubview:label];
}

@end
