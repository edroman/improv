//
//  IntroPageViewController.m
//  Improv
//
//  Created by Ed Roman on 1/27/13.
//  Copyright (c) 2013 Ghostfire Games. All rights reserved.
//

#import "IntroPageViewController.h"
#import "ImageScrollView.h"

@interface IntroPageViewController ()
{
	NSUInteger _pageIndex;
}
@end

@implementation IntroPageViewController

- (NSInteger)pageIndex
{
	return _pageIndex;
}

- (id)initWithPageIndex:(NSUInteger)index
{
	self = [super initWithNibName:nil bundle:nil];

	if (self) {
		_pageIndex = index;
		
		// Custom initialization
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
	ImageScrollView *scrollView = [[ImageScrollView alloc] init];
	scrollView.index = _pageIndex;
	scrollView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view = scrollView;

	if (_pageIndex == 2)
	{
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		CGFloat screenWidth = screenRect.size.width;
		CGFloat screenHeight = screenRect.size.height;
		
		UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		button.frame = CGRectMake(screenWidth/2.0f - 25.0f, screenHeight/2.0f - 25.0f, 50.0f, 50.0f);
		button.tag = 101;
		[button setTitle:@"Begin" forState:UIControlStateNormal];
		[button addTarget:self action:@selector(pressedButton:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.view addSubview:button];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressedButton:(id)sender
{
	[self performSegueWithIdentifier:@"IntroToLoginSegue" sender:sender];
}

@end
