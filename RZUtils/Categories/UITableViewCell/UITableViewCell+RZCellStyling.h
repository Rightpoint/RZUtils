//
//  UITableViewCell+RZCellStyling.h
//
//  Created by Joshua Leibsly on 4/22/13.

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
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (RZCellStyling)

/**
 *  Sets the background image for cells in a @c UITableView depending on the cell's position in its section.  Call this category when configuring a cell for an index path.  Requires background images in the form of: @c "bg-cell" / @c "bg-cell-pressed" , @c "bg-cell-top" / @c "bg-cell-top-pressed" , @c "bg-cell-bottom" / @c "bg-cell-bottom-pressed" , @c "bg-cell-middle" / @c "bg-cell-middle-pressed".
 *
 *  @param index     the index for the @c UITableViewCell.
 *  @param totalRows the total count of rows in the section.
 */
- (void)rz_setBackgroundImagesForIndex:(int)index totalRowsInSection:(int)totalRows;

@end
