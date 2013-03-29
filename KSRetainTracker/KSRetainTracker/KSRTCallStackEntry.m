//
//  KSRTCallStackEntry.m
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

#import "KSRTCallStackEntry.h"


@implementation KSRTCallStackEntry

static NSMutableCharacterSet* objcSymbolSet;

+ (id) entryWithTraceLine:(NSString*) traceLine
{
	return [[[self alloc] initWithTraceLine:traceLine] autorelease];
}

- (id) initWithTraceLine:(NSString*) traceLine
{
	if(nil == objcSymbolSet)
	{
		objcSymbolSet = [[NSMutableCharacterSet alloc] init];
		[objcSymbolSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
		[objcSymbolSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithRange:NSMakeRange('!', '~' - '!')]];
	}
	
	if(nil != (self = [super init]))
	{
		_rawEntry = [traceLine retain];
		
		NSScanner* scanner = [NSScanner scannerWithString:_rawEntry];
		
		if(![scanner scanInt:(int*)&_traceEntryNumber]) goto done;
		
		if(![scanner scanCharactersFromSet:objcSymbolSet intoString:&_library]) goto done;
		
		if(![scanner scanHexInt:&_address]) goto done;
		
		if(![scanner scanCharactersFromSet:objcSymbolSet intoString:&_selectorName]) goto done;
		if([_selectorName length] > 2 && [_selectorName characterAtIndex:1] == '[')
		{
			_isClassLevelSelector = [_selectorName characterAtIndex:0] == '+';
			_objectClass = [[_selectorName substringFromIndex:2] retain];
			if(![scanner scanUpToString:@"]" intoString:&_selectorName]) goto done;
			if(![scanner scanString:@"]" intoString:nil]) goto done;
		}
		
		if(![scanner scanString:@"+" intoString:nil]) goto done;
		
		if(![scanner scanInt:&_offset]) goto done;
		
	done:
		if(nil == _library)
		{
			_library = @"???";
		}
		if(nil == _selectorName)
		{
			_selectorName = @"???";
		}
		[_library retain];
		[_objectClass retain];
		[_selectorName retain];
	}
	return self;
}

- (void) dealloc
{
	[_rawEntry release];
	[_library release];
	[_objectClass release];
	[_selectorName release];
	[super dealloc];
}

@synthesize traceEntryNumber = _traceEntryNumber;
@synthesize library = _library;
@synthesize address = _address;
@synthesize objectClass = _objectClass;
@synthesize isClassLevelSelector = _isClassLevelSelector;
@synthesize selectorName = _selectorName;
@synthesize offset = _offset;

- (NSString*) description
{
	return _rawEntry;
}

- (NSString*) call
{
    if(_objectClass != nil)
    {
        if(_isClassLevelSelector)
        {
            return [NSString stringWithFormat:@"+[%@ %@]", _objectClass, _selectorName];
        }
        else
        {
            return [NSString stringWithFormat:@"-[%@ %@]", _objectClass, _selectorName];
        }
    }
    else
    {
        return _selectorName;
    }
}

@end
