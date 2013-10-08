//
//  BROrm.h
//  BROrm
//
//  Created by Cornelius Horstmann on 15.06.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabaseQueue;
@class FMDatabase;

@interface BROrm : NSObject

@property (nonatomic,retain) FMDatabaseQueue *databaseQueue;
@property (nonatomic,retain) NSString *tableName;
@property (nonatomic,retain) NSString *tableAlias;
@property (nonatomic,retain) NSNumber *limit;
@property (nonatomic,retain) NSNumber *offset;
@property (nonatomic,retain) NSString *idColumn;
@property (nonatomic,readwrite) BOOL *distinct;


+ (instancetype)forTable:(NSString*)tableName;
+ (instancetype)forTable:(NSString*)tableName inDatabase:(FMDatabaseQueue*)databaseQueue;

+ (NSArray *)executeQuery:(NSString*)query withArgumentsInArray:(NSArray*)arguments;
+ (NSArray *)executeQuery:(NSString*)query withArgumentsInArray:(NSArray*)arguments inDatabaseQueue:(FMDatabaseQueue*)databaseQueue;

+ (BOOL)executeUpdate:(NSString*)query withArgumentsInArray:(NSArray*)arguments;
+ (BOOL)executeUpdate:(NSString*)query withArgumentsInArray:(NSArray*)arguments inDatabaseQueue:(FMDatabaseQueue*)databaseQueue;

+ (BOOL)transactionSaveObjects:(NSArray*)objects inDatabaseQueue:(FMDatabaseQueue*)databaseQueue;

+ (FMDatabaseQueue*)defaultQueue;
+ (void)setDefaultQueue:(FMDatabaseQueue*)databaseQueue;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;


// -----------------------------------------------------------------------------
// read

- (BROrm *)findOne;
- (BROrm *)findOne:(id)identifier;
- (NSDictionary*)findOneAsDictionary:(NSString *)identifier;

- (NSArray*)findMany;
- (NSArray*)findManyAsDictionaries;

- (int)count;

- (void)rawQuery:(NSString *)query withParameters:(NSArray*)parameters;
- (void)select:(NSString*)column as:(NSString*)alias;
- (void)selectExpression:(NSString*)expression as:(NSString*)alias;

- (void)whereIsNull:(NSString*)column;
- (void)whereIsNotNull:(NSString*)column;
- (void)whereRaw:(NSString*)rawCondition;
- (void)whereType:(NSString*)type column:(NSString*)column value:(id)value;
- (void)whereEquals:(NSString*)column value:(id)value;
- (void)whereNotEquals:(NSString*)column value:(id)value;
- (void)whereIdIs:(id)value;
- (void)whereLike:(NSString*)column value:(id)value;
- (void)whereNotLike:(NSString*)column value:(id)value;

- (void)joinType:(NSString*)type onTable:(NSString*)table withConstraints:(NSArray*)constraints andAlias:(NSString*)alias;
- (void)join:(NSString*)table withConstraints:(NSArray*)constraints andAlias:(NSString*)alias;

- (void)orderBy:(NSString*)column withOrdering:(NSString*)ordering;

- (void)groupBy:(NSString*)column;
- (void)having:(NSString*)expression;

// -----------------------------------------------------------------------------
// write
- (id)create;
- (id)create:(NSDictionary*)data;
- (void)forceAllDirty;
- (void)hydrate:(NSDictionary*)data;
- (BOOL)save;


@end
