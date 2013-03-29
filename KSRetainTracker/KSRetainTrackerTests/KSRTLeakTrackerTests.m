//
//  KSRTLeakTrackerTests.m
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

#import <SenTestingKit/SenTestingKit.h>
#import "KSLeakTracker.h"
#import "KSRetainTracker.h"

SYNTHESIZE_IDENTICAL_SUBCLASS(MySubclass2, NSObject);
SYNTHESIZE_IDENTICAL_SUBCLASS(MySubclass3, NSObject);

@interface KSRTLeakTrackerTests : SenTestCase {} @end


@implementation KSRTLeakTrackerTests

static int _originalStackTraceDepth;

- (void)setUp
{
    [super setUp];
    
    _originalStackTraceDepth = [KSRetainTracker stackTraceDepth];
    [KSRetainTracker setEnabled:NO];
}

- (void)tearDown
{
    [KSRetainTracker setEnabled:NO];
    [KSRetainTracker setStackTraceDepth:_originalStackTraceDepth];
    [KSRetainTracker removeCallbacksForAllClasses];
    
    [super tearDown];
}

- (void) testNonLeak
{
    [KSLeakTracker monitorClass:[MySubclass2 class]];
    [KSRetainTracker setEnabled:YES];
    MySubclass2* instance = [[MySubclass2 alloc] init];
    [instance release];
    NSArray* alive = [KSLeakTracker aliveMonitors];
    STAssertTrue([alive count] == 0, @"Should be no items alive");
}

- (void) testLeak
{
    [KSLeakTracker monitorClass:[MySubclass2 class]];
    [KSRetainTracker setEnabled:YES];
    MySubclass2* instance = [[MySubclass2 alloc] init];
    NSArray* alive = [KSLeakTracker aliveMonitors];
    STAssertTrue([alive count] == 1, @"Should only be 1 item in alive");
    [instance release];
}

- (void) testAlloc
{
    [KSLeakTracker monitorClass:[MySubclass2 class]];
    [KSRetainTracker setEnabled:YES];
    MySubclass2* instance = [[MySubclass2 alloc] init];
    NSArray* alive = [KSLeakTracker aliveMonitors];
    STAssertTrue([alive count] == 1, @"Should only be 1 item in alive");
    KSRTLifecycleMonitor* monitor = [alive objectAtIndex:0];
    STAssertTrue([monitor.mmOperations count] == 1, @"Should only be 1 operation");
    KSRTMMOperation* operation = [monitor.mmOperations objectAtIndex:0];
    STAssertEquals(operation.method, KSRTMethodAlloc, @"Should be method 'Alloc'");
    
    [instance release];
}

- (void) testStealthAlloc
{
    MySubclass2* instance = [[MySubclass2 alloc] init];
    [KSLeakTracker monitorClass:[MySubclass2 class]];
    [KSRetainTracker setEnabled:YES];
    [instance retain];
    NSArray* alive = [KSLeakTracker aliveMonitors];
    STAssertTrue([alive count] == 1, @"Should only be 1 item in alive");
    KSRTLifecycleMonitor* monitor = [alive objectAtIndex:0];
    STAssertTrue([monitor.mmOperations count] == 2, @"Should only be 2 operations");
    KSRTMMOperation* operation = [monitor.mmOperations objectAtIndex:0];
    STAssertEquals(operation.method, KSRTMethodStealthAlloc, @"Should be method 'StealthAlloc'");
    
    [instance release];
    [instance release];
}

- (void) testRetain
{
    [KSLeakTracker monitorClass:[MySubclass2 class]];
    [KSRetainTracker setEnabled:YES];
    MySubclass2* instance = [[MySubclass2 alloc] init];
    [instance retain];
    NSArray* alive = [KSLeakTracker aliveMonitors];
    STAssertTrue([alive count] == 1, @"Should only be 1 item in alive");
    KSRTLifecycleMonitor* monitor = [alive objectAtIndex:0];
    STAssertTrue([monitor.mmOperations count] == 2, @"Should only be 2 operations");
    KSRTMMOperation* operation = [monitor.mmOperations objectAtIndex:1];
    STAssertEquals(operation.method, KSRTMethodRetain, @"Should be method 'Retain'");
    
    [instance release];
    [instance release];
}

- (void) testRelease
{
    [KSLeakTracker monitorClass:[MySubclass2 class]];
    [KSRetainTracker setEnabled:YES];
    MySubclass2* instance = [[MySubclass2 alloc] init];
    [instance retain];
    [instance release];
    NSArray* alive = [KSLeakTracker aliveMonitors];
    STAssertTrue([alive count] == 1, @"Should only be 1 item in alive");
    KSRTLifecycleMonitor* monitor = [alive objectAtIndex:0];
    STAssertTrue([monitor.mmOperations count] == 3, @"Should only be 3 operations");
    KSRTMMOperation* operation = [monitor.mmOperations objectAtIndex:2];
    STAssertEquals(operation.method, KSRTMethodRelease, @"Should be method 'Release'");
    
    [instance release];
}

- (void) testAutorelease
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [KSLeakTracker monitorClass:[MySubclass2 class]];
    [KSRetainTracker setEnabled:YES];
    MySubclass2* instance = [[MySubclass2 alloc] init];
    [instance retain];
    [instance autorelease];
    NSArray* alive = [KSLeakTracker aliveMonitors];
    STAssertTrue([alive count] == 1, @"Should only be 1 item in alive");
    KSRTLifecycleMonitor* monitor = [alive objectAtIndex:0];
    STAssertTrue([monitor.mmOperations count] == 3, @"Should only be 3 operations");
    KSRTMMOperation* operation = [monitor.mmOperations objectAtIndex:2];
    STAssertEquals(operation.method, KSRTMethodAutorelease, @"Should be method 'Autorelease'");
    
    [instance release];
    [pool release];
}

- (void) test2Classes
{
    [KSLeakTracker monitorClass:[MySubclass2 class]];
    [KSLeakTracker monitorClass:[MySubclass3 class]];
    [KSRetainTracker setEnabled:YES];
    MySubclass2* instance2 = [[MySubclass2 alloc] init];
    MySubclass3* instance3 = [[MySubclass3 alloc] init];
    NSArray* alive = [KSLeakTracker aliveMonitors];
    STAssertTrue([alive count] == 2, @"Should only be 2 items in alive");
    
    [instance2 release];
    [instance3 release];
}

@end
