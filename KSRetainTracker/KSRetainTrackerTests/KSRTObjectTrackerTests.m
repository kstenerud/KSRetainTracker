//
//  KSRTObjectTrackerTests.m
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
#import "KSRTObjectTracker+Private.h"

@interface KSRTObjectTrackerTests : SenTestCase {} @end


@implementation KSRTObjectTrackerTests

- (void) testObject
{
    NSObject* object = [[[NSObject alloc] init] autorelease];
    KSRTObjectTracker* tracker = [KSRTObjectTracker trackerWithObject:object callbacks:nil];
    
    STAssertEquals(object, tracker.object, @"");
}

- (void) testNotifyAlloc
{
    NSObject* object = [[[NSObject alloc] init] autorelease];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block KSRTObjectTracker* compareTracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    __block NSArray* compareCallStack = [NSArray array];
    __block BOOL called = NO;
    
    [callbacks addAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(compareTracker, tracker, @"");
         STAssertEquals(compareCallStack, callStack, @"");
     }];
    
    [compareTracker notifyAllocWithCallStack:compareCallStack];
    STAssertTrue(called, @"");
}

- (void) testNotifyStealthAlloc
{
    NSObject* object = [[[NSObject alloc] init] autorelease];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block KSRTObjectTracker* compareTracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    __block NSArray* compareCallStack = [NSArray array];
    __block BOOL called = NO;
    
    [callbacks addStealthAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(compareTracker, tracker, @"");
         STAssertEquals(compareCallStack, callStack, @"");
     }];
    
    [compareTracker notifyStealthAllocWithCallStack:compareCallStack];
    STAssertTrue(called, @"");
}

- (void) testNotifyRetain
{
    NSObject* object = [[[NSObject alloc] init] autorelease];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block KSRTObjectTracker* compareTracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    __block NSArray* compareCallStack = [NSArray array];
    __block BOOL called = NO;
    
    [callbacks addRetainCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(compareTracker, tracker, @"");
         STAssertEquals(compareCallStack, callStack, @"");
     }];
    
    [compareTracker notifyRetainWithCallStack:compareCallStack];
    STAssertTrue(called, @"");
}

- (void) testNotifyRelease
{
    NSObject* object = [[[NSObject alloc] init] autorelease];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block KSRTObjectTracker* compareTracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    __block NSArray* compareCallStack = [NSArray array];
    __block BOOL called = NO;
    
    [callbacks addReleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(compareTracker, tracker, @"");
         STAssertEquals(compareCallStack, callStack, @"");
     }];
    
    [compareTracker notifyReleaseWithCallStack:compareCallStack];
    STAssertTrue(called, @"");
}

- (void) testNotifyAutorelease
{
    NSObject* object = [[[NSObject alloc] init] autorelease];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block KSRTObjectTracker* compareTracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    __block NSArray* compareCallStack = [NSArray array];
    __block BOOL called = NO;
    
    [callbacks addAutoreleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(compareTracker, tracker, @"");
         STAssertEquals(compareCallStack, callStack, @"");
     }];
    
    [compareTracker notifyAutoreleaseWithCallStack:compareCallStack];
    STAssertTrue(called, @"");
}

- (void) testNotifyDealloc
{
    NSObject* object = [[[NSObject alloc] init] autorelease];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block KSRTObjectTracker* compareTracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    __block NSArray* compareCallStack = [NSArray array];
    __block BOOL called = NO;
    
    [callbacks addDeallocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(compareTracker, tracker, @"");
         STAssertEquals(compareCallStack, callStack, @"");
     }];
    
    [compareTracker notifyDeallocWithCallStack:compareCallStack];
    STAssertTrue(called, @"");
}


- (void) testAlloc
{
    NSObject* object = [[NSObject alloc] init];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    KSRTObjectTracker* tracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];

    __block BOOL called = NO;

    [callbacks addAllocCallback:^(KSRTObjectTracker *tracker2, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(tracker2.currentRetainCount, 1, @"");
         STAssertEquals(tracker2.currentAutoreleaseCount, 0, @"");
         STAssertEquals(tracker2.effectiveRetainCount, 1, @"");
     }];

    [tracker notifyAllocWithCallStack:nil];
    STAssertTrue(called, @"");
    [object release];
}

- (void) testAlloc2
{
    NSObject* object = [[NSObject alloc] init];
    [object retain];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    KSRTObjectTracker* tracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addAllocCallback:^(KSRTObjectTracker *tracker2, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(tracker2.currentRetainCount, 2, @"");
         STAssertEquals(tracker2.currentAutoreleaseCount, 0, @"");
         STAssertEquals(tracker2.effectiveRetainCount, 2, @"");
     }];
    
    [tracker notifyAllocWithCallStack:nil];
    STAssertTrue(called, @"");
    [object release];
    [object release];
}

- (void) testStealthAlloc
{
    NSObject* object = [[NSObject alloc] init];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    KSRTObjectTracker* tracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addStealthAllocCallback:^(KSRTObjectTracker *tracker2, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(tracker2.currentRetainCount, 1, @"");
         STAssertEquals(tracker2.currentAutoreleaseCount, 0, @"");
         STAssertEquals(tracker2.effectiveRetainCount, 1, @"");
     }];
    
    [tracker notifyStealthAllocWithCallStack:nil];
    STAssertTrue(called, @"");
    [object release];
}

- (void) testStealthAlloc2
{
    NSObject* object = [[NSObject alloc] init];
    [object retain];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    KSRTObjectTracker* tracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addStealthAllocCallback:^(KSRTObjectTracker *tracker2, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(tracker2.currentRetainCount, 2, @"");
         STAssertEquals(tracker2.currentAutoreleaseCount, 0, @"");
         STAssertEquals(tracker2.effectiveRetainCount, 2, @"");
     }];
    
    [tracker notifyStealthAllocWithCallStack:nil];
    STAssertTrue(called, @"");
    [object release];
    [object release];
}

- (void) testRetain
{
    NSObject* object = [[NSObject alloc] init];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    KSRTObjectTracker* tracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addRetainCallback:^(KSRTObjectTracker *tracker2, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(tracker2.currentRetainCount, 2, @"");
         STAssertEquals(tracker2.currentAutoreleaseCount, 0, @"");
         STAssertEquals(tracker2.effectiveRetainCount, 2, @"");
     }];
    
    [tracker notifyAllocWithCallStack:nil];
    [tracker notifyRetainWithCallStack:nil];
    STAssertTrue(called, @"");
    [object release];
}

- (void) testRelease
{
    NSObject* object = [[NSObject alloc] init];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    KSRTObjectTracker* tracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addReleaseCallback:^(KSRTObjectTracker *tracker2, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(tracker2.currentRetainCount, 0, @"");
         STAssertEquals(tracker2.currentAutoreleaseCount, 0, @"");
         STAssertEquals(tracker2.effectiveRetainCount, 0, @"");
     }];
    
    [tracker notifyAllocWithCallStack:nil];
    [tracker notifyReleaseWithCallStack:nil];
    STAssertTrue(called, @"");
    [object release];
}

- (void) testAutorelease
{
    NSObject* object = [[NSObject alloc] init];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    KSRTObjectTracker* tracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addAutoreleaseCallback:^(KSRTObjectTracker *tracker2, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(tracker2.currentRetainCount, 1, @"");
         STAssertEquals(tracker2.currentAutoreleaseCount, 1, @"");
         STAssertEquals(tracker2.effectiveRetainCount, 0, @"");
     }];
    
    [tracker notifyAllocWithCallStack:nil];
    [tracker notifyAutoreleaseWithCallStack:nil];
    STAssertTrue(called, @"");
    [object release];
}

- (void) testDealloc
{
    NSObject* object = [[NSObject alloc] init];
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    KSRTObjectTracker* tracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addDeallocCallback:^(KSRTObjectTracker *tracker2, NSArray *callStack)
     {
         called = YES;
         // Dealloc handler reads retainCount from the object, but the object in this
         // test is not deallocated, nor can we test when it is deallocated.
         STAssertEquals(tracker2.currentRetainCount, 1, @"");
         STAssertEquals(tracker2.currentAutoreleaseCount, 0, @"");
         STAssertEquals(tracker2.effectiveRetainCount, 1, @"");
     }];
    
    [tracker notifyDeallocWithCallStack:nil];
    STAssertTrue(called, @"");
    [object release];
}

@end
