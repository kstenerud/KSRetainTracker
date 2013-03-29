//
//  KSLeakTracker.m
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

#import "KSLeakTracker.h"
#import "KSRetainTracker.h"
#import "KSRTLifecycleMonitor+Private.h"


@implementation KSLeakTracker

static NSMutableDictionary* _monitorsByTracker = nil; // Key: KSRTObjectTracker, Value: KSRTLifecycleMonitor

+ (void) initialize
{
    _monitorsByTracker = [[NSMutableDictionary dictionaryWithCapacity:50] retain];
}

+ (KSRTLifecycleMonitor*) getOrCreateMonitorForTracker:(KSRTObjectTracker*) tracker
{
    NSParameterAssert(_monitorsByTracker);
    KSRTLifecycleMonitor* monitor = [_monitorsByTracker objectForKey:tracker];
    if(monitor == nil)
    {
        monitor = [KSRTLifecycleMonitor monitorForTracker:tracker];
        [_monitorsByTracker setObject:monitor forKey:tracker];
    }
    
    return monitor;
}

+ (void) removeMonitorForTracker:(KSRTObjectTracker*) tracker
{
    [_monitorsByTracker removeObjectForKey:tracker];
}

+ (void) monitorClass:(Class) cls
{
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         KSRTLifecycleMonitor* monitor = [self getOrCreateMonitorForTracker:tracker];
         [monitor notifyMethodCall:KSRTMethodAlloc callStack:callStack];
     } forClass:cls method:KSRTMethodAlloc];

    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         KSRTLifecycleMonitor* monitor = [self getOrCreateMonitorForTracker:tracker];
         [monitor notifyMethodCall:KSRTMethodStealthAlloc callStack:callStack];
     } forClass:cls method:KSRTMethodStealthAlloc];
    
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         KSRTLifecycleMonitor* monitor = [self getOrCreateMonitorForTracker:tracker];
         [monitor notifyMethodCall:KSRTMethodRetain callStack:callStack];
     } forClass:cls method:KSRTMethodRetain];
    
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         KSRTLifecycleMonitor* monitor = [self getOrCreateMonitorForTracker:tracker];
         [monitor notifyMethodCall:KSRTMethodRelease callStack:callStack];
     } forClass:cls method:KSRTMethodRelease];
    
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         KSRTLifecycleMonitor* monitor = [self getOrCreateMonitorForTracker:tracker];
         [monitor notifyMethodCall:KSRTMethodAutorelease callStack:callStack];
     } forClass:cls method:KSRTMethodAutorelease];
    
    [KSRetainTracker addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         #pragma unused(callStack)
         [self removeMonitorForTracker:tracker];
     } forClass:cls method:KSRTMethodDealloc];
}

+ (NSArray*) aliveMonitors
{
    return [_monitorsByTracker allValues];
}

@end
