//
//  KSRTObjectTracker.h
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


/**
 * Tracks an object during its lifecycle, maintaining the retain count and
 * autorelease count.
 *
 * Note: Notifications for memory management operations occur BEFORE the
 *       operation proceeds!
 *       This means that the object's official (pre-operation) retain count
 *       will be different from the tracker's effective (post-operation) retain
 *       count.
 */
@interface KSRTObjectTracker: NSObject <NSCopying>
{
    /** \cond */
    id _object;
    int _currentRetainCount;
    int _currentAutoreleaseCount;
    /** \endcond */
}

/** The object being tracked. */
@property(nonatomic,readonly,assign) id object; // Weak reference

/** The current retain count. */
@property(nonatomic,readonly,assign) int currentRetainCount;

/** The current number of pending autoreleases. */
@property(nonatomic,readonly,assign) int currentAutoreleaseCount;

/** The "effective" retain count, taking into account pending autoreleases. */
@property(nonatomic,readonly,assign) int effectiveRetainCount;

@end
