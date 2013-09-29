//
//  BRSchool.h
//  BROrm
//
//  Created by Cornelius Horstmann on 13.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BRModel.h"

@interface BRSchool : BRModel

+ (void)migrate;
- (NSInteger)numberOfClasses;
- (NSArray*)classes;

- (NSInteger)numberOfStudents;
- (NSArray*)students;

@end
