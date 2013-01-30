#import "IntroViewController.h"
#import "IntroPageViewController.h"
#import "ImageScrollView.h"

@interface IntroViewController ()
@end

@implementation IntroViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	return [self setup];
}

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	return [self setup];
}
*/

// Initialization
- (id) setup
{
	id _id = [super init];
	
	self.dataSource = self;
	self.delegate = self;
	
	// Create the first page's view controller
	IntroPageViewController *pageZero = [IntroViewController getController:0];
	
	// Set us to point to that
	[self setViewControllers:@[pageZero]
						direction:UIPageViewControllerNavigationDirectionForward
						 animated:NO
					  completion:NULL];
	
	return _id;
}

// Required method of UIPageViewDataSource -- gets the previous view controller
- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerBeforeViewController:(IntroPageViewController *)vc
{
	NSUInteger index = vc.pageIndex;
	return [IntroViewController getController:(index - 1)];
}

// Required method of UIPageViewDataSource -- gets the next view controller
- (UIViewController *)pageViewController:(UIPageViewController *)pvc viewControllerAfterViewController:(IntroPageViewController *)vc
{
	NSUInteger index = vc.pageIndex;
	return [IntroViewController getController:(index + 1)];
}

// Class method -- finds a IntroPageViewController, creating one if needed, for the corresponding page
+ (IntroPageViewController *)getController:(NSUInteger)pageIndex
{
	if (pageIndex < [ImageScrollView imageCount])
	{
		return [[IntroPageViewController alloc] initWithPageIndex:pageIndex];
	}
	return nil;
}

// (this can also be defined in Info.plist via UISupportedInterfaceOrientations)
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
