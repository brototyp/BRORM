//
//  BRClass.m
//  BROrm
//
//  Created by Cornelius Horstmann on 13.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BRClass.h"
#import "BRSchool.h"

@implementation BRClass

+ (void)migrate{
    [BROrm executeUpdate:@"CREATE TABLE IF NOT EXISTS class (identifier INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, school_identifier INTEGER);" withArgumentsInArray:NULL];
}

+ (NSString*)getTableName{
    return @"class";
}

- (BRSchool*)school{
    return (BRSchool*)[[BROrmWrapper factoryForClassName:@"BRSchool"] findOne:self[@"school_identifier"]];
}

@end
