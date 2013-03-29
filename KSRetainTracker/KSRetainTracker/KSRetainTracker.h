//
//  KSRetainTracker.h
//  KSRetainTracker
//
// Copyright 2010 Karl Stenerud, all rights reserved
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


#import <Foundation/Foundation.h>
#import "KSRTTypes.h"
#import "KSRTObjectTracker.h"

/** \mainpage KSRetainTracker
 
 <strong>A debugging framework for tracking down memory management problems</strong> <br><br>
 
 Version 2.0 <br> <br>
 
 Copyright 2010 Karl Stenerud. All rights reserved. <br><br>

 \section contents_sec Contents
 - \ref intro_sec
 - \ref basic_sec
 - \ref advanced_sec
 - \ref leak_tracker_sec

 
 <br>
 \section intro_sec Introduction

 Memory management is tricky, and debugging memory issues can be trickier still.
 Apple offers some tools to help, but often they're not quite fine-grained
 enough for your needs. Sometimes you just wish you had a tailored solution.
 
 KSRetainTracker puts you in control. With a few lines of code, you can track
 every alloc, retain, release, autorelease, and dealloc, on a single object or
 on entire classes, complete with a stack trace at every step to help you track
 down where that extra retain or release is happening, or which object isn't
 letting go when it should.
 
 You can be as broad or as narrow as you want in your approach. Since it's all
 in code, your debugging session is tailored to the problem at hand. You can
 even define your own custom routines to perform whenever a memory management
 method gets called on an object.
 
 KSRetainTracker is the customized debug solution for hard memory problems.

 <br>
 KSLeakTracker is an add-on to KSRetainTracker. It provides fine-grained leak
 tracking.

 
 <br>
 \section basic_sec Basic Usage
 
 The most common usage is:
 
 \code
 #import <KSRetainTracker/KSRetainTracker.h>

 ...
 
 [KSRetainTracker addCondensedLogCallbacksForClass:[MyView class] callStackDepth:3];
 [KSRetainTracker setEnabled:YES]; // Start tracking

 ... // Do stuff with your MyView class

 // Once you're done (possibly in a different file/method):
 [KSRetainTracker setEnabled:NO]; // Disable globally
 // - OR -
 [KSRetainTracker removeCallbacksForClass:[MyView class]]; // Stop tracking MyView
 \endcode
 
 <strong>addCondensedLogCallbacksForClass</strong> is a convenience method for
 adding log entries to all memory management methods for a class. The NSLog
 output will look something like this:
 \code
 2011-09-05 12:19:20.526 MySuperApp[26403:207] <MyView: 0x8105400> ALLOC  :  1 ( 1) (_decodeObject,-[UIRuntimeConnection initWithCoder:],_decodeObjectBinary)
 2011-09-05 12:19:20.530 MySuperApp[26403:207] <MyView: 0x8105400> RETAIN :  2 ( 2) (_decodeObjectBinary,_decodeObject,-[UIRuntimeConnection initWithCoder:])
 2011-09-05 12:19:20.532 MySuperApp[26403:207] <MyView: 0x8105400> RETAIN :  3 ( 3) (__CFBasicHashAddValue,CFDictionarySetValue,-[NSKeyedUnarchiver _replaceObject:withObject:])
 2011-09-05 12:19:20.535 MySuperApp[26403:207] <MyView: 0x8105400> RELEASE:  2 ( 2) (_decodeObjectBinary,_decodeObject,-[UIRuntimeConnection initWithCoder:])
 2011-09-05 12:19:20.537 MySuperApp[26403:207] <MyView: 0x8105400> RETAIN :  3 ( 3) (__CFBasicHashAddValue,CFDictionarySetValue,_decodeObjectBinary)
 2011-09-05 12:19:20.540 MySuperApp[26403:207] <MyView: 0x8105400> AUTOREL:  3 ( 2) (_decodeObject,-[UIRuntimeConnection initWithCoder:],_decodeObjectBinary)
 2011-09-05 12:19:20.615 MySuperApp[26403:207] <MyView: 0x8105400> RELEASE:  2 ( 1) (-[__NSArrayI dealloc],__CFBasicHashDrain,-[NSKeyedUnarchiver dealloc])
 2011-09-05 12:19:20.808 MySuperApp[26403:207] <MyView: 0x8105400> RELEASE:  1 ( 1) (_CFAutoreleasePoolPop,-[NSAutoreleasePool release],_UIApplicationHandleEvent)
 2011-09-05 12:19:22.893 MySuperApp[26403:207] <MyView: 0x8105400> RELEASE:  0 ( 0) (-[MyView dealloc],-[UIView dealloc],-[UINavigationTransitionView dealloc])
 2011-09-05 12:19:22.894 MySuperApp[26403:207] <MyView: 0x8105400> DEALLOC:         (-[MyView dealloc],-[UIView dealloc],-[UIView dealloc])
 \endcode
 
 If you were to use <strong>addFullLogCallbacksForClass</strong> instead, it would print out the
 more familiar full stack trace format:
 \code
 2011-09-05 14:08:00.112 MySuperApp[29017:207] <MyView: 0x6b2c7e0> ALLOC  :  1 ( 1) 
 4   Foundation                          0x00713d91 _decodeObject + 224
 5   UIKit                               0x00ba9979 -[UIRuntimeConnection initWithCoder:] + 212
 6   Foundation                          0x00714c24 _decodeObjectBinary + 3296
 2011-09-05 14:08:00.115 MySuperApp[29017:207] <MyView: 0x6b2c7e0> RETAIN :  2 ( 2) 
 3   Foundation                          0x00714ce2 _decodeObjectBinary + 3486
 4   Foundation                          0x00713d91 _decodeObject + 224
 5   UIKit                               0x00ba9979 -[UIRuntimeConnection initWithCoder:] + 212
 ...
 \endcode

 The two numbers in the traces - for example 3 (2) - represent the tracked
 object's retain count and effective retained count (in parenthesis). The
 effective retain count is the retain count minus the number of pending
 autoreleases. These count values represent what the values would be AFTER
 the memory management operation has completed.
 
 Note: Some call stack entries are ignored since they add no meaning and clutter
       up the stack trace. See \link KSRTTypes.h KSRTCallback in KSRTTypes.h \endlink for more info.

 Note: If you see (ALLOC) instead of ALLOC, it signifies a "stealth" alloc.
       This happens if an object the tracker hasn't seen before suddenly
       receives a retain, release, autorelease, or dealloc. Some Apple classes
       do some trickery, bypassing the normal alloc process. The "stealth"
       alloc trace helps inform you of when this happens.
 
 <br>
 \section advanced_sec Advanced Usage
 
 <br>
 \subsection synthesize_identical_subclass_subsec Narrowing down what gets tracked
 
 Sometimes you want to track only specific instances of a class, as you would
 otherwise be flooded with irrelevant reports.
 
 The <strong>SYNTHESIZE_IDENTICAL_SUBCLASS</strong> macro creates a custom subclass
 that is identical to a superclass in every way except for its name. By
 temporarily changing your code to instantiate the subclass, you can
 differentiate it from all the other instances. Here's an example:
 
 \code
 #import <KSRetainTracker/KSRetainTracker.h>
 
 ...
 
 SYNTHESIZE_IDENTICAL_SUBCLASS(MyNarrowClass, MyWideClass);
 
 ...
 
 [KSRetainTracker addCondensedLogCallbacksForClass:[MyNarrowClass class] callStackDepth:3];
 [KSRetainTracker setEnabled:YES]; // Start tracking
 \endcode

 Elsewhere:
 
 \code
 // TODO: Return this to normal after debugging session
 //myInstance = [[MyWideClass alloc] init];
 myInstance = [[MyNarrowClass alloc] init];
 \endcode
 
 
 <br>
 \subsection custom_callbacks_subsec Adding your own custom callbacks

 If the logging convenience methods aren't enough to track down your memory
 issue, you can add your own callbacks to do more detailed work.
 
 The method <strong>addCallback:forClass:method:</strong> provides the
 interface for this. You can use it like so:
 
 \code
 #import <KSRetainTracker/KSRetainTracker.h>
 
 ...
 
 [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
 {
     NSLog(@"Object %@ was released!", tracker.object);
     [MyCustomTracker notifyObjectReleasedWithTracker:tracker callStack:callStack];
 } forClass:[MyClass class] method:KSRTMethodRelease];

 [KSRetainTracker setEnabled:YES]; // Start tracking
 \endcode
 
 See KSRTTypes.h for an explanation of the method types.
 
 Note: Callbacks for memory management operations occur BEFORE the operation
       proceeds (with the exception of alloc and stealth alloc)!
       This means that the object's official (pre-operation) retain count
       will be different from the tracker's effective (post-operation) retain
       count at the point of the callback.

 
 <br>
 \section leak_tracker_sec Using KSLeakTracker
 
 KSLeakTracker monitors objects over the course of their lifetimes, keeping
 track of all memory management calls made, including stack trace.
 
 As an example, let's suppose that you have a view controller that keeps a list
 of objects for some purpose. In our simple universe, we create the view
 controller and add one object to it.
 Here's the pertinent code:
 
 MainViewController:
 \code
 - (IBAction) onShowSubview
 {
     MyViewController* myVC = [[[MyViewController alloc] initWithNibName:@"MyViewController" bundle:nil] autorelease];
     MyClass* obj = [[[MyClass alloc] init] autorelease];
     [myVC addObject:obj];
     [self presentModalViewController:myVC animated:YES];
 }
 \endcode

 MyViewController:
 \code
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
     self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
     if (self)
     {
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
     [myArray addObject:[object retain]];
 }
 
 - (IBAction) onDismiss
 {
     [self.parentViewController dismissModalViewControllerAnimated:YES];
 }
 \endcode
 
 You discover that it leaks memory every time you present and dismiss the
 controller, but where is the actual leak?
 
 Add in some strategic tracking and logging buttons:
 
 MainViewController:
 \code
 - (IBAction) onPrepareTracking
 {
     [KSLeakTracker monitorClass:[MyClass class]];
     [KSRetainTracker setEnabled:YES];
 }

 - (IBAction) onLog
 {
     NSArray* monitors = [KSLeakTracker aliveMonitors];
     if([monitors count] > 0)
     {
         // Just printing the first one for our example
         KSRTLifecycleMonitor* monitor = [monitors objectAtIndex:0];
         NSLog(@"%@", monitor);
     }
     else
     {
         NSLog(@"No leaks");
     }
 }
 \endcode

 Now, after triggering onPrepareTracking, presenting the controller, dismissing
 it, then triggering onLog, you get:
 \code
 2011-09-10 16:41:23.596 myapp[25974:207] <KSRTLifecycleMonitor: 0x4e3a830>: Tracker = [<KSRTObjectTracker: 0x4e2c210>: Object = <MyClass: 0x4e056a0>, RC =  1 ( 1)], Operations =
 <KSRTMMOperation: 0x4e3aa90>: RC =  1 ( 1), Method = Alloc, Stack =
 4   myapp                               0x00002696 -[MainViewController onShowSubview] + 166
 5   UIKit                               0x000b44fd -[UIApplication sendAction:to:from:forEvent:] + 119
 6   UIKit                               0x00144799 -[UIControl sendAction:to:forEvent:] + 67
 7   UIKit                               0x00146c2b -[UIControl(Internal) _sendActionsForEvents:withEvent:] + 527
 8   UIKit                               0x00145a1c -[UIControl touchesBegan:withEvent:] + 277
 9   UIKit                               0x000d8d41 -[UIWindow _sendTouchesForEvent:] + 395
 10  UIKit                               0x000b9c37 -[UIApplication sendEvent:] + 447
 11  UIKit                               0x000bef2e _UIApplicationHandleEvent + 7576
 12  GraphicsServices                    0x01346992 PurpleEventCallback + 1550
 13  CoreFoundation                      0x00e43944 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__ + 52
 <KSRTMMOperation: 0x4e3c800>: RC =  1 ( 0), Method = Autorelease, Stack =
 3   myapp                               0x000026cc -[MainViewController onShowSubview] + 220
 4   UIKit                               0x000b44fd -[UIApplication sendAction:to:from:forEvent:] + 119
 5   UIKit                               0x00144799 -[UIControl sendAction:to:forEvent:] + 67
 6   UIKit                               0x00146c2b -[UIControl(Internal) _sendActionsForEvents:withEvent:] + 527
 7   UIKit                               0x00145a1c -[UIControl touchesBegan:withEvent:] + 277
 8   UIKit                               0x000d8d41 -[UIWindow _sendTouchesForEvent:] + 395
 9   UIKit                               0x000b9c37 -[UIApplication sendEvent:] + 447
 10  UIKit                               0x000bef2e _UIApplicationHandleEvent + 7576
 11  GraphicsServices                    0x01346992 PurpleEventCallback + 1550
 12  CoreFoundation                      0x00e43944 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__ + 52
 <KSRTMMOperation: 0x4e3e4e0>: RC =  2 ( 1), Method = Retain, Stack =
 3   myapp                               0x0000299d -[MyViewController addObject:] + 77
 4   myapp                               0x000026f4 -[MainViewController onShowSubview] + 260
 5   UIKit                               0x000b44fd -[UIApplication sendAction:to:from:forEvent:] + 119
 6   UIKit                               0x00144799 -[UIControl sendAction:to:forEvent:] + 67
 7   UIKit                               0x00146c2b -[UIControl(Internal) _sendActionsForEvents:withEvent:] + 527
 8   UIKit                               0x00145a1c -[UIControl touchesBegan:withEvent:] + 277
 9   UIKit                               0x000d8d41 -[UIWindow _sendTouchesForEvent:] + 395
 10  UIKit                               0x000b9c37 -[UIApplication sendEvent:] + 447
 11  UIKit                               0x000bef2e _UIApplicationHandleEvent + 7576
 12  GraphicsServices                    0x01346992 PurpleEventCallback + 1550
 <KSRTMMOperation: 0x4e40450>: RC =  3 ( 2), Method = Retain, Stack =
 4   CoreFoundation                      0x00e57604 -[__NSArrayM addObject:] + 68
 5   myapp                               0x000029b9 -[MyViewController addObject:] + 105
 6   myapp                               0x000026f4 -[MainViewController onShowSubview] + 260
 7   UIKit                               0x000b44fd -[UIApplication sendAction:to:from:forEvent:] + 119
 8   UIKit                               0x00144799 -[UIControl sendAction:to:forEvent:] + 67
 9   UIKit                               0x00146c2b -[UIControl(Internal) _sendActionsForEvents:withEvent:] + 527
 10  UIKit                               0x00145a1c -[UIControl touchesBegan:withEvent:] + 277
 11  UIKit                               0x000d8d41 -[UIWindow _sendTouchesForEvent:] + 395
 12  UIKit                               0x000b9c37 -[UIApplication sendEvent:] + 447
 13  UIKit                               0x000bef2e _UIApplicationHandleEvent + 7576
 <KSRTMMOperation: 0x4e3f570>: RC =  2 ( 2), Method = Release, Stack =
 4   CoreFoundation                      0x00d9e18d _CFAutoreleasePoolPop + 237
 5   Foundation                          0x008163eb -[NSAutoreleasePool release] + 167
 6   UIKit                               0x000bf3ee _UIApplicationHandleEvent + 8792
 7   GraphicsServices                    0x01346992 PurpleEventCallback + 1550
 8   CoreFoundation                      0x00e43944 __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__ + 52
 9   CoreFoundation                      0x00da3cf7 __CFRunLoopDoSource1 + 215
 10  CoreFoundation                      0x00da0f83 __CFRunLoopRun + 979
 11  CoreFoundation                      0x00da0840 CFRunLoopRunSpecific + 208
 12  CoreFoundation                      0x00da0761 CFRunLoopRunInMode + 97
 13  GraphicsServices                    0x013451c4 GSEventRunModal + 217
 <KSRTMMOperation: 0x4b12480>: RC =  1 ( 1), Method = Release, Stack =
 4   CoreFoundation                      0x00e5b84a -[__NSArrayM dealloc] + 170
 6   myapp                               0x00002910 -[MyViewController dealloc] + 64
 8   UIKit                               0x00363030 -[UIWindowController transitionViewDidComplete:fromView:toView:] + 1559
 9   UIKit                               0x00141c6a -[UITransitionView notifyDidCompleteTransition:] + 188
 10  UIKit                               0x001427b1 -[UITransitionView _didCompleteTransition:] + 1286
 11  UIKit                               0x000e4fb9 -[UIViewAnimationState sendDelegateAnimationDidStop:finished:] + 294
 12  UIKit                               0x000e4e4b -[UIViewAnimationState animationDidStop:finished:] + 77
 13  QuartzCore                          0x019fb99b _ZL23run_animation_callbacksdPv + 278
 14  QuartzCore                          0x019a0651 _ZN2CAL14timer_callbackEP16__CFRunLoopTimerPv + 157
 15  CoreFoundation                      0x00e438c3 __CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__ + 19
 \endcode
 
 Looking at the first line:
 \code
   <KSRTLifecycleMonitor: 0x4e3a830>: Tracker = [<KSRTObjectTracker: 0x4e2c210>: Object = <MyClass: 0x4e056a0>, RC =  1 ( 1)], Operations =
 \endcode

 The instance of MyClass is still alive with a retain count of 1 (i.e. it has leaked).
 
 - <strong>-[MainViewController onShowSubview]</strong> didn't leak it, because there's an effective
   retain count of 0 (1 retain + 1 autorelease) after the last stack entry where it's at the top.

 - NSArray isn't leaking; We can see a retain from addObject and a matching
   release from dealloc.

 - The autorelease entry is accounted for (from onShowSubview)

 - <strong>-[MyViewController addObject:]</strong>, the only remaining entry,
   appears to be the likely culprit.
 
 Looking at -[MyViewController addObject:] again:
 
 \code
 - (void) addObject:(id) object
 {
     [myArray addObject:[object retain]];
 }
 \endcode
 
 This should actually be:
 \code
 - (void) addObject:(id) object
 {
     [myArray addObject:object];
 }
 \endcode

 After fixing the bug, re-running our checker will log "No leaks".
 */



/** \def SYNTHESIZE_IDENTICAL_SUBCLASS(SUBCLASS, SUPERCLASS)
 * Synthesize an empty subclass (different in name only) to make it easier
 * to track via RetainTracker.
 */
#define SYNTHESIZE_IDENTICAL_SUBCLASS(SUBCLASS, SUPERCLASS) \
@interface SUBCLASS : SUPERCLASS {} @end @implementation SUBCLASS @end



/**
 * Main control class for retain tracking.
 *
 * From this class, you can add or remove tracking for classes, or
 * enable/disable tracking at the global level.
 *
 * Retain tracking starts off disabled. You can enable it by calling
 * \code
 [KSRetainTracker setEnabled:YES];
 * \endcode
 *
 * You can register callbacks for memory management methods using the
 * <strong>addCallback</strong> method, or simply use one of the convenience
 * logging methods <strong>addCondensedLogCallbacksForClass</strong> or
 * <strong>addFullLogCallbacksForClass</strong>.
 */
@interface KSRetainTracker : NSObject
{
}

#pragma mark Properties

/** When YES, tracker will log memory management method calls.
 *
 * @return YES if enabled.
 */
+ (BOOL) enabled;

/** Enable/disable tracking.
 *
 * @param value If YES, enable tracking.
 */
+ (void) setEnabled:(BOOL) value;

/** The depth of the stack trace that will be generated for your callbacks.
 *
 * @return The stack trace depth.
 */
+ (int) stackTraceDepth;

/** Set the depth of the stack trace that will be generated for your callbacks.
 *
 * @param stackDepth The stack trace depth.
 */
+ (void) setStackTraceDepth:(int) stackDepth;


#pragma mark Main API

/** Add a callback for the specified class method. An object tracker
 * will call your callback whenever an instance of the specified class calls
 * the specified method.
 *
 * Example:
 \code
 [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
 {
     NSLog(@"Object %@ was released!", tracker.object);
     [MyCustomTracker notifyObjectReleasedWithTracker:tracker callStack:callStack];
 } forClass:[MyClass class] method:KSRTMethodRelease];
 \endcode
 *
 * @param callback Your callback block.
 * @param cls The class to track.
 * @param method The method to track.
 */
+ (void) addCallback:(KSRTCallback) callback
            forClass:(Class) cls
              method:(KSRTMethod) method;

/** Convenience method to log a condensed stack trace to every memory management
 * call that instances of the specified class make.
 *
 * The logging output will look similar to this (assuming callStackDepth = 3):
 * \code
2011-09-05 12:19:20.621 MyAwesomeApp[26403:207] <MyView: 0x8105400> RETAIN :  3 ( 3) (-[MyViewController view],-[MyViewController contentScrollView],-[UINavigationController _computeAndApplyScrollContentInsetDeltaForViewController:])
   \endcode
 *
 * @param cls The class to log memory management calls for.
 * @param callStackDepth The depth to which to log call stack entries. Note that
 *                       callStackDepth is limited by
 *                       [KSRetainTracker stackTraceDepth].
 */
+ (void) addCondensedLogCallbacksForClass:(Class) cls
                           callStackDepth:(int) callStackDepth;

/** Convenience method to log a standard format stack trace to every memory management
 * call that instances of the specified class make.
 *
 * The logging output will look similar to this (assuming callStackDepth = 3):
 * \code
2011-09-05 14:08:00.200 MyAwesomeApp[29017:207] <MyView: 0x8105400> RETAIN :  3 ( 3)
3   UIKit                               0x00a5e0a4 -[MyViewController view] + 206
4   UIKit                               0x00a5c482 -[MyViewController contentScrollView] + 42
5   UIKit                               0x00a6cf25 -[UINavigationController _computeAndApplyScrollContentInsetDeltaForViewController:] + 48
   \endcode
 *
 * @param cls The class to log memory management calls for.
 * @param callStackDepth The depth to which to log call stack entries. Note that
 *                       callStackDepth is limited by
 *                       [KSRetainTracker stackTraceDepth].
 */
+ (void) addFullLogCallbacksForClass:(Class) cls
                      callStackDepth:(int) callStackDepth;

/** Remove all callbacks registered to a class.
 *
 * @param cls The class to remove callbacks for.
 */
+ (void) removeCallbacksForClass:(Class) cls;

/** Remove callbacks for the speficied methods in the specified class.
 *
 * @param cls The class to remove callbacks for.
 * @param method The method to remove callbacks for.
 */
+ (void) removeCallbacksForClass:(Class) cls method:(KSRTMethod) method;

/** Remove all callbacks for all classes.
 */
+ (void) removeCallbacksForAllClasses;

@end
