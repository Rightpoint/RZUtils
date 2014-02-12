//
//  RZLogHelper.h
//  Created by Nick Donaldson on 8/1/13.

//
// Copyright 2014 Raizlabs and other contributors
// http://raizlabs.com/
// 
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


// Include guard
#ifndef __RZ_LOGHELPER_H__
#define __RZ_LOGHELPER_H__


// Globally enable or disable logging. Set here or in Build-Level Preprocessor Macros
#ifndef RZ_LOGGING_ENABLED
#	define RZ_LOGGING_ENABLED        1
#endif

// Logging Verboisty. Set here or in Build-Level Preprocessor Macros
#ifndef RZ_LOGGING_LEVEL_DEBUG
#	define RZ_LOGGING_LEVEL_DEBUG        0
#endif
#ifndef RZ_LOGGING_LEVEL_INFO
#	define RZ_LOGGING_LEVEL_INFO         1
#endif
#ifndef RZ_LOGGING_LEVEL_ERROR
#	define RZ_LOGGING_LEVEL_ERROR        1
#endif


// Abandon all hope, ye who change code below this line
// ----------------------------------------------------------------


#if !(defined(RZ_LOGGING_ENABLED) && RZ_LOGGING_ENABLED)
#undef RZ_LOGGING_LEVEL_TRACE
#undef RZ_LOGGING_LEVEL_INFO
#undef RZ_LOGGING_LEVEL_ERROR
#undef RZ_LOGGING_LEVEL_DEBUG
#endif

// Creates a string containing the current function and line number
#define RZCurrentCodeLocation [NSString stringWithFormat:@"%s (Line %d)", __PRETTY_FUNCTION__, __LINE__]

#if defined(RZ_LOGGING_LEVEL_INFO) && RZ_LOGGING_LEVEL_INFO
#define RZLogInfo(fmt, ...) NSLog((@"[INFO] " fmt), ##__VA_ARGS__)
#else
#define RZLogInfo(...)
#endif

#if defined(RZ_LOGGING_LEVEL_ERROR) && RZ_LOGGING_LEVEL_ERROR
#define RZLogError(fmt, ...) NSLog((@"[ERROR] " fmt), ##__VA_ARGS__)
#else
#define RZLogError(...)
#endif

#if defined(RZ_LOGGING_LEVEL_DEBUG) && RZ_LOGGING_LEVEL_DEBUG
#define RZLogDebug(fmt, ...) NSLog((@"[DEBUG] " fmt), ##__VA_ARGS__)
#else
#define RZLogDebug(...)
#endif

#endif
