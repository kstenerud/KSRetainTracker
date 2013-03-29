//
//  KSRTObjectTrackerCallbacksTests.m
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

@interface KSRTObjectTrackerCallbacksTests : SenTestCase {} @end


@implementation KSRTObjectTrackerCallbacksTests

- (void) testTrackerAndCallStack
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];

    __block KSRTObjectTracker* compareTracker = [KSRTObjectTracker trackerWithObject:nil callbacks:callbacks];
    __block NSArray* compareCallStack = [NSArray array];
    __block BOOL called = NO;
    
    [callbacks addAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
         STAssertEquals(compareTracker, tracker, @"");
         STAssertEquals(compareCallStack, callStack, @"");
     }];
    
    [callbacks performAllocCallbackWithTracker:compareTracker callStack:compareCallStack];
    STAssertTrue(called, @"");
}

- (void) testOneAllocCallback
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
     }];
    
    [callbacks performAllocCallbackWithTracker:nil callStack:nil];
    STAssertTrue(called, @"");
}

- (void) testMultipleAllocCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called1 = NO;
    __block BOOL called2 = NO;
    
    [callbacks addAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called1 = YES;
     }];
    
    [callbacks addAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called2 = YES;
     }];
    
    [callbacks performAllocCallbackWithTracker:nil callStack:nil];
    STAssertTrue(called1, @"");
    STAssertTrue(called2, @"");
}

- (void) testRemoveAllocCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called1 = NO;
    __block BOOL called2 = NO;
    
    [callbacks addAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called1 = YES;
     }];
    
    [callbacks addAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called2 = YES;
     }];
    
    [callbacks removeAllocCallbacks];
    [callbacks performAllocCallbackWithTracker:nil callStack:nil];
    STAssertFalse(called1, @"");
    STAssertFalse(called2, @"");
}

- (void) testOneStealthAllocCallback
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addStealthAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
     }];
    
    [callbacks performStealthAllocCallbackWithTracker:nil callStack:nil];
    STAssertTrue(called, @"");
}

- (void) testMultipleStealthAllocCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called1 = NO;
    __block BOOL called2 = NO;
    
    [callbacks addStealthAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called1 = YES;
     }];
    
    [callbacks addStealthAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called2 = YES;
     }];
    
    [callbacks performStealthAllocCallbackWithTracker:nil callStack:nil];
    STAssertTrue(called1, @"");
    STAssertTrue(called2, @"");
}

- (void) testRemoveStealthAllocCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called1 = NO;
    __block BOOL called2 = NO;
    
    [callbacks addStealthAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called1 = YES;
     }];
    
    [callbacks addStealthAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called2 = YES;
     }];
    
    [callbacks removeStealthAllocCallbacks];
    [callbacks performStealthAllocCallbackWithTracker:nil callStack:nil];
    STAssertFalse(called1, @"");
    STAssertFalse(called2, @"");
}

- (void) testOneRetainCallback
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addRetainCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
     }];
    
    [callbacks performRetainCallbackWithTracker:nil callStack:nil];
    STAssertTrue(called, @"");
}

- (void) testMultipleRetainCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called1 = NO;
    __block BOOL called2 = NO;
    
    [callbacks addRetainCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called1 = YES;
     }];
    
    [callbacks addRetainCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called2 = YES;
     }];
    
    [callbacks performRetainCallbackWithTracker:nil callStack:nil];
    STAssertTrue(called1, @"");
    STAssertTrue(called2, @"");
}

- (void) testRemoveRetainCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called1 = NO;
    __block BOOL called2 = NO;
    
    [callbacks addRetainCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called1 = YES;
     }];
    
    [callbacks addRetainCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called2 = YES;
     }];
    
    [callbacks removeRetainCallbacks];
    [callbacks performRetainCallbackWithTracker:nil callStack:nil];
    STAssertFalse(called1, @"");
    STAssertFalse(called2, @"");
}

- (void) testOneReleaseCallback
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addReleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
     }];
    
    [callbacks performReleaseCallbackWithTracker:nil callStack:nil];
    STAssertTrue(called, @"");
}

- (void) testMultipleReleaseCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called1 = NO;
    __block BOOL called2 = NO;
    
    [callbacks addReleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called1 = YES;
     }];
    
    [callbacks addReleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called2 = YES;
     }];
    
    [callbacks performReleaseCallbackWithTracker:nil callStack:nil];
    STAssertTrue(called1, @"");
    STAssertTrue(called2, @"");
}

- (void) testRemoveReleaseCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called1 = NO;
    __block BOOL called2 = NO;
    
    [callbacks addReleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called1 = YES;
     }];
    
    [callbacks addReleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called2 = YES;
     }];
    
    [callbacks removeReleaseCallbacks];
    [callbacks performReleaseCallbackWithTracker:nil callStack:nil];
    STAssertFalse(called1, @"");
    STAssertFalse(called2, @"");
}

- (void) testOneAutoreleaseCallback
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addAutoreleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
     }];
    
    [callbacks performAutoreleaseCallbackWithTracker:nil callStack:nil];
    STAssertTrue(called, @"");
}

- (void) testMultipleAutoreleaseCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called1 = NO;
    __block BOOL called2 = NO;
    
    [callbacks addAutoreleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called1 = YES;
     }];
    
    [callbacks addAutoreleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called2 = YES;
     }];
    
    [callbacks performAutoreleaseCallbackWithTracker:nil callStack:nil];
    STAssertTrue(called1, @"");
    STAssertTrue(called2, @"");
}

- (void) testRemoveAutoreleaseCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called1 = NO;
    __block BOOL called2 = NO;
    
    [callbacks addAutoreleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called1 = YES;
     }];
    
    [callbacks addAutoreleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called2 = YES;
     }];
    
    [callbacks removeAutoreleaseCallbacks];
    [callbacks performAutoreleaseCallbackWithTracker:nil callStack:nil];
    STAssertFalse(called1, @"");
    STAssertFalse(called2, @"");
}

- (void) testOneDeallocCallback
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called = NO;
    
    [callbacks addDeallocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called = YES;
     }];
    
    [callbacks performDeallocCallbackWithTracker:nil callStack:nil];
    STAssertTrue(called, @"");
}

- (void) testMultipleCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called1 = NO;
    __block BOOL called2 = NO;
    
    [callbacks addDeallocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called1 = YES;
     }];
    
    [callbacks addDeallocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called2 = YES;
     }];
    
    [callbacks performDeallocCallbackWithTracker:nil callStack:nil];
    STAssertTrue(called1, @"");
    STAssertTrue(called2, @"");
}

- (void) testRemoveDeallocCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL called1 = NO;
    __block BOOL called2 = NO;
    
    [callbacks addDeallocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called1 = YES;
     }];
    
    [callbacks addDeallocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         called2 = YES;
     }];
    
    [callbacks removeDeallocCallbacks];
    [callbacks performDeallocCallbackWithTracker:nil callStack:nil];
    STAssertFalse(called1, @"");
    STAssertFalse(called2, @"");
}

- (void) testRemoveAllCallbacks
{
    KSRTObjectTrackerCallbacks* callbacks = [KSRTObjectTrackerCallbacks callbacks];
    
    __block BOOL calledAlloc = NO;
    __block BOOL calledStealthAlloc = NO;
    __block BOOL calledRetain = NO;
    __block BOOL calledRelease = NO;
    __block BOOL calledAutorelease = NO;
    __block BOOL calledDealloc = NO;
    
    [callbacks addAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         calledAlloc = YES;
     }];
    
    [callbacks addStealthAllocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         calledStealthAlloc = YES;
     }];
    
    [callbacks addRetainCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         calledRetain = YES;
     }];
    
    [callbacks addReleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         calledRelease = YES;
     }];
    
    [callbacks addAutoreleaseCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         calledAutorelease = YES;
     }];
    
    [callbacks addDeallocCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         calledDealloc = YES;
     }];
    
    [callbacks removeAllCallbacks];
    [callbacks performAllocCallbackWithTracker:nil callStack:nil];
    [callbacks performStealthAllocCallbackWithTracker:nil callStack:nil];
    [callbacks performRetainCallbackWithTracker:nil callStack:nil];
    [callbacks performReleaseCallbackWithTracker:nil callStack:nil];
    [callbacks performAutoreleaseCallbackWithTracker:nil callStack:nil];
    [callbacks performDeallocCallbackWithTracker:nil callStack:nil];

    STAssertFalse(calledAlloc, @"");
    STAssertFalse(calledStealthAlloc, @"");
    STAssertFalse(calledRetain, @"");
    STAssertFalse(calledRelease, @"");
    STAssertFalse(calledAutorelease, @"");
    STAssertFalse(calledDealloc, @"");
    
}

@end
