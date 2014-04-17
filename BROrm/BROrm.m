//
//  BROrm.m
//  BROrm
//
//  Created by Cornelius Horstmann on 15.06.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BROrm.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"


@interface BROrm(){
    BOOL _isNew;
    
    NSMutableDictionary *_data;
    NSMutableArray *_dirtyFields;
    
    BOOL _isRawQuery;
    NSString *_rawQuery;
    NSArray *_rawParameters;
    
    NSArray *_parameters; //former values
    NSMutableArray *_columns;
    
    NSMutableArray *_whereConditions;
    NSMutableArray *_joins;
    NSMutableArray *_orders;
    NSMutableArray *_groups;
    
    NSString *_havingExpression;
}


- (BOOL)saveInTransaction:(FMDatabase *)database;

@end

static FMDatabaseQueue *_defaultQueue = NULL;
#ifdef BRORM_LOGGING
static BOOL _logging = YES;
#else
static BOOL _logging = NO;
#endif

@implementation BROrm

- (id)init{
    self = [super init];
    if(self){
        _idColumn = @"identifier";
        _columns = [NSMutableArray array];
        _whereConditions = [NSMutableArray array];
        _joins = [NSMutableArray array];
        _orders = [NSMutableArray array];
        _dirtyFields = [NSMutableArray array];
        _groups = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)forTable:(NSString*)tableName{
    return [self forTable:tableName inDatabase:_defaultQueue];
}
+ (instancetype)forTable:(NSString*)tableName inDatabase:(FMDatabaseQueue*)databaseQueue{
    if(!databaseQueue){
        if(_logging) NSLog(@"[ERROR:] No databaseQueue given");
        return NULL;
    }
    if(!tableName){
        if(_logging) NSLog(@"[ERROR:] No tableName given");
        return NULL;
    }
    BROrm *orm = [[BROrm alloc] init];
    if(orm){
        orm.tableName = tableName;
        orm.databaseQueue = databaseQueue;
    }
    return orm;
}

+ (NSArray *)executeQuery:(NSString*)query withArgumentsInArray:(NSArray*)arguments{
    if(!_defaultQueue){
        if(_logging) NSLog(@"[ERROR:] defaultQueue is not set. Use +executeQuery:withAurgumentsInArray:inDatabaseQueue instead");
        return NULL;
    }
    return [self executeQuery:query withArgumentsInArray:arguments inDatabaseQueue:_defaultQueue];
}

+ (NSArray *)executeQuery:(NSString*)query withArgumentsInArray:(NSArray*)arguments inDatabaseQueue:(FMDatabaseQueue*)databaseQueue{
    __block NSMutableArray *returnIt = [NSMutableArray array];
    [databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:query withArgumentsInArray:arguments];
        NSArray *keys = [BROrm sortedKeysForResultSet:resultSet];
        
        while ([resultSet next]) {
            [returnIt addObject:[self dictionaryFromCurrentRowInResultSet:resultSet withKeys:keys]];
        }
        [resultSet close];
    }];
    if([returnIt count] == 0) return NULL;
    return [NSArray arrayWithArray:returnIt];
}

+ (BOOL)executeUpdate:(NSString*)query withArgumentsInArray:(NSArray*)arguments{
    if(!_defaultQueue) return false;
    return [self executeUpdate:query withArgumentsInArray:arguments inDatabaseQueue:_defaultQueue];
}

+ (BOOL)executeUpdate:(NSString*)query withArgumentsInArray:(NSArray*)arguments inDatabaseQueue:(FMDatabaseQueue*)databaseQueue{
    return [self executeUpdate:query withArgumentsInArray:arguments inDatabaseQueue:databaseQueue withLockBlock:^(FMDatabase *db){}];
}

+ (BOOL)executeUpdate:(NSString*)query withArgumentsInArray:(NSArray*)arguments inDatabaseQueue:(FMDatabaseQueue*)databaseQueue withLockBlock:(void (^)(FMDatabase *db))block{
    __block BOOL success = NO;
    [databaseQueue inDatabase:^(FMDatabase *db) {
        success = [db executeUpdate:query withArgumentsInArray:arguments];
        block(db);
    }];
    return success;
}

+ (BOOL)transactionSaveObjects:(NSArray*)objects inDatabaseQueue:(FMDatabaseQueue*)databaseQueue{
    __block BOOL success = NO;
    [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        BOOL success = true;
        
        for (BROrm *orm in objects) {
            success = success && [orm saveInTransaction:db];
        }
        
        if (!success) {
            *rollback = YES;
            return;
        }
    }];
    return success;
}

+ (void)setDefaultQueue:(FMDatabaseQueue*)databaseQueue{
    _defaultQueue = databaseQueue;
}

+ (FMDatabaseQueue*)defaultQueue{
    return _defaultQueue;
}

#pragma mark -
#pragma mark reading

- (NSDictionary*)findOneAsDictionary:(NSString *)identifier{
    if(_isRawQuery){
        return [[self findManyAsDictionaries] objectAtIndex:0];
    } else {
        _limit = @(1);
        return [[self findManyAsDictionaries] objectAtIndex:0];
    }
}

- (BROrm *)findOne{
    return [self findOne:NULL];
}

- (BROrm *)findOne:(id)identifier{
    if(!_tableName){
        if(_logging) NSLog(@"[ERROR:] No tableName given");
        return NULL;
    }
    if(identifier){
        [_whereConditions removeAllObjects];
        [self whereIdIs:identifier];
    }
    
    NSDictionary *first_dict = [self findOneAsDictionary:identifier];
    if(!first_dict) return NULL;
    
    BROrm *first = [BROrm forTable:_tableName inDatabase:_databaseQueue];
    [first hydrate:first_dict];
    return first;
}

- (NSArray*)findMany{
    if(!_tableName){
        if(_logging) NSLog(@"[ERROR:] No tableName given");
        return NULL;
    }
    NSArray *many = [self findManyAsDictionaries];
    
    NSMutableArray *returnIt = [@[] mutableCopy];
    for (NSDictionary *one in many) {
        BROrm *current = [BROrm forTable:_tableName inDatabase:_databaseQueue];
        [current hydrate:one];
        [returnIt addObject:current];
    }
    return returnIt;
}

- (NSArray*)findManyAsDictionaries{
    return [self run];
}

- (int)count{
    if(_isRawQuery){
        return [[self findMany] count];
    } else {
        _columns = [NSMutableArray arrayWithArray:@[@"COUNT(*) as count"]];
        NSDictionary *result = [self findOneAsDictionary:NULL];
        return [[result objectForKey:@"count"] intValue];
    }
}

- (void)rawQuery:(NSString *)query withParameters:(NSArray*)parameters{
    _isRawQuery = YES;
    _rawQuery = query;
    _rawParameters = parameters;
}

- (void)select:(NSString*)column as:(NSString*)alias{
    [self addResultColumn:column as:alias];
}

- (void)selectExpression:(NSString*)expression as:(NSString*)alias{
    [self addResultColumn:expression as:alias];
}

- (void)whereIsNull:(NSString*)column{
    [_whereConditions addObject:@{@"raw_condition":[NSString stringWithFormat:@"%@ IS NULL",column]}];
}
- (void)whereIsNotNull:(NSString*)column{
    [_whereConditions addObject:@{@"raw_condition":[NSString stringWithFormat:@"%@ IS NOT NULL",column]}];
}
- (void)whereRaw:(NSString*)rawCondition{
    [_whereConditions addObject:@{@"raw_condition":rawCondition}];
}
- (void)whereType:(NSString*)type column:(NSString*)column value:(id)value{
    [_whereConditions addObject:@{@"column":column,@"type":type,@"value":value}];
}
- (void)whereEquals:(NSString*)column value:(id)value{
    [self whereType:@"=" column:column value:value];
}
- (void)whereNotEquals:(NSString*)column value:(id)value{
    [self whereType:@"!=" column:column value:value];
}
- (void)whereIdIs:(id)value{
    [self whereType:@"=" column:_idColumn value:value];
}
- (void)whereLike:(NSString*)column value:(id)value{
    [self whereType:@"LIKE" column:column value:value];
}
- (void)whereNotLike:(NSString*)column value:(id)value{
    [self whereType:@"NOT LIKE" column:column value:value];
}

- (void)joinType:(NSString*)type onTable:(NSString*)table withConstraints:(NSArray*)constraints andAlias:(NSString*)alias{
    [_joins addObject:@{
                        @"type":type,
                        @"table":table,
                        @"constraints":constraints,
                        @"alias":alias}];
}
- (void)join:(NSString*)table withConstraints:(NSArray*)constraints andAlias:(NSString*)alias{
    [self joinType:@"" onTable:table withConstraints:constraints andAlias:alias];
}

- (void)orderBy:(NSString*)column withOrdering:(NSString*)ordering{
    [_orders addObject:@{
                         @"column":column,
                         @"ordering":ordering}];
}


- (void)groupBy:(NSString*)column{
    [_groups addObject:column];
}

- (void)having:(NSString*)expression{
    _havingExpression = expression;
}


#pragma mark writing


- (id)create{
    _isNew = YES;
    return self;
}

- (id)create:(NSDictionary*)data{
    _isNew = YES;
    if(data != NULL){
        [self hydrate:data];
        [self forceAllDirty];
    }
    return self;
}

- (void)hydrate:(NSDictionary*)data{
    _data = [data mutableCopy];
}



- (void)forceAllDirty{
    _dirtyFields = [[_data allKeys] mutableCopy];
}

- (void)generateSaveQueryWithBlock:(void (^)(NSString *query, NSArray *values))block{
    
    if([_dirtyFields count] == 0){
        block(NULL,NULL);
        return;
    }
    
    NSMutableDictionary *toSave = [NSMutableDictionary dictionary];
    for (NSString *key in _dirtyFields) {
        [toSave setObject:[_data objectForKey:key] forKey:key];
    }
    
    NSArray *values;
    NSString *query;
    if(_isNew){
        query = [self buildInsert:toSave];
        values = [toSave allValues];
    } else {
        query = [self buildUpdate:toSave];
        values = [[toSave allValues] arrayByAddingObject:[_data objectForKey:_idColumn]];
    }
    
    block(query,values);
}

- (BOOL)save{
    
    __block BOOL success = false;
    [self generateSaveQueryWithBlock:^(NSString *query,NSArray *values){
        if(query == NULL | values == NULL){
            success = true;
        } else {
            success = [BROrm executeUpdate:query withArgumentsInArray:values inDatabaseQueue:_databaseQueue withLockBlock:^(FMDatabase *db){
                if(_isNew){
                    _data[_idColumn] = @([db lastInsertRowId]);
                    _isNew = NO;
                }
            }];
        }
    }];
    
    if(success)
        _dirtyFields = [@[] mutableCopy];
    return success;
}

- (BOOL)saveInTransaction:(FMDatabase *)database{
    __block BOOL success = false;
    [self generateSaveQueryWithBlock:^(NSString *query,NSArray *values){
        if(query == NULL | values == NULL){
            success = true;
        } else {
            success = [database executeUpdate:query withArgumentsInArray:values];
            if(success){
                [_data setObject:@([database lastInsertRowId]) forKey:_idColumn];
                _isNew = NO;
            }
        }
    }];
    if(success)
        _dirtyFields = [@[] mutableCopy];
    return success;
}


#pragma mark key subscripting
- (id)objectForKeyedSubscript:(id <NSCopying>)key{
    return [_data objectForKey:key];
}
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key{
    if([[_data objectForKey:key] isEqual:obj]) return;
    [_data setObject:obj forKey:key];
    if(![_dirtyFields containsObject:key])
        [_dirtyFields addObject:key];
}

#pragma mark -
#pragma mark private

#pragma mark read
- (void)addResultColumn:(NSString*)column as:(NSString*)alias{
    if(alias){
        [_columns addObject:[NSString stringWithFormat:@"%@ AS %@",column,alias]];
    } else {
        [_columns addObject:column];
    }
}

- (NSString*)buildSelect{
    _parameters = NULL;
    if(_isRawQuery){
        _parameters = _rawParameters;
        return _rawQuery;
    }
    return [@[
              [self buildSelectStart],
              [self buildJoin],
              [self buildWhere],
              [self buildGroupBy],
              [self buildHaving],
              [self buildOrderBy],
              [self buildLimit],
              [self buildOffset],
              ] componentsJoinedByString:@" "];
}

- (NSString*)buildSelectStart{
    NSString *columns;
    if([_columns count] == 0) columns = @"*";
    else columns = [_columns componentsJoinedByString:@", "];
    
    if (_distinct) {
        columns = [@"Distinct " stringByAppendingString:columns];
    }
    
    NSString *fragment = [NSString stringWithFormat:@"SELECT %@ FROM %@",columns,_tableName];
    
    if (_tableAlias) {
        fragment = [NSString stringWithFormat:@"%@ as %@",fragment,_tableAlias];
    }
    return fragment;
}

- (NSString*)buildJoin{
    NSMutableArray *joins = [NSMutableArray array];
    for (NSDictionary *join in _joins) {
        NSString *conditionstring = [self buildConditions:[join objectForKey:@"constraints"]];
        NSString *tablestring = [join objectForKey:@"table"];
        if([join objectForKey:@"alias"])
            [tablestring stringByAppendingString:[NSString stringWithFormat:@"AS %@",[join objectForKey:@"alias"]]];
        [joins addObject:[NSString stringWithFormat:@"%@ JOIN %@ ON (%@)",
                          [join objectForKey:@"type"],
                          [join objectForKey:@"table"],
                          conditionstring]];
    }
    return [joins componentsJoinedByString:@" "];
}

- (NSString*)buildLimit{
    if(!_limit) return @"";
    return [NSString stringWithFormat:@"LIMIT %i",[_limit intValue]];
}

- (NSString*)buildOffset{
    if(!_offset || !_limit) return @"";
    return [NSString stringWithFormat:@"OFFSET %i",[_offset intValue]];
}

- (NSString*)buildWhere{
    if([_whereConditions count] == 0) return @"";
    return [NSString stringWithFormat:@"WHERE %@",[self buildConditions:_whereConditions]];
}

- (NSString*)buildOrderBy{
    if([_orders count]==0) return @"";
    NSMutableArray *orders = [NSMutableArray array];
    for (NSDictionary *order in _orders) {
        [orders addObject:[NSString stringWithFormat:@"%@ %@",
                           [order objectForKey:@"column"],
                           [order objectForKey:@"ordering"]]];
    }
    return [@"ORDER BY " stringByAppendingString:[orders componentsJoinedByString:@", "]];
}

- (NSString*)buildConditions:(NSArray*)conditions{
    NSMutableArray *conditionsarray = [NSMutableArray array];
    NSMutableArray *m_parameters = [_parameters mutableCopy];
    if(!m_parameters) m_parameters = [@[] mutableCopy];
    for (NSDictionary *condition in conditions) {
        if([condition objectForKey:@"raw_condition"]){
            [conditionsarray addObject:[condition objectForKey:@"raw_condition"]];
        } else {
            [conditionsarray addObject:[NSString stringWithFormat:@"%@ %@ ?",[condition objectForKey:@"column"],[condition objectForKey:@"type"]]];
            [m_parameters addObject:[condition objectForKey:@"value"]];
        }
    }
    _parameters = m_parameters;
    if([conditionsarray count] == 0) return @"";
    return [conditionsarray componentsJoinedByString:@" AND "];
}

- (NSString*)buildGroupBy{
    if([_groups count] == 0) return @"";
    NSString *groupByString = @"GROUP BY ";
    
    groupByString = [groupByString stringByAppendingString:[_groups componentsJoinedByString:@","]];
    
    return groupByString;
}

- (NSString*)buildHaving{
    if(!_havingExpression || [_groups count] == 0) return @"";
    return [@"HAVING " stringByAppendingString:_havingExpression];
}

- (NSArray*)run{
    NSString *query = [self buildSelect];
    if(_logging) NSLog(@"[QUERY:] %@ with: %@",query,_parameters);
    return [BROrm executeQuery:query withArgumentsInArray:_parameters inDatabaseQueue:_databaseQueue];
}

+ (NSArray*)sortedKeysForResultSet:(FMResultSet*)resultSet{
    NSMutableArray *returnIt = [NSMutableArray array];
    for(int i = 0; i<[resultSet columnCount]; i++)
        [returnIt addObject:[resultSet columnNameForIndex:i]];
    return [NSArray arrayWithArray:returnIt];
}

+ (NSDictionary*)dictionaryFromCurrentRowInResultSet:(FMResultSet*)resultSet withKeys:(NSArray*)keys{
    if(![resultSet hasAnotherRow]) return NULL;
    
    NSMutableDictionary *returnIt = [NSMutableDictionary dictionary];
    
    for (NSString *key in keys) {
        [returnIt setObject:[resultSet objectForColumnName:key] forKey:key];
    }
    
    return [NSDictionary dictionaryWithDictionary:returnIt];
}

#pragma mark write


- (NSString*)buildUpdate:(NSDictionary*)data{
    NSString *query = [NSString stringWithFormat:@"UPDATE %@ SET ",_tableName];
    
    NSMutableArray *fields = [NSMutableArray array];
    for (NSString *key in data) {
        [fields addObject:[NSString stringWithFormat:@"%@ = ?",key]];
    }
    query = [query stringByAppendingString:[fields componentsJoinedByString:@", "]];
    query = [query stringByAppendingString:[NSString stringWithFormat:@" WHERE %@ = ?",_idColumn]];
    return query;
}
- (NSString*)buildInsert:(NSDictionary*)data{
    NSString *query = [NSString stringWithFormat:@"INSERT INTO %@ ",_tableName];
    
    NSMutableArray *fields = [NSMutableArray array];
    NSMutableArray *placeholders = [NSMutableArray array];
    for (NSString *key in data) {
        [fields addObject:key];
        [placeholders addObject:@"?"];
    }
    query = [query stringByAppendingString:[NSString stringWithFormat:@"(%@)",[fields componentsJoinedByString:@", "]]];
    query = [query stringByAppendingString:[NSString stringWithFormat:@" VALUES (%@)",[placeholders componentsJoinedByString:@", "]]];
    return query;
}

@end
