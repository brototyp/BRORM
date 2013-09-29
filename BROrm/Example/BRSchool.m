//
//  BRSchool.m
//  BROrm
//
//  Created by Cornelius Horstmann on 13.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BRSchool.h"

@implementation BRSchool

+ (void)migrate{
    [BROrm executeUpdate:@"CREATE TABLE IF NOT EXISTS school (identifier INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);" withArgumentsInArray:NULL];
}

+ (NSString*)getTableName{
    return @"school";
}

- (NSInteger)numberOfClasses{
    return [[self hasOneOrMany:@"BRClass"] count];
}
- (NSArray*)classes{
    return [[self hasOneOrMany:@"BRClass"] findMany];
}

- (NSInteger)numberOfStudents{
    return [[self hasOneOrMany:@"BRStudent"] count];
}
- (NSArray*)students{
    return [[self hasOneOrMany:@"BRStudent"] findMany];
}
@end
