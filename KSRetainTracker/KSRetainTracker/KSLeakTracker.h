//
//  KSLeakTracker.h
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
#import "KSRTLifecycleMonitor.h"


/**
 * Keeps a reference to all alive tracked objects to help diagnose leaks.
 *
 * Objects are added to the "alive" pool upon an alloc or stealth alloc,
 * and then are removed from the "alive" pool when they dealloc.
 *
 * By checking the aliveTrackers list, you can see which objects are still
 * alive when they shouldn't be, and then check the lifecycle monitor to see
 * all memory management operations the object went through, with stack traces
 * for each operation.
 */
@interface KSLeakTracker : NSObject
{
}

/** Add a class whose objects are to have their lifecycles monitored.
 *
 * @param cls The class to monitor.
 */
+ (void) monitorClass:(Class) cls;


/** Get a list of monitors whose objects are still alive.
 *
 * @return A list of KSRTLifecycleMonitor
 */
+ (NSArray*) aliveMonitors;

@end
