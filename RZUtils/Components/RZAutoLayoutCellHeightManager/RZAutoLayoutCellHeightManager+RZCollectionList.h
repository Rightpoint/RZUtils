//
//  RZAutoLayoutCellHeightManager+RZCollectionList.h
//  VirginPulse
//
//  Created by Alex Rouse on 12/12/13.
//  Copyright (c) 2013 Virgin. All rights reserved.
//

#import "RZAutoLayoutCellHeightManager.h"
#import "RZCollectionList.h"

@interface RZAutoLayoutCellHeightManager (RZCollectionList)

- (void)rz_autoInvalidateWithCollectionList:(id<RZCollectionList>)collectionList;

@end
