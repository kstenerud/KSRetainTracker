//
//  KSRTRetainTrackerTests.m
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
#import "KSRetainTracker.h"
#import "KSRetainTracker+Private.h"


@interface KSRTRetainTrackerTests : SenTestCase {} @end

SYNTHESIZE_IDENTICAL_SUBCLASS(MySubclass, NSObject);

@implementation KSRTRetainTrackerTests

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

- (void) testGenerateStackTrace
{
    [KSRetainTracker setStackTraceDepth:50];
    NSArray* stackTrace = [KSRetainTracker generateTraceWithMaxEntries:2 skipFrames:0];
    STAssertNotNil(stackTrace, @"");
    STAssertTrue([stackTrace count] > 0, @"Stack trace was empty");
}

- (void) testGenerateStackTrace2
{
    [KSRetainTracker setStackTraceDepth:0];
    NSArray* stackTrace = [KSRetainTracker generateTraceWithMaxEntries:2 skipFrames:0];
    STAssertNotNil(stackTrace, @"");
    STAssertTrue([stackTrace count] > 0, @"Stack trace was empty");
}

- (void) testGenerateStackTrace3
{
    [KSRetainTracker setStackTraceDepth:50];
    NSArray* stackTrace = [KSRetainTracker generateTraceWithMaxEntries:1 skipFrames:4];
    STAssertNotNil(stackTrace, @"");
    STAssertTrue([stackTrace count] > 0, @"Stack trace was empty");
}

- (void) testNotifyAlloc
{
    __block BOOL called = NO;
    
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack) {
        called = YES;
        STAssertNotNil(tracker, @"");
        STAssertNotNil(callStack, @"");
        STAssertTrue([callStack count] > 0, @"Stack was empty");
    } forClass:[MySubclass class] method:KSRTMethodAlloc];
    
    [KSRetainTracker setEnabled:YES];
    MySubclass* object = [[MySubclass alloc] init];
    STAssertTrue(called, @"");
    [object release];
}

- (void) testNotifyAllocDisabled
{
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack) {
        STFail(@"Should not have been called");
    } forClass:[MySubclass class] method:KSRTMethodAlloc];
    
    [KSRetainTracker setEnabled:YES];
    [KSRetainTracker setEnabled:NO];
    MySubclass* object = [[MySubclass alloc] init];
    [object release];
}

- (void) testNotifyStealthAlloc
{
    __block BOOL called = NO;
    
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack) {
        called = YES;
        STAssertNotNil(tracker, @"");
        STAssertNotNil(callStack, @"");
        STAssertTrue([callStack count] > 0, @"Stack was empty");
    } forClass:[MySubclass class] method:KSRTMethodStealthAlloc];
    
    MySubclass* object = [[MySubclass alloc] init];
    [KSRetainTracker setEnabled:YES];
    [object retain];
    STAssertTrue(called, @"");
    [object release];
    [object release];
}

- (void) testNotifyStealthAllocDisabled
{
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack) {
        STFail(@"Should not have been called");
    } forClass:[MySubclass class] method:KSRTMethodStealthAlloc];
    
    MySubclass* object = [[MySubclass alloc] init];
    [KSRetainTracker setEnabled:YES];
    [KSRetainTracker setEnabled:NO];
    [object retain];
    [object release];
    [object release];
}

- (void) testNotifyRetain
{
    __block BOOL called = NO;
    
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack) {
        called = YES;
        STAssertNotNil(tracker, @"");
        STAssertNotNil(callStack, @"");
        STAssertTrue([callStack count] > 0, @"Stack was empty");
    } forClass:[MySubclass class] method:KSRTMethodRetain];
    
    MySubclass* object = [[MySubclass alloc] init];
    [KSRetainTracker setEnabled:YES];
    [object retain];
    STAssertTrue(called, @"");
    [object release];
    [object release];
}

- (void) testNotifyRetainDisabled
{
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack) {
        STFail(@"Should not have been called");
    } forClass:[MySubclass class] method:KSRTMethodRetain];
    
    MySubclass* object = [[MySubclass alloc] init];
    [KSRetainTracker setEnabled:YES];
    [KSRetainTracker setEnabled:NO];
    [object retain];
    [object release];
    [object release];
}

- (void) testNotifyRelease
{
    __block BOOL called = NO;
    
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack) {
        called = YES;
        STAssertNotNil(tracker, @"");
        STAssertNotNil(callStack, @"");
        STAssertTrue([callStack count] > 0, @"Stack was empty");
    } forClass:[MySubclass class] method:KSRTMethodRelease];
    
    MySubclass* object = [[MySubclass alloc] init];
    [KSRetainTracker setEnabled:YES];
    [object release];
    STAssertTrue(called, @"");
}

- (void) testNotifyReleaseDisabled
{
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack) {
        STFail(@"Should not have been called");
    } forClass:[MySubclass class] method:KSRTMethodRelease];
    
    MySubclass* object = [[MySubclass alloc] init];
    [KSRetainTracker setEnabled:YES];
    [KSRetainTracker setEnabled:NO];
    [object release];
}

- (void) testNotifyAutorelease
{
    __block BOOL called = NO;
    
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack) {
        called = YES;
        STAssertNotNil(tracker, @"");
        STAssertNotNil(callStack, @"");
        STAssertTrue([callStack count] > 0, @"Stack was empty");
    } forClass:[MySubclass class] method:KSRTMethodAutorelease];
    
    MySubclass* object = [[MySubclass alloc] init];
    [KSRetainTracker setEnabled:YES];
    [object autorelease];
    STAssertTrue(called, @"");
}

- (void) testNotifyAutoreleaseDisabled
{
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack) {
        STFail(@"Should not have been called");
    } forClass:[MySubclass class] method:KSRTMethodAutorelease];
    
    MySubclass* object = [[MySubclass alloc] init];
    [KSRetainTracker setEnabled:YES];
    [KSRetainTracker setEnabled:NO];
    [object autorelease];
}

- (void) testNotifyDealloc
{
    __block BOOL called = NO;
    
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack) {
        called = YES;
        STAssertNotNil(tracker, @"");
        STAssertNotNil(callStack, @"");
        STAssertTrue([callStack count] > 0, @"Stack was empty");
    } forClass:[MySubclass class] method:KSRTMethodDealloc];

    [KSRetainTracker setEnabled:YES];
    MySubclass* object = [[MySubclass alloc] init];
    [object release];
    STAssertTrue(called, @"");
}

- (void) testNotifyDeallocDisabled
{
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack) {
        STFail(@"Should not have been called");
    } forClass:[MySubclass class] method:KSRTMethodDealloc];
    
    [KSRetainTracker setEnabled:YES];
    [KSRetainTracker setEnabled:NO];
    MySubclass* object = [[MySubclass alloc] init];
    [object release];
}

@end
