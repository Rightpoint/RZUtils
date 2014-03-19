//
//  NSUndoManager+RZBlockUndo.h
//  Raizlabs
//
//  Created by Nick Donaldson on 3/14/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

/*
Copyright 2014 Raizlabs and other contributors
http://raizlabs.com/

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import <Foundation/Foundation.h>

/**
 *  Block-based interface for NSUndoManager
 */
@interface NSUndoManager (RZBlockUndo)

/**
 *  Register an undo action with a block and a redo block.
 *  @warning undoBlock must not be nil. Neither block should contain a strong reference to anything that is unsafe to retain.
 *  @param undoBlock A block that will be invoked when the undo stack reaches this action.
 *  @param redoBlock An optional block that will be invoked for a redo after an undo of this action.
 */
- (void)rz_registerUndoWithBlock:(void(^)())undoBlock redoBlock:(void(^)())redoBlock;

@end
