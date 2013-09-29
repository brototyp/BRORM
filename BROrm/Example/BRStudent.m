//
//  BRStudent.m
//  BROrm
//
//  Created by Cornelius Horstmann on 14.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BRStudent.h"

@implementation BRStudent

+ (void)migrate{
    [BROrm executeUpdate:@"CREATE TABLE IF NOT EXISTS student (identifier INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, class_identifier INTEGER);" withArgumentsInArray:NULL];
}

+ (NSString*)getTableName{
    return @"student";
}

@end
