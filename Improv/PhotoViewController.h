#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController
+ (PhotoViewController *)photoViewControllerForPageIndex:(NSUInteger)pageIndex;

- (NSInteger)pageIndex;

@end
