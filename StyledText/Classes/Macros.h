//
//  Macros.h
//  coreTextEx
//
//  Created by jkaufman on 3/2/11.
//  Copyright 2011 Raizlabs. All rights reserved.
//

#import "Macros.h"

// Convert CFRange to NSRange
// http://www.cocoabuilder.com/archive/cocoa/296636-convert-cfrange-to-nsrange.html
#define NSMakeRangeFromCF(cfr) NSMakeRange( cfr.location == kCFNotFound ? NSNotFound : cfr.location, cfr.length )