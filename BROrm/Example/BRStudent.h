//
//  BRStudent.h
//  BROrm
//
//  Created by Cornelius Horstmann on 14.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BRModel.h"

@class BRSchool,BRClass;

@interface BRStudent : BRModel


+ (void)migrate;
- (BRSchool*)school;
- (BRClass*)class;

@end
