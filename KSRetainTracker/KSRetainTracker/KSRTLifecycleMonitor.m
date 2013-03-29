//
//  KSRTLifecycleMonitor.m
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

#import "KSRTLifecycleMonitor.h"
#import "KSRTLifecycleMonitor+Private.h"
#import "KSRTObjectTracker.h"


@implementation KSRTMMOperation

+ (KSRTMMOperation*) operationWithMethod:(KSRTMethod) method
                               callStack:(NSArray*) callStack
                             retainCount:(int) retainCount
                        autoreleaseCount:(int) autoreleaseCount
{
    return [[[self alloc] initWithMethod:method
                               callStack:callStack
                             retainCount:retainCount
                        autoreleaseCount:autoreleaseCount] autorelease];
}

- (id) initWithMethod:(KSRTMethod) method
            callStack:(NSArray*) callStack
          retainCount:(int) retainCount
     autoreleaseCount:(int) autoreleaseCount
{
    if((self = [super init]))
    {
        _method = method;
        _callStack = [callStack retain];
        _currentRetainCount = retainCount;
        _currentAutoreleaseCount = autoreleaseCount;
    }
    return self;
}

- (void) dealloc
{
    [_callStack release];
    [super dealloc];
}

- (NSString*) description
{
    NSString* methodName = nil;
    switch (self.method)
    {
        case KSRTMethodAlloc:
            methodName = @"Alloc";
            break;
        case KSRTMethodStealthAlloc:
            methodName = @"StealthAlloc";
            break;
        case KSRTMethodRetain:
            methodName = @"Retain";
            break;
        case KSRTMethodRelease:
            methodName = @"Release";
            break;
        case KSRTMethodAutorelease:
            methodName = @"Autorelease";
            break;
        case KSRTMethodDealloc:
            methodName = @"Dealloc";
            break;
    }
    
    NSMutableString* trace = [NSMutableString stringWithCapacity:100];
    for(KSRTCallStackEntry* entry in self.callStack)
    {
        [trace appendString:[entry description]];
        [trace appendString:@"\n"];
    }
    [trace deleteCharactersInRange:NSMakeRange([trace length]-1, 1)];
    
    return [NSString stringWithFormat:@"<%@: %p>: RC = %2d (%2d), Method = %@, Stack =\n%@",
            [self class],
            self,
            _currentRetainCount,
            _currentRetainCount - _currentAutoreleaseCount,
            methodName,
            trace
            ];
}

@synthesize method = _method;
@synthesize callStack = _callStack;
@synthesize currentRetainCount = _currentRetainCount;
@synthesize currentAutoreleaseCount = _currentAutoreleaseCount;

@end



@implementation KSRTLifecycleMonitor

+ (KSRTLifecycleMonitor*) monitorForTracker:(KSRTObjectTracker*) tracker
{
    return [[[self alloc] initWithTracker:tracker] autorelease];
}

- (id) initWithTracker:(KSRTObjectTracker*) tracker
{
    if((self = [super init]))
    {
        _tracker = [tracker retain];
        _mmOperations = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void) dealloc
{
    [_tracker release];
    [_mmOperations release];
    [super dealloc];
}

- (NSString*) description
{
    NSMutableString* operationsDesc = [NSMutableString string];
    for(KSRTMMOperation* operation in self.mmOperations)
    {
        [operationsDesc appendString:[operation description]];
        [operationsDesc appendString:@"\n"];
    }
    [operationsDesc deleteCharactersInRange:NSMakeRange([operationsDesc length]-1, 1)];
    
    return [NSString stringWithFormat:@"<%@: %p>: Tracker = [%@], Operations =\n%@",
            [self class],
            self,
            self.tracker,
            operationsDesc
            ];
}

@synthesize tracker = _tracker;
@synthesize mmOperations = _mmOperations;

- (id) object
{
    return self.tracker.object;
}

- (void) notifyMethodCall:(KSRTMethod) method callStack:(NSArray*) callStack
{
    [_mmOperations addObject:[KSRTMMOperation operationWithMethod:method
                                                        callStack:callStack
                                                      retainCount:_tracker.currentRetainCount
                                                 autoreleaseCount:_tracker.currentAutoreleaseCount]];
}

@end
