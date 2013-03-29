//
//  ViewController.m
//  LeakDemo
//

#import "ViewController.h"
#import <KSRetainTracker/KSLeakTracker.h>
#import <KSRetainTracker/KSRetainTracker.h>
#import "MyViewController.h"

SYNTHESIZE_IDENTICAL_SUBCLASS(MyClass, NSObject)

@implementation ViewController

- (IBAction) onPrepareTracking
{
    [KSLeakTracker monitorClass:[MyClass class]];
    [KSRetainTracker setEnabled:YES];
    NSLog(@"Tracking enabled");
    UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Tracking enabled" message:@"Tracking enabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

- (IBAction) onShowSubview
{
    MyViewController* myVC = [[[MyViewController alloc] initWithNibName:@"MyViewController" bundle:nil] autorelease];
    MyClass* obj = [[[MyClass alloc] init] autorelease];
    [myVC addObject:obj];
    [self presentModalViewController:myVC animated:YES];
}

- (IBAction) onLog
{
    NSArray* monitors = [KSLeakTracker aliveMonitors];
    if([monitors count] > 0)
    {
        KSRTLifecycleMonitor* monitor = [monitors objectAtIndex:0];
        NSLog(@"%@", monitor);
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"Leaks found!" message:@"See the logs to view the stack traces leading to the leak" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    else
    {
        UIAlertView* av = [[UIAlertView alloc] initWithTitle:@"No leaks!" message:@"No leaks detected" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        NSLog(@"No leaks");
    }
}

@end
