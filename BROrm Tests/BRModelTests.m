//
//  BRModelTests.m
//  BROrm
//
//  Created by Cornelius Horstmann on 17.06.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BRModel.h"
#import "FMDatabaseQueue.h"

#define CLASSNAMES @[@"DefaultClass",@"CustomClass"]

@interface CustomClass : BRModel

@end

@implementation CustomClass

+ (NSString*)getTableName{
    return @"custom_class_table";
}

+ (NSString*)idColumn{
    return @"id_column";
}

@end

@interface BRModelTests : XCTestCase

@end

@implementation BRModelTests{
    FMDatabaseQueue *_databaseQueue;
}

- (void)setUp
{
    [super setUp];
    _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"test.sqlite"]];
    [BROrm setDefaultQueue:_databaseQueue];
    
    [BROrm executeUpdate:@"CREATE TABLE IF NOT EXISTS default_class (identifier INTEGER PRIMARY KEY AUTOINCREMENT, string TEXT, int INTEGER, default_class_identifier INTEGER);" withArgumentsInArray:NULL];
    [BROrm executeUpdate:@"INSERT INTO default_class (string, int, default_class_identifier) VALUES (?,?,?)" withArgumentsInArray:@[@"string 1",@(1),@(1)]];
    [BROrm executeUpdate:@"INSERT INTO default_class (string, int, default_class_identifier) VALUES (?,?,?)" withArgumentsInArray:@[@"string 2",@(1),@(1)]];
    [BROrm executeUpdate:@"INSERT INTO default_class (string, int, default_class_identifier) VALUES (?,?,?)" withArgumentsInArray:@[@"string 3",@(2),@(2)]];
    
    [BROrm executeUpdate:@"CREATE TABLE IF NOT EXISTS custom_class_table (id_column INTEGER PRIMARY KEY AUTOINCREMENT, string TEXT, int INTEGER, custom_class_table_foreign_key INTEGER);" withArgumentsInArray:NULL];
    [BROrm executeUpdate:@"INSERT INTO custom_class_table (string, int, custom_class_table_foreign_key) VALUES (?,?,?)" withArgumentsInArray:@[@"string 1",@(1),@(1)]];
    [BROrm executeUpdate:@"INSERT INTO custom_class_table (string, int, custom_class_table_foreign_key) VALUES (?,?,?)" withArgumentsInArray:@[@"string 2",@(1),@(1)]];
    [BROrm executeUpdate:@"INSERT INTO custom_class_table (string, int, custom_class_table_foreign_key) VALUES (?,?,?)" withArgumentsInArray:@[@"string 3",@(2),@(2)]];
}

- (void)tearDown
{
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"test.sqlite"] error:NULL];
    [super tearDown];
}

#pragma mark automatic tests

- (void)testAutoClassDiscovery
{
    for (NSString *classname in CLASSNAMES) {
        BROrmWrapper *w = [BROrmWrapper factoryForClassName:classname];
        XCTAssertTrue([w.idColumn isEqualToString:[NSClassFromString(classname) idColumn]], @"idColumn isn't copied to the BRORM object");
        XCTAssertTrue([w.tableName isEqualToString:[NSClassFromString(classname) getTableName]], @"tableName isn't copied to the BRORM object");
        XCTAssertTrue([w.className isEqualToString:classname], @"%@ is falsely %@",classname,w.className);
    }
}

- (void)testAutoCreate{
    for (NSString *classname in CLASSNAMES) {
        BROrmWrapper *w = [BROrmWrapper factoryForClassName:classname];
        BRModel *object = [w create:@{@"string":@"string",@"int":@10}];
        XCTAssertNotNil(w, @"BROrmWrapper wasn't created properly");
        XCTAssertNotNil(object, @"BRModel wasn't created properly");
        XCTAssertTrue([object save], @"wasn't able to save");
        XCTAssertNotNil(object[[[object class] idColumn]], @"idColumn wasn't set properly");
        XCTAssertTrue([object[@"string"] isEqualToString:@"string"], @"string wasn't saved properly");
        XCTAssertTrue([object[@"int"] intValue] == 10, @"string wasn't saved properly");
    }
}

- (void)testAutoUpdate{
    for (NSString *classname in CLASSNAMES) {
        BROrmWrapper *w = [BROrmWrapper factoryForClassName:classname];
        BRModel *first = (BRModel *)[w findOne];
        first[@"string"] = @"teststring";
        XCTAssertTrue([first save], @"unable to save");
        first = (BRModel *)[w findOne];
        XCTAssertTrue([first[@"string"] isEqualToString:@"teststring"], @"field wasn't updated");
    }
}

- (void)testAutoFindMany{
    for (NSString *classname in CLASSNAMES) {
        BROrmWrapper *w = [BROrmWrapper factoryForClassName:classname];
        NSArray *objects = [w findMany];
        BRModel *first = objects[0];
        XCTAssertTrue([first isKindOfClass:[NSClassFromString(classname) class]], @"Class is wrong");
        XCTAssertTrue([objects count] == 3, @"Number of objects is wrong");
    }
}


- (void)testAutoFindById{
    for (NSString *classname in CLASSNAMES) {
        BROrmWrapper *w = [BROrmWrapper factoryForClassName:classname];
        BRModel *object = (BRModel *)[w findOne:@(2)];
        XCTAssertNotNil(object, @"Object wasn't red properly");
        NSLog(@"%@",[[object class] idColumn]);
        NSLog(@"%i",[object[[[object class] idColumn]] intValue]);
        XCTAssertTrue([object[[[object class] idColumn]] intValue]==2, @"Wrong object selected");
    }
}
- (void)testAutoLimit{
    for (NSString *classname in CLASSNAMES) {
        BROrmWrapper *w = [BROrmWrapper factoryForClassName:classname];
        w.limit = @1;
        NSArray *testentries = [w findMany];
        XCTAssertTrue([testentries count]==1, @"wrong count");
    }
}

- (void)testAutoOffset{
    for (NSString *classname in CLASSNAMES) {
        NSString *idColum = [NSClassFromString(classname) idColumn];
        
        BROrmWrapper *w = [BROrmWrapper factoryForClassName:classname];
        [w orderBy:@"int" withOrdering:@"ASC"];
        NSArray *all = [w findMany];
        w.offset = @1;
        NSArray *stillAll = [w findMany];
        XCTAssertTrue([all count]==[stillAll count], @"wrong count");
        
        BRModel *second = all[1];
        NSUInteger secondId = [second[idColum] intValue];
        
        w.limit = @1;
        NSArray *justOne = [w findMany];
        XCTAssertTrue(([justOne count])==1, @"wrong count");
        XCTAssertTrue([justOne[0][idColum] intValue] == secondId, @"wrong Element");
    }
}


- (void)testAutoGroupBy{
    for (NSString *classname in CLASSNAMES) {
        BROrmWrapper *w = [BROrmWrapper factoryForClassName:classname];
        [w select:@"int" as:@"int"];
        [w select:@"count(*)" as:@"count"];
        [w groupBy:@"int"];
        NSArray *all = [w findMany];
        XCTAssertTrue(([all count])==2, @"wrong count");
    }
}

- (void)testAutoHaving{
    for (NSString *classname in CLASSNAMES) {
        BROrmWrapper *w = [BROrmWrapper factoryForClassName:classname];
        [w having:@"int = 2"];
        NSArray *stillAll = [w findMany];
        XCTAssertTrue(([stillAll count])==3, @"wrong count");
    }
}

- (void)testAutoGroupByAndHaving{
    for (NSString *classname in CLASSNAMES) {
        BROrmWrapper *w = [BROrmWrapper factoryForClassName:classname];
        [w select:@"int" as:@"int"];
        [w select:@"count(*)" as:@"count"];
        [w groupBy:@"int"];
        [w having:@"int = 2"];
        NSArray *all = [w findMany];
        XCTAssertTrue(([all count])==1, @"wrong count");
    }
}

- (void)testAutoFindByWhereFilter{
    for (NSString *classname in CLASSNAMES) {
        BROrmWrapper *w = [BROrmWrapper factoryForClassName:classname];
        [w whereLike:@"string" value:@"string%"];
        NSArray *testentries = [w findMany];
        XCTAssertTrue([testentries count]==3, @"Anzahl ist falsch.");
        XCTAssertTrue([w count]==3, @"Anzahl ist falsch.");
        
        w = [BROrmWrapper factoryForClassName:classname];
        [w whereLike:@"string" value:@"%3"];
        testentries = [w findMany];
        XCTAssertTrue([testentries count]==1, @"Anzahl ist falsch.");
        XCTAssertTrue([w count]==1, @"Anzahl ist falsch.");
        
        w = [BROrmWrapper factoryForClassName:classname];
        [w whereNotLike:@"string" value:@"%3"];
        testentries = [w findMany];
        XCTAssertTrue([testentries count]==2, @"Anzahl ist falsch.");
        XCTAssertTrue([w count]==2, @"Anzahl ist falsch.");
        
        w = [BROrmWrapper factoryForClassName:classname];
        [w whereEquals:@"string" value:@"string 1"];
        testentries = [w findMany];
        XCTAssertTrue([testentries count]==1, @"Anzahl ist falsch.");
        XCTAssertTrue([w count]==1, @"Anzahl ist falsch.");
        
        w = [BROrmWrapper factoryForClassName:classname];
        [w whereNotEquals:@"string" value:@"string 1"];
        testentries = [w findMany];
        XCTAssertTrue([testentries count]==2, @"Anzahl ist falsch.");
        XCTAssertTrue([w count]==2, @"Anzahl ist falsch.");
        
        w = [BROrmWrapper factoryForClassName:classname];
        [w whereIdIs:@(1)];
        testentries = [w findMany];
        XCTAssertTrue([testentries count]==1, @"Anzahl ist falsch.");
        XCTAssertTrue([w count]==1, @"Anzahl ist falsch.");
    }
}

- (void)testHasOneOrMany{
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"DefaultClass"];
    BRModel *d = (BRModel *)[w findOne:@"1"];
    NSArray *objects = [[d hasOneOrMany:@"DefaultClass"] findMany];
    XCTAssertTrue([objects count]==2, @"Anzahl ist falsch.");
    
    w = [BROrmWrapper factoryForClassName:@"CustomClass"];
    CustomClass *c = (CustomClass*)[w findOne:@"1"];
    objects = [[c hasOneOrMany:@"CustomClass" withForeignKey:@"custom_class_table_foreign_key"] findMany];
    XCTAssertTrue([objects count]==2, @"Anzahl ist falsch.");
}

// TODO: add test for lazy save
// TODO: add test for transactional save
// TODO: add test for hasAndBelongsToMany

//- (void)testHasAndBelongsToMany{
//    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
//    BRTesttable *t = (BRTesttable*)[w findOne:@"1"];
//    NSArray *singer = [[t hasMany:@"Singer" through:@"singer_test" withForeignKey:@"singer_identifier" andBaseKey:@"testtable_identifier"] findMany];
//    XCTAssertTrue([singer count]==2, @"Anzahl ist falsch.");
//
//    t = (BRTesttable*)[w findOne:@"3"];
//    Singer *asinger = (Singer*)[[t hasMany:@"Singer" through:@"singer_test" withForeignKey:@"singer_identifier" andBaseKey:@"testtable_identifier"] findOne];
//    XCTAssertTrue(asinger, @"Wurde nicht gefunden.");
//
//}


@end
