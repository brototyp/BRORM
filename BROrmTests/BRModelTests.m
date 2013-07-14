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


@interface Singer : BRModel

@end

@implementation Singer

@end

@interface Person : BRModel

@end

@interface BRTesttable : BRModel

@end

@implementation BRTesttable

+ (NSString*)getTableName{
    return @"testtable";
}

- (void)addSinger:(NSArray*)singer{
    
    NSMutableArray *objects = [@[] mutableCopy];
    
    for (Singer *asinger in singer) {
        
        BROrmWrapper *w = [self hasMany:@"Singer" through:@"singer_test" withForeignKey:@"singer_identifier" andBaseKey:@"testtable_identifier"];
        [w whereEquals:@"singer.identifier" value:asinger[@"identifier"]];
        if([w findOne]==NULL){
            BROrm *orm = [BROrm forTable:@"singer_test"];
            [orm create:@{@"singer_identifier":asinger[@"identifier"],
                          @"testtable_identifier":self[@"identifier"]}];
            [objects addObject:orm];
        }
    }
    
    [BROrm transactionSaveObjects:objects inDatabaseQueue:self.orm.databaseQueue];
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
    
    [BROrm executeUpdate:@"CREATE TABLE IF NOT EXISTS testtable (identifier INTEGER PRIMARY KEY AUTOINCREMENT, string TEXT, int INTEGER);" withArgumentsInArray:NULL];
    [BROrm executeUpdate:@"INSERT INTO testtable (string, int) VALUES (?,?)" withArgumentsInArray:@[@"string 1",@(1)]];
    [BROrm executeUpdate:@"INSERT INTO testtable (string, int) VALUES (?,?)" withArgumentsInArray:@[@"string 2",@(2)]];
    [BROrm executeUpdate:@"INSERT INTO testtable (string, int) VALUES (?,?)" withArgumentsInArray:@[@"string 3",@(3)]];
    
    [BROrm executeUpdate:@"CREATE TABLE IF NOT EXISTS singer (identifier INTEGER PRIMARY KEY AUTOINCREMENT, string TEXT, testtable_identifier INTEGER);" withArgumentsInArray:NULL];
    [BROrm executeUpdate:@"INSERT INTO singer (string, testtable_identifier) VALUES (?,?)" withArgumentsInArray:@[@"string 1",@(1)]];
    [BROrm executeUpdate:@"INSERT INTO singer (string, testtable_identifier) VALUES (?,?)" withArgumentsInArray:@[@"string 2",@(1)]];
    [BROrm executeUpdate:@"INSERT INTO singer (string, testtable_identifier) VALUES (?,?)" withArgumentsInArray:@[@"string 3",@(2)]];
    
    
    [BROrm executeUpdate:@"CREATE TABLE IF NOT EXISTS singer_test (identifier INTEGER PRIMARY KEY AUTOINCREMENT, singer_identifier INTEGER, testtable_identifier INTEGER);" withArgumentsInArray:NULL];
    [BROrm executeUpdate:@"INSERT INTO singer_test (singer_identifier,testtable_identifier) VALUES (?,?)" withArgumentsInArray:@[@(1),@(1)]];
    [BROrm executeUpdate:@"INSERT INTO singer_test (singer_identifier,testtable_identifier) VALUES (?,?)" withArgumentsInArray:@[@(1),@(2)]];
    [BROrm executeUpdate:@"INSERT INTO singer_test (singer_identifier,testtable_identifier) VALUES (?,?)" withArgumentsInArray:@[@(2),@(3)]];
    [BROrm executeUpdate:@"INSERT INTO singer_test (singer_identifier,testtable_identifier) VALUES (?,?)" withArgumentsInArray:@[@(3),@(1)]];
    [BROrm executeUpdate:@"INSERT INTO singer_test (singer_identifier,testtable_identifier) VALUES (?,?)" withArgumentsInArray:@[@(3),@(2)]];
}

- (void)tearDown
{
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"test.sqlite"] error:NULL];
    [super tearDown];
}

- (void)testClassDiscovery
{
    NSArray *classnames = @[@"Person",@"SomeBody"];
    
    for (NSString *classname in classnames) {
        BROrmWrapper *w = [BROrmWrapper factoryForClassName:classname];
        XCTAssertTrue([w.className isEqualToString:classname], @"%@ wird nicht korrekt erkannt, war: %@",classname,w.className);
    }
}

- (void)testCreate{
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    BRTesttable *t = [w create:@{@"string":@"string 5",@"int":@(5)}];
    XCTAssertTrue([t save], @"Konnte nicht gespeichert werden.");
    
    w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    [w whereEquals:@"int" value:@(5)];
    t = (BRTesttable*)[w findOne];
    XCTAssertTrue([t[@"string"] isEqualToString:@"string 5"], @"Wurde nicht korrekt gespeichert");
}

- (void)testFindManyClass{
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    NSArray *testentries = [w findMany];
    BRTesttable *first = testentries[0];
    XCTAssertTrue([first isKindOfClass:[BRTesttable class]], @"Klasse ist falsch.");
}

- (void)testSimpleRead{
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    NSArray *testentries = [w findMany];
    XCTAssertTrue([testentries count]==3, @"Anzahl ist falsch.");
}

- (void)testFindById{
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    BRTesttable *testentry = (BRTesttable*)[w findOne:@(2)];
    XCTAssertTrue([testentry[@"identifier"] intValue]==2, @"Abfrage ist so nicht korrekt.");
}

- (void)testFindByWhereFilter{
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    [w whereLike:@"string" value:@"string%"];
    NSArray *testentries = [w findMany];
    XCTAssertTrue([testentries count]==3, @"Anzahl ist falsch.");
    XCTAssertTrue([w count]==3, @"Anzahl ist falsch.");
    
    w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    [w whereLike:@"string" value:@"%3"];
    testentries = [w findMany];
    XCTAssertTrue([testentries count]==1, @"Anzahl ist falsch.");
    XCTAssertTrue([w count]==1, @"Anzahl ist falsch.");
    
    w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    [w whereNotLike:@"string" value:@"%3"];
    testentries = [w findMany];
    XCTAssertTrue([testentries count]==2, @"Anzahl ist falsch.");
    XCTAssertTrue([w count]==2, @"Anzahl ist falsch.");
    
    w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    [w whereEquals:@"string" value:@"string 1"];
    testentries = [w findMany];
    XCTAssertTrue([testentries count]==1, @"Anzahl ist falsch.");
    XCTAssertTrue([w count]==1, @"Anzahl ist falsch.");
    
    w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    [w whereNotEquals:@"string" value:@"string 1"];
    testentries = [w findMany];
    XCTAssertTrue([testentries count]==2, @"Anzahl ist falsch.");
    XCTAssertTrue([w count]==2, @"Anzahl ist falsch.");
    
    w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    [w whereIdIs:@(1)];
    testentries = [w findMany];
    XCTAssertTrue([testentries count]==1, @"Anzahl ist falsch.");
    XCTAssertTrue([w count]==1, @"Anzahl ist falsch.");
}

- (void)testHasOneOrMany{
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    BRTesttable *t = (BRTesttable*)[w findOne:@"1"];
    NSArray *singer = [[t hasOneOrMany:@"Singer"] findMany];
    XCTAssertTrue([singer count]==2, @"Anzahl ist falsch.");
    
    t = (BRTesttable*)[w findOne:@"2"];
    Singer *asinger = (Singer*)[[t hasOneOrMany:@"Singer"] findOne];
    XCTAssertTrue(asinger, @"Wurde nicht gefunden.");
}

- (void)testHasAndBelongsToMany{
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    BRTesttable *t = (BRTesttable*)[w findOne:@"1"];
    NSArray *singer = [[t hasMany:@"Singer" through:@"singer_test" withForeignKey:@"singer_identifier" andBaseKey:@"testtable_identifier"] findMany];
    XCTAssertTrue([singer count]==2, @"Anzahl ist falsch.");
    
    t = (BRTesttable*)[w findOne:@"3"];
    Singer *asinger = (Singer*)[[t hasMany:@"Singer" through:@"singer_test" withForeignKey:@"singer_identifier" andBaseKey:@"testtable_identifier"] findOne];
    XCTAssertTrue(asinger, @"Wurde nicht gefunden.");
    
}

- (void)testTransactionSave{
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    BRTesttable *t = (BRTesttable*)[w findOne:@"1"];
    
    NSArray *singer = [[BROrmWrapper factoryForClassName:@"Singer"] findMany];
    [t addSinger:singer];
    
    singer = [[t hasMany:@"Singer" through:@"singer_test" withForeignKey:@"singer_identifier" andBaseKey:@"testtable_identifier"] findMany];
    XCTAssertTrue([singer count]==3, @"Anzahl ist falsch.");
}

- (void)testSimpleLazySave{
    // Dieser Test kann so nicht überprüft werden
    // Um das hier zu prüfen bitte in die jeweiligen Methoden Breakpoints machen
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"BRTesttable"];
    BRTesttable *testentry = (BRTesttable*)[w findOne:@"2"];
    testentry[@"string"] = testentry[@"string"];
    BOOL success = [testentry save]; //should not save anything, since nothing changed
    
    testentry[@"string"] = @"string 2";
    success = [testentry save]; //should not save anything, since nothing changed
}

@end
