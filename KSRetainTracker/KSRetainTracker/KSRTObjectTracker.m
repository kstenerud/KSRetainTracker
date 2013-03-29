//
//  KSRTObjectTracker.m
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

#import "KSRTObjectTracker.h"
#import "KSRTTypes.h"
#import "KSRTObjectTracker+Private.h"




@implementation KSRTObjectTrackerCallbacks

+ (KSRTObjectTrackerCallbacks*) callbacks
{
    return [[[self alloc] init] autorelease];
}

- (id) init
{
    if((self = [super init]))
    {
        _onAlloc = [[NSMutableArray alloc] init];
        _onStealthAlloc = [[NSMutableArray alloc] init];
        _onRetain = [[NSMutableArray alloc] init];
        _onRelease = [[NSMutableArray alloc] init];
        _onAutorelease = [[NSMutableArray alloc] init];
        _onDealloc = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [_onAlloc release];
    [_onStealthAlloc release];
    [_onRetain release];
    [_onRelease release];
    [_onAutorelease release];
    [_onDealloc release];
    
    [super dealloc];
}

- (void) addAllocCallback:(KSRTCallback) callback
{
    [_onAlloc addObject:[[callback copy] autorelease]];
}

- (void) addStealthAllocCallback:(KSRTCallback) callback
{
    [_onStealthAlloc addObject:[[callback copy] autorelease]];
}

- (void) addRetainCallback:(KSRTCallback) callback
{
    [_onRetain addObject:[[callback copy] autorelease]];
}

- (void) addReleaseCallback:(KSRTCallback) callback
{
    [_onRelease addObject:[[callback copy] autorelease]];
}

- (void) addAutoreleaseCallback:(KSRTCallback) callback
{
    [_onAutorelease addObject:[[callback copy] autorelease]];
}

- (void) addDeallocCallback:(KSRTCallback) callback
{
    [_onDealloc addObject:[[callback copy] autorelease]];
}

- (void) removeAllocCallbacks
{
    [_onAlloc removeAllObjects];
}

- (void) removeStealthAllocCallbacks
{
    [_onStealthAlloc removeAllObjects];
}

- (void) removeRetainCallbacks
{
    [_onRetain removeAllObjects];
}

- (void) removeReleaseCallbacks
{
    [_onRelease removeAllObjects];
}

- (void) removeAutoreleaseCallbacks
{
    [_onAutorelease removeAllObjects];
}

- (void) removeDeallocCallbacks
{
    [_onDealloc removeAllObjects];
}

- (void) removeAllCallbacks
{
    [self removeAllocCallbacks];
    [self removeStealthAllocCallbacks];
    [self removeRetainCallbacks];
    [self removeReleaseCallbacks];
    [self removeAutoreleaseCallbacks];
    [self removeDeallocCallbacks];
}

- (void) performAllocCallbackWithTracker:(KSRTObjectTracker*) tracker callStack:(NSArray*) callStack
{
    for(KSRTCallback callback in _onAlloc)
    {
        callback(tracker, callStack);
    }
}

- (void) performStealthAllocCallbackWithTracker:(KSRTObjectTracker*) tracker callStack:(NSArray*) callStack
{
    for(KSRTCallback callback in _onStealthAlloc)
    {
        callback(tracker, callStack);
    }
}

- (void) performRetainCallbackWithTracker:(KSRTObjectTracker*) tracker callStack:(NSArray*) callStack
{
    for(KSRTCallback callback in _onRetain)
    {
        callback(tracker, callStack);
    }
}

- (void) performReleaseCallbackWithTracker:(KSRTObjectTracker*) tracker callStack:(NSArray*) callStack
{
    for(KSRTCallback callback in _onRelease)
    {
        callback(tracker, callStack);
    }
}

- (void) performAutoreleaseCallbackWithTracker:(KSRTObjectTracker*) tracker callStack:(NSArray*) callStack
{
    for(KSRTCallback callback in _onAutorelease)
    {
        callback(tracker, callStack);
    }
}

- (void) performDeallocCallbackWithTracker:(KSRTObjectTracker*) tracker callStack:(NSArray*) callStack
{
    for(KSRTCallback callback in _onDealloc)
    {
        callback(tracker, callStack);
    }
}

@end


@interface KSRTObjectTracker ()

@property(nonatomic,readonly,retain) KSRTObjectTrackerCallbacks* callbacks;

@end

@implementation KSRTObjectTracker

@synthesize callbacks = _callbacks;
@synthesize object = _object;

+ (KSRTObjectTracker*) trackerWithObject:(id) object
                               callbacks:(KSRTObjectTrackerCallbacks*) callbacks
{
    return [[[self alloc] initWithObject:object callbacks:callbacks] autorelease];
}

- (id) initWithObject:(id) object
            callbacks:(KSRTObjectTrackerCallbacks*) callbacks
{
    if(nil != (self = [super init]))
    {
        _object = object; // Weak reference
        _callbacks = [callbacks retain];
    }
    return self;
}

- (void) dealloc
{
    [_callbacks release];
    [super dealloc];
}

- (NSString*) description
{
    return [NSString stringWithFormat:@"<%@: %p>: Object = %@, RC = %2d (%2d)",
            [self class],
            self,
            self.object,
            self.currentRetainCount,
            self.effectiveRetainCount];
}

- (NSUInteger) hash
{
    return [[_object class] hash];
}

- (BOOL) isEqual:(id)object
{
    if(![object isKindOfClass:[KSRTObjectTracker class]])
    {
        return NO;
    }
    KSRTObjectTracker* other = (KSRTObjectTracker*)object;
    return self.object == other.object;
}

- (id) copyWithZone:(NSZone *)zone
{
    KSRTObjectTracker* other = [[[self class] allocWithZone:zone] initWithObject:_object callbacks:_callbacks];
    other->_currentAutoreleaseCount = _currentAutoreleaseCount;
    other->_currentRetainCount = _currentRetainCount;
    return other;
}

@synthesize currentRetainCount = _currentRetainCount;
@synthesize currentAutoreleaseCount = _currentAutoreleaseCount;

- (int) effectiveRetainCount
{
    return _currentRetainCount - _currentAutoreleaseCount;
}

- (void) notifyAllocWithCallStack:(NSArray*) callStack
{
    _currentRetainCount = (int)[_object retainCount];
    [_callbacks performAllocCallbackWithTracker:self callStack:callStack];
}

- (void) notifyStealthAllocWithCallStack:(NSArray*) callStack
{
    _currentRetainCount = (int)[_object retainCount];
    [_callbacks performStealthAllocCallbackWithTracker:self callStack:callStack];
}

- (void) notifyRetainWithCallStack:(NSArray*) callStack
{
    _currentRetainCount++;
    [_callbacks performRetainCallbackWithTracker:self callStack:callStack];
}

- (BOOL) isAutoreleasePoolPop:(NSArray*) callStack
{
    for(KSRTCallStackEntry* entry in callStack)
    {
        NSString* selectorName = entry.selectorName;
        switch([selectorName characterAtIndex:0])
        {
            case '-':
            case '+':
                return NO;
        }
        if([selectorName isEqualToString:@"CFRelease"])
        {
            return NO;
        }
        if([selectorName isEqualToString:@"_CFAutoreleasePoolPop"])
        {
            return YES;
        }
    }
    return NO;
}

- (void) notifyReleaseWithCallStack:(NSArray*) callStack
{
    if([callStack count] > 0 && [self isAutoreleasePoolPop:callStack])
    {
        _currentAutoreleaseCount--;
    }
    _currentRetainCount--;

    // Just in case the above check fails.
    if(_currentAutoreleaseCount > _currentRetainCount)
    {
        _currentAutoreleaseCount = _currentRetainCount;
    }

    [_callbacks performReleaseCallbackWithTracker:self callStack:callStack];
}

- (void) notifyAutoreleaseWithCallStack:(NSArray*) callStack
{
    _currentAutoreleaseCount++;
    [_callbacks performAutoreleaseCallbackWithTracker:self callStack:callStack];
}

- (void) notifyDeallocWithCallStack:(NSArray*) callStack
{
    _currentRetainCount = (int)[_object retainCount];
    [_callbacks performDeallocCallbackWithTracker:self callStack:callStack];
}

@end
