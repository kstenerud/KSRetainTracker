//
//  KSRTObjectTracker+Private.h
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


/** \cond */
@interface KSRTObjectTrackerCallbacks: NSObject
{
    NSMutableArray* _onAlloc;
    NSMutableArray* _onStealthAlloc;
    NSMutableArray* _onRetain;
    NSMutableArray* _onRelease;
    NSMutableArray* _onAutorelease;
    NSMutableArray* _onDealloc;
}

+ (KSRTObjectTrackerCallbacks*) callbacks;


- (void) addAllocCallback:(KSRTCallback) callback;
- (void) addStealthAllocCallback:(KSRTCallback) callback;
- (void) addRetainCallback:(KSRTCallback) callback;
- (void) addReleaseCallback:(KSRTCallback) callback;
- (void) addAutoreleaseCallback:(KSRTCallback) callback;
- (void) addDeallocCallback:(KSRTCallback) callback;

- (void) removeAllocCallbacks;
- (void) removeStealthAllocCallbacks;
- (void) removeRetainCallbacks;
- (void) removeReleaseCallbacks;
- (void) removeAutoreleaseCallbacks;
- (void) removeDeallocCallbacks;
- (void) removeAllCallbacks;

- (void) performAllocCallbackWithTracker:(KSRTObjectTracker*) tracker callStack:(NSArray*) callStack;
- (void) performStealthAllocCallbackWithTracker:(KSRTObjectTracker*) tracker callStack:(NSArray*) callStack;
- (void) performRetainCallbackWithTracker:(KSRTObjectTracker*) tracker callStack:(NSArray*) callStack;
- (void) performReleaseCallbackWithTracker:(KSRTObjectTracker*) tracker callStack:(NSArray*) callStack;
- (void) performAutoreleaseCallbackWithTracker:(KSRTObjectTracker*) tracker callStack:(NSArray*) callStack;
- (void) performDeallocCallbackWithTracker:(KSRTObjectTracker*) tracker callStack:(NSArray*) callStack;

@end



@interface KSRTObjectTracker ()

- (void) notifyAllocWithCallStack:(NSArray*) callStack;
- (void) notifyStealthAllocWithCallStack:(NSArray*) callStack;
- (void) notifyRetainWithCallStack:(NSArray*) callStack;
- (void) notifyReleaseWithCallStack:(NSArray*) callStack;
- (void) notifyAutoreleaseWithCallStack:(NSArray*) callStack;
- (void) notifyDeallocWithCallStack:(NSArray*) callStack;

+ (KSRTObjectTracker*) trackerWithObject:(id) object
                               callbacks:(KSRTObjectTrackerCallbacks*) callbacks;

- (id) initWithObject:(id) object
            callbacks:(KSRTObjectTrackerCallbacks*) callbacks;

@end
/** \endcond */
