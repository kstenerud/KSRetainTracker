//
//  KSRTCallStackEntry.h
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
 * A single stack trace entry, recording all information about a stack trace line.
 */
@interface KSRTCallStackEntry: NSObject
{
    /** \cond */
	int _traceEntryNumber;
	NSString* _library;
	unsigned int _address;
	NSString* _objectClass;
	bool _isClassLevelSelector;
	NSString* _selectorName;
	int _offset;
	NSString* _rawEntry;
    /** \endcond */
}
/** This entry's position in the original stack trace. */
@property(nonatomic,readonly,assign) int traceEntryNumber;

/** Which library, framework, or process the entry is from. */
@property(nonatomic,readonly,retain) NSString* library;

/** The address in memory. */
@property(nonatomic,readonly,assign) unsigned int address;

/** The class of object that made the call. */
@property(nonatomic,readonly,retain) NSString* objectClass;

/** If true, this is a class level selector being called. */
@property(nonatomic,readonly,assign) bool isClassLevelSelector;

/** The selector (or function if it's C) being called. */
@property(nonatomic,readonly,retain) NSString* selectorName;

/** The full call signature of the selector or function.
 *
 * Examples:
 *   -[NSString stringWithFormat];
 *   +[MyClass someClassMethod:withParam:]
 *   SomeCFunction
 */
@property(nonatomic,readonly,retain) NSString* call;

/** The offset within the function or method. */
@property(nonatomic,readonly,assign) int offset;

/** Create a new stack trace entry from the specified trace line.
 * This line is expected to conform to what backtrace_symbols() returns.
 */
+ (id) entryWithTraceLine:(NSString*) traceLine;

/** Initialize a stack trace entry from the specified trace line.
 * This line is expected to conform to what backtrace_symbols() returns.
 */
- (id) initWithTraceLine:(NSString*) traceLine;

@end
