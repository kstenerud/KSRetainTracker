//
//  KSRTLifecycleMonitor.h
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

/**
 * Represents a memory management operation, with call stack.
 */
@interface KSRTMMOperation: NSObject
{
    /** \cond */
    KSRTMethod _method;
    NSArray* _callStack;
    int _currentRetainCount;
    int _currentAutoreleaseCount;
    /** \endcond */
}

/** The memory management method used */
@property(nonatomic,readonly,assign) KSRTMethod method;

/** The call stack leading up to the method call (Type = KSRTCallStackEntry) */
@property(nonatomic,readonly,retain) NSArray* callStack;

/** The current retain count at the time of the call. */
@property(nonatomic,readonly,assign) int currentRetainCount;

/** The current number of pending autoreleases at the time of the call. */
@property(nonatomic,readonly,assign) int currentAutoreleaseCount;

@end


/**
 * Monitors an object during its lifecycle.
 */
@interface KSRTLifecycleMonitor : NSObject
{
    /** \cond */
    KSRTObjectTracker* _tracker;
    NSMutableArray* _mmOperations;
    /** \endcond */
}

/** The tracker that is tracking our object. */
@property(nonatomic,readonly,retain) KSRTObjectTracker* tracker;

/** All memory management operations that have occurred on this object (Type = KSRTMMOperation) */
@property(nonatomic,readonly,retain) NSArray* mmOperations;

@end
