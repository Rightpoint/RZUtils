//
//  NSUndoManager+RZBlockUndo.m
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


#import "NSUndoManager+RZBlockUndo.h"

@interface RZUndoRedoBlockAction : NSObject

@property (nonatomic, copy) void (^undoBlock)();
@property (nonatomic, copy) void (^redoBlock)();

- (instancetype)invertedAction;

@end

@implementation RZUndoRedoBlockAction

- (instancetype)invertedAction
{
    // Must have a redo block to return an inverted action
    if ( self.redoBlock == nil ) {
        return nil;
    }
    
    RZUndoRedoBlockAction *invertedAction = [[RZUndoRedoBlockAction alloc] init];
    invertedAction.undoBlock = self.redoBlock;
    invertedAction.redoBlock = self.undoBlock;
    return invertedAction;
}

@end

@implementation NSUndoManager (RZBlockUndo)

- (void)rz_performUndoAction:(RZUndoRedoBlockAction *)action
{
    if ( action.undoBlock ) {
        action.undoBlock();
    }
    
    RZUndoRedoBlockAction *redoAction = [action invertedAction];
    
    if ( redoAction != nil ) {
        [self registerUndoWithTarget:self selector:@selector(rz_performUndoAction:) object:redoAction];
    }
}

- (void)rz_registerUndoWithBlock:(void (^)())undoBlock redoBlock:(void (^)())redoBlock
{
    NSParameterAssert(undoBlock);

    RZUndoRedoBlockAction *undoRedoAction    = [[RZUndoRedoBlockAction alloc] init];
    undoRedoAction.undoBlock                 = undoBlock;
    undoRedoAction.redoBlock                 = redoBlock;
    
    [self registerUndoWithTarget:self selector:@selector(rz_performUndoAction:) object:undoRedoAction];
}

@end
