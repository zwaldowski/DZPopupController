//
// DemoDetailViewController.m
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

#import "DemoDetailViewController.h"


#define kBackgroundColor [UIColor colorWithWhite:0.8f alpha:1.0f]
#define kLabelFont       [UIFont boldSystemFontOfSize:30.0f]
#define kShadowOffset    CGSizeMake(0, 1.0f)
#define kTextColor       [UIColor blackColor]
#define kTextShadowColor [UIColor colorWithWhite:1.0f alpha:0.5f]

@implementation DemoDetailViewController

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
