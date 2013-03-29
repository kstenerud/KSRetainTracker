//
//  MyViewController.h
//  LeakDemo
//

#import <UIKit/UIKit.h>


@interface MyViewController : UIViewController
{
    NSMutableArray* myArray;
}

- (void) addObject:(id) object;

- (IBAction) onDismiss;

@end
