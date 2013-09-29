//
//  BRClass.h
//  BROrm
//
//  Created by Cornelius Horstmann on 13.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BRModel.h"

@class BRSchool;

@interface BRClass : BRModel

+ (void)migrate;
- (BRSchool*)school;

@end
