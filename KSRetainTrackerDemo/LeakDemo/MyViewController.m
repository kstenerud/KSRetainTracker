//
//  MyViewController.m
//  LeakDemo
//

#import "MyViewController.h"
#import <KSRetainTracker/KSLeakTracker.h>


@implementation MyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        myArray = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)dealloc
{
    [myArray release];
    [super dealloc];
}

- (void) addObject:(id) object
{
    // Leaky
    [myArray addObject:[object retain]];

    // Non-leaky
//    [myArray addObject:object];
}

- (IBAction) onDismiss
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
