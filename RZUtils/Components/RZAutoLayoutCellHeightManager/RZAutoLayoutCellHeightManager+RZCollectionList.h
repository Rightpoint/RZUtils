//
//  RZAutoLayoutCellHeightManager+RZCollectionList.h
//  Raizlabs
//
//  Created by Alex Rouse on 12/12/13.
//  Copyright (c) 2013 Raizlabs. All rights reserved.
//

#import "RZAutoLayoutCellHeightManager.h"
#import "RZCollectionList.h"

@interface RZAutoLayoutCellHeightManager (RZCollectionList)

- (void)rz_autoInvalidateWithCollectionList:(id<RZCollectionList>)collectionList;

@end
