#import <UIKit/UIKit.h>

#import "IntroPageViewController.h"

// This subclasses UIPageViewController, and contains necessary methods to customize this to our needs
// This uses N IntroPageViewControllers (each representing 1 page)
@interface IntroViewController : UIPageViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

+ (IntroPageViewController *)getController:(NSUInteger)pageIndex;

@end
