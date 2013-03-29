//
//  KSRetainTracker.m
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

#import "KSRetainTracker.h"
#import "KSRTObjectTracker+Private.h"
#import "KSRetainTracker+Private.h"
#import <objc/runtime.h>
#include <execinfo.h>
#import <CommonCrypto/CommonDigest.h>


#define kRTAllocSkipFrames 4
#define kRTDeallocSkipFrames 5
#define kRTRetainSkipFrames 3
#define kRTReleaseSkipFrames 3
#define kRTAutoreleaseSkipFrames 3

#define kStackTraceDepth 10

#define kExtraFrames 5


@implementation NSObject (KSRetainTracker)

+ (id) allocWithZone_KSRTOriginal:(NSZone*) zone
{
    id allocedObject = [self allocWithZone_KSRTOriginal:zone];
    [KSRetainTracker notifyAlloc:allocedObject];
    return allocedObject;
}

- (void) dealloc_KSRTOriginal
{
    [KSRetainTracker notifyDealloc:self];
    [self dealloc_KSRTOriginal];
}

- (id) retain_KSRTOriginal
{
    [KSRetainTracker notifyRetain:self];
    return [self retain_KSRTOriginal];
}

- (void) release_KSRTOriginal
{
    [KSRetainTracker notifyRelease:self];
    [self release_KSRTOriginal];
} 

- (id) autorelease_KSRTOriginal
{
    [KSRetainTracker notifyAutorelease:self];
    return [self autorelease_KSRTOriginal];
}

@end



@implementation KSRetainTracker

static NSMutableArray* _trackers = nil;
static NSMutableDictionary* _callbacksByClass = nil;
static BOOL _enabled = NO;
static BOOL _inTrackingMethod = NO;
static int _stackTraceDepth = 0;


+ (void) initialize
{
    _callbacksByClass = [[NSMutableDictionary dictionaryWithCapacity:64] retain];
    _trackers = [[NSMutableArray arrayWithCapacity:512] retain];
    _stackTraceDepth = kStackTraceDepth;
}

+ (NSArray*) generateTraceWithMaxEntries:(int) maxEntries
                              skipFrames:(int) skipFrames
{
    int numFramesToTrace = maxEntries + skipFrames;
	void* callstack[numFramesToTrace + kExtraFrames];
	int maxFrames = backtrace(callstack, numFramesToTrace + kExtraFrames);
	char** symbols = backtrace_symbols(callstack, maxFrames);
	
	NSMutableArray* stackTrace = [NSMutableArray arrayWithCapacity:(NSUInteger)maxFrames];
	for(int i = skipFrames; i < numFramesToTrace && i < maxFrames; i++)
	{
        // Have to explicitly copy because stringWithUTF8String cheats and only references the bytes.
        NSString* traceString = [[NSString stringWithUTF8String:symbols[i]] copy];
        KSRTCallStackEntry* entry = [KSRTCallStackEntry entryWithTraceLine:traceString];
        [traceString release];

        if(
           (
            entry.objectClass == nil &&
            (
             [entry.selectorName isEqualToString:@"CFRetain"] ||
             [entry.selectorName isEqualToString:@"CFRelease"] ||
             [entry.selectorName isEqualToString:@"_CFRelease"]
            )
           ) ||
           (
            entry.objectClass != nil &&
            (
             [entry.selectorName isEqualToString:@"allocWithZone_KSRTOriginal"] ||
             [entry.selectorName isEqualToString:@"dealloc_KSRTOriginal"] ||
             [entry.selectorName isEqualToString:@"retain_KSRTOriginal"] ||
             [entry.selectorName isEqualToString:@"release_KSRTOriginal"] ||
             [entry.selectorName isEqualToString:@"autorelease_KSRTOriginal"]
             )
            )
           )
        {
            numFramesToTrace++;
            continue;
        }
		[stackTrace addObject:entry];
	}
	
	free(symbols);

	return stackTrace;
}

+ (BOOL) enabled
{
    return _enabled;
}

+ (void) setEnabled:(BOOL)value
{
    @synchronized(self)
    {
        if(_enabled != value)
        {
            _enabled = value;
            Class cls = [NSObject class];
            method_exchangeImplementations(class_getClassMethod(cls, @selector(allocWithZone:)),
                                           class_getClassMethod(cls, @selector(allocWithZone_KSRTOriginal:)));
            method_exchangeImplementations(class_getInstanceMethod(cls, @selector(dealloc)),
                                           class_getClassMethod(cls, @selector(dealloc_KSRTOriginal)));
            method_exchangeImplementations(class_getInstanceMethod(cls, @selector(retain)),
                                           class_getClassMethod(cls, @selector(retain_KSRTOriginal)));
            method_exchangeImplementations(class_getInstanceMethod(cls, @selector(release)),
                                           class_getClassMethod(cls, @selector(release_KSRTOriginal)));
            method_exchangeImplementations(class_getInstanceMethod(cls, @selector(autorelease)),
                                           class_getClassMethod(cls, @selector(autorelease_KSRTOriginal)));
        }
    }
}

+ (int) stackTraceDepth
{
    return _stackTraceDepth;
}

+ (void) setStackTraceDepth:(int) stackDepth
{
    _stackTraceDepth = stackDepth;
}

+ (KSRTObjectTrackerCallbacks*) getCallbacksForClass:(Class) cls
{
    return [_callbacksByClass objectForKey:cls];
}

+ (KSRTObjectTrackerCallbacks*) getOrCreateCallbacksForClass:(Class) cls
{
    KSRTObjectTrackerCallbacks* callbacks = [_callbacksByClass objectForKey:cls];
    if(callbacks == nil)
    {
        callbacks = [KSRTObjectTrackerCallbacks callbacks];
        [_callbacksByClass setObject:callbacks forKey:(id)cls];
    }
    return callbacks;
}


+ (void) addCallback:(KSRTCallback) callback
            forClass:(Class) cls
              method:(KSRTMethod) method
{
    @synchronized(self)
    {
        KSRTObjectTrackerCallbacks* callbacks = [self getOrCreateCallbacksForClass:cls];
        
        switch(method)
        {
            case KSRTMethodAlloc:
                [callbacks addAllocCallback:callback];
                break;
            case KSRTMethodStealthAlloc:
                [callbacks addStealthAllocCallback:callback];
                break;
            case KSRTMethodRetain:
                [callbacks addRetainCallback:callback];
                break;
            case KSRTMethodRelease:
                [callbacks addReleaseCallback:callback];
                break;
            case KSRTMethodAutorelease:
                [callbacks addAutoreleaseCallback:callback];
                break;
            case KSRTMethodDealloc:
                [callbacks addDeallocCallback:callback];
                break;
        }
    }
}

+ (void) removeCallbacksForAllClasses
{
    @synchronized(self)
    {
        [_trackers removeAllObjects];
        [_callbacksByClass removeAllObjects];
    }
}

+ (void) removeCallbacksForClass:(Class) cls
{
    @synchronized(self)
    {
        KSRTObjectTrackerCallbacks* callbacks = [self getCallbacksForClass:cls];
        [callbacks removeAllCallbacks];
    }
}

+ (void) removeCallbacksForClass:(Class) cls method:(KSRTMethod) method
{
    @synchronized(self)
    {
        KSRTObjectTrackerCallbacks* callbacks = [self getCallbacksForClass:cls];
        switch(method)
        {
            case KSRTMethodAlloc:
                [callbacks removeAllocCallbacks];
                break;
            case KSRTMethodStealthAlloc:
                [callbacks removeStealthAllocCallbacks];
                break;
            case KSRTMethodRetain:
                [callbacks removeRetainCallbacks];
                break;
            case KSRTMethodRelease:
                [callbacks removeReleaseCallbacks];
                break;
            case KSRTMethodAutorelease:
                [callbacks removeAutoreleaseCallbacks];
                break;
            case KSRTMethodDealloc:
                [callbacks removeDeallocCallbacks];
                break;
        }
    }
}


+ (KSRTObjectTracker*) trackerForObject:(id) object
{
    for(KSRTObjectTracker* tracker in _trackers)
    {
        if(tracker.object == object)
        {
            return tracker;
        }
    }
    return nil;
}

+ (KSRTObjectTracker*) addTrackerForObject:(id) object
{
    KSRTObjectTrackerCallbacks* callbacks = [self getCallbacksForClass:[object class]];
    if(callbacks == nil)
    {
        return nil;
    }

    KSRTObjectTracker* tracker = [KSRTObjectTracker trackerWithObject:object callbacks:callbacks];
    [_trackers addObject:tracker];
    return tracker;
}

+ (void) removeTrackerForObject:(id) object
{
    NSUInteger count = [_trackers count];
    for(NSUInteger i = 0; i < count; i++)
    {
        KSRTObjectTracker* tracker = [_trackers objectAtIndex:i];
        if(tracker.object == object)
        {
            [_trackers removeObjectAtIndex:i];
            break;
        }
    }
}


+ (void) notifyAlloc:(id) object
{
    @synchronized(self)
    {
        if(_enabled && !_inTrackingMethod)
        {
            _inTrackingMethod = YES;
            KSRTObjectTracker* tracker = nil;
            // TODO: Should it even exist at this point??
            tracker = [self trackerForObject:object];
            if(tracker == nil)
            {
                tracker = [self addTrackerForObject:object];
            }
            if(tracker != nil)
            {
                [tracker notifyAllocWithCallStack:[self generateTraceWithMaxEntries:_stackTraceDepth
                                                                         skipFrames:kRTAllocSkipFrames]];
            }
            _inTrackingMethod = NO;
        }
    }
}

+ (void) notifyDealloc:(id) object
{
    @synchronized(self)
    {
        if(_enabled && !_inTrackingMethod)
        {
            _inTrackingMethod = YES;
            KSRTObjectTracker* tracker = nil;
            BOOL isStealthAlloc = NO;
            tracker = [self trackerForObject:object];
            if(tracker == nil)
            {
                isStealthAlloc = YES;
                tracker = [self addTrackerForObject:object];
            }

            if(tracker != nil)
            {
                NSArray* callStack = [self generateTraceWithMaxEntries:_stackTraceDepth
                                                            skipFrames:kRTRetainSkipFrames];
                
                if(isStealthAlloc)
                {
                    [tracker notifyStealthAllocWithCallStack:callStack];
                }
                [tracker notifyDeallocWithCallStack:callStack];
                [self removeTrackerForObject:object];
            }
            _inTrackingMethod = NO;
        }
    }
}

+ (void) notifyRetain:(id) object
{
    @synchronized(self)
    {
        if(_enabled && !_inTrackingMethod)
        {
            _inTrackingMethod = YES;
            KSRTObjectTracker* tracker = nil;
            BOOL isStealthAlloc = NO;
            tracker = [self trackerForObject:object];
            if(tracker == nil)
            {
                isStealthAlloc = YES;
                tracker = [self addTrackerForObject:object];
            }
            
            if(tracker != nil)
            {
                NSArray* callStack = [self generateTraceWithMaxEntries:_stackTraceDepth
                                                            skipFrames:kRTRetainSkipFrames];
                
                if(isStealthAlloc)
                {
                    [tracker notifyStealthAllocWithCallStack:callStack];
                }
                [tracker notifyRetainWithCallStack:callStack];
            }
            _inTrackingMethod = NO;
        }
    }
}

+ (void) notifyRelease:(id) object
{
    @synchronized(self)
    {
        if(_enabled && !_inTrackingMethod)
        {
            _inTrackingMethod = YES;
            KSRTObjectTracker* tracker = nil;
            BOOL isStealthAlloc = NO;
            tracker = [self trackerForObject:object];
            if(tracker == nil)
            {
                isStealthAlloc = YES;
                tracker = [self addTrackerForObject:object];
            }
            
            if(tracker != nil)
            {
                NSArray* callStack = [self generateTraceWithMaxEntries:_stackTraceDepth
                                                            skipFrames:kRTReleaseSkipFrames];
                
                if(isStealthAlloc)
                {
                    [tracker notifyStealthAllocWithCallStack:callStack];
                }
                [tracker notifyReleaseWithCallStack:callStack];
            }
            _inTrackingMethod = NO;
        }
    }
}

+ (void) notifyAutorelease:(id) object
{
    @synchronized(self)
    {
        if(_enabled && !_inTrackingMethod)
        {
            _inTrackingMethod = YES;
            KSRTObjectTracker* tracker = nil;
            BOOL isStealthAlloc = NO;
            tracker = [self trackerForObject:object];
            if(tracker == nil)
            {
                isStealthAlloc = YES;
                tracker = [self addTrackerForObject:object];
            }
            
            if(tracker != nil)
            {
                NSArray* callStack = [self generateTraceWithMaxEntries:_stackTraceDepth
                                                            skipFrames:kRTAutoreleaseSkipFrames];
                
                if(isStealthAlloc)
                {
                    [tracker notifyStealthAllocWithCallStack:callStack];
                }
                [tracker notifyAutoreleaseWithCallStack:callStack];
            }
            _inTrackingMethod = NO;
        }
    }
}

+ (NSString*) condensedTraceForStack:(NSArray*) callStack depth:(int) maxDepth
{
    if(maxDepth == 0 || maxDepth > (int)[callStack count])
    {
        maxDepth = (int)[callStack count];
    }
    
    NSMutableString* string = [NSMutableString stringWithString:@"("];
    for(int i = 0; i < maxDepth; i++)
    {
        KSRTCallStackEntry* entry = [callStack objectAtIndex:(NSUInteger)i];
        [string appendString:entry.call];
        if(i < maxDepth-1)
        {
            [string appendString:@","];
        }
    }
    [string appendString:@")"];
    
    return [string length] > 2 ? string : @"";
}

+ (NSString*) fullTraceForStack:(NSArray*) callStack depth:(int) maxDepth
{
    if(maxDepth == 0 || maxDepth > (int)[callStack count])
    {
        maxDepth = (int)[callStack count];
    }
    
    NSMutableString* string = [NSMutableString stringWithString:@"\n"];
    for(int i = 0; i < maxDepth; i++)
    {
        KSRTCallStackEntry* entry = [callStack objectAtIndex:(NSUInteger)i];
        [string appendString:entry.description];
        if(i < maxDepth-1)
        {
            [string appendString:@"\n"];
        }
    }
    [string appendString:@"\n"];
    
    return [string length] > 2 ? string : @"";
}


+ (void) addCondensedLogCallbacksForClass:(Class) cls
                           callStackDepth:(int) callStackDepth
{
    [self addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         NSLog(@"<%@: %p> ALLOC  : %2d (%2d) %@",
               [tracker.object class],
               tracker.object,
               tracker.currentRetainCount,
               tracker.effectiveRetainCount,
               [self condensedTraceForStack:callStack depth:callStackDepth]);
     } forClass:cls method:KSRTMethodAlloc];
    [self addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         #pragma unused(callStack)
         NSLog(@"<%@: %p> (ALLOC):  ? ( ?)",
               [tracker.object class],
               tracker.object);
     } forClass:cls method:KSRTMethodStealthAlloc];
    
    [self addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         NSLog(@"<%@: %p> RETAIN : %2d (%2d) %@",
               [tracker.object class],
               tracker.object,
               tracker.currentRetainCount,
               tracker.effectiveRetainCount,
               [self condensedTraceForStack:callStack depth:callStackDepth]);
     } forClass:cls method:KSRTMethodRetain];
    
    [self addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         NSLog(@"<%@: %p> RELEASE: %2d (%2d) %@",
               [tracker.object class],
               tracker.object,
               tracker.currentRetainCount,
               tracker.effectiveRetainCount,
               [self condensedTraceForStack:callStack depth:callStackDepth]);
     } forClass:cls method:KSRTMethodRelease];
    
    [self addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         NSLog(@"<%@: %p> AUTOREL: %2d (%2d) %@",
               [tracker.object class],
               tracker.object,
               tracker.currentRetainCount,
               tracker.effectiveRetainCount,
               [self condensedTraceForStack:callStack depth:callStackDepth]);
     } forClass:cls method:KSRTMethodAutorelease];
    
    [self addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         NSLog(@"<%@: %p> DEALLOC:         %@",
               [tracker.object class],
               tracker.object,
               [self condensedTraceForStack:callStack depth:callStackDepth]);
     } forClass:cls method:KSRTMethodDealloc];
}

+ (void) addFullLogCallbacksForClass:(Class) cls
                           callStackDepth:(int) callStackDepth
{
    [self addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         NSLog(@"<%@: %p> ALLOC  : %2d (%2d) %@",
               [tracker.object class],
               tracker.object,
               tracker.currentRetainCount,
               tracker.effectiveRetainCount,
               [self fullTraceForStack:callStack depth:callStackDepth]);
     } forClass:cls method:KSRTMethodAlloc];
    [self addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         #pragma unused(callStack)
         NSLog(@"<%@: %p> (ALLOC):  ? ( ?)",
               [tracker.object class],
               tracker.object);
     } forClass:cls method:KSRTMethodStealthAlloc];
    
    [self addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         NSLog(@"<%@: %p> RETAIN : %2d (%2d) %@",
               [tracker.object class],
               tracker.object,
               tracker.currentRetainCount,
               tracker.effectiveRetainCount,
               [self fullTraceForStack:callStack depth:callStackDepth]);
     } forClass:cls method:KSRTMethodRetain];
    
    [self addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         NSLog(@"<%@: %p> RELEASE: %2d (%2d) %@",
               [tracker.object class],
               tracker.object,
               tracker.currentRetainCount,
               tracker.effectiveRetainCount,
               [self fullTraceForStack:callStack depth:callStackDepth]);
     } forClass:cls method:KSRTMethodRelease];
    
    [self addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         NSLog(@"<%@: %p> AUTOREL: %2d (%2d) %@",
               [tracker.object class],
               tracker.object,
               tracker.currentRetainCount,
               tracker.effectiveRetainCount,
               [self fullTraceForStack:callStack depth:callStackDepth]);
     } forClass:cls method:KSRTMethodAutorelease];
    
    [self addCallback:^(KSRTObjectTracker *tracker, NSArray *callStack)
     {
         NSLog(@"<%@: %p> DEALLOC:         %@",
               [tracker.object class],
               tracker.object,
               [self fullTraceForStack:callStack depth:callStackDepth]);
     } forClass:cls method:KSRTMethodDealloc];
}

@end
