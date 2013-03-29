//
//  CallStackEntryTests.m
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
#import "KSRTCallStackEntry.h"

@interface KSRTCallStackEntryTests : SenTestCase {} @end


@implementation KSRTCallStackEntryTests

- (void) testInstanceSelector
{
    KSRTCallStackEntry* entry = [KSRTCallStackEntry entryWithTraceLine:@"0   KSRTTempTests                       0x00d62908 -[KSRTRetainTrackerTests testNotifyAlloc] + 1048"];
    STAssertEquals(entry.traceEntryNumber, 0, @"");
    STAssertEqualObjects(entry.library, @"KSRTTempTests", @"");
    STAssertEquals(entry.address, 0x00d62908u, @"");
    STAssertEqualObjects(entry.objectClass, @"KSRTRetainTrackerTests", @"");
    STAssertFalse(entry.isClassLevelSelector, @"");
    STAssertEqualObjects(entry.selectorName, @"testNotifyAlloc", @"");
    STAssertEquals(entry.offset, 1048, @"");
}

- (void) testClassSelector
{
    KSRTCallStackEntry* entry = [KSRTCallStackEntry entryWithTraceLine:@"1   KSRTTempTests                       0x00d624ee +[KSRTRetainTracker generateTraceWithMaxEntries:skipFrames:] + 126"];
    STAssertEquals(entry.traceEntryNumber, 1, @"");
    STAssertEqualObjects(entry.library, @"KSRTTempTests", @"");
    STAssertEquals(entry.address, 0x00d624eeu, @"");
    STAssertEqualObjects(entry.objectClass, @"KSRTRetainTracker", @"");
    STAssertTrue(entry.isClassLevelSelector, @"");
    STAssertEqualObjects(entry.selectorName, @"generateTraceWithMaxEntries:skipFrames:", @"");
    STAssertEquals(entry.offset, 126, @"");
}

- (void) testFunction
{
    KSRTCallStackEntry* entry = [KSRTCallStackEntry entryWithTraceLine:@"2   CoreFoundation                      0x00410c7d __invoking___ + 29"];
    STAssertEquals(entry.traceEntryNumber, 2, @"");
    STAssertEqualObjects(entry.library, @"CoreFoundation", @"");
    STAssertEquals(entry.address, 0x00410c7du, @"");
    STAssertNil(entry.objectClass, @"");
    STAssertFalse(entry.isClassLevelSelector, @"");
    STAssertEqualObjects(entry.selectorName, @"__invoking___", @"");
    STAssertEquals(entry.offset, 29, @"");
}

@end
