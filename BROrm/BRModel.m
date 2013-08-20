//
//  BRModel.m
//  BROrm
//
//  Created by Cornelius Horstmann on 15.06.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BRModel.h"
#import "BROrm.h"
#import "FMDatabaseQueue.h"

#import "NSString+Inflections.h"

@class BROrmWrapper;

@interface BRModel(){
    BROrm *_orm;
}

@end

@implementation BRModel

- (id)initWithDatabaseQueue:(FMDatabaseQueue*)databaseQueue{
    self = [super init];
    if(self){
        _orm = [BROrm forTable:[[self class] getTableName] inDatabase:databaseQueue];
    }
    return self;
}
- (id)initWithOrm:(BROrm*)orm{
    self = [super init];
    if(self){
        _orm = orm;
    }
    return self;
}

- (BOOL)save{
    if(![_orm save]) return FALSE;
    
    if(_orm.lastInsertRowId){
        NSString *idcolumn = [[self class] idColumn];
        _orm[idcolumn] = _orm.lastInsertRowId;
    }
    return YES;
}

- (BOOL)destroy{
    NSString *idcolumn = [[self class] idColumn];
    return [BROrm executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",[[self class] getTableName],idcolumn]
           withArgumentsInArray:self[idcolumn]
                inDatabaseQueue:_orm.databaseQueue];
}

// TODO: delete


//#pragma mark key subscripting
- (id)objectForKeyedSubscript:(id <NSCopying>)key{
    return _orm[key];
}
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key{
    _orm[key] = obj;
}

- (void)setFromDictionary:(NSDictionary*)dictionary{
    for (id <NSCopying> key in [dictionary allKeys]) {
        _orm[key] = dictionary[key];
    }
}

- (BROrmWrapper*)hasOneOrMany:(NSString*)className{
    return [self hasOneOrMany:className withForeignKey:[NSString stringWithFormat:@"%@_identifier",[[self class] getTableName]]];
}

- (BROrmWrapper*)hasOneOrMany:(NSString*)className withForeignKey:(NSString*)foreignKey{
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:className andDatabaseQueue:_orm.databaseQueue];
    [w whereEquals:[NSString stringWithFormat:@"%@.%@",[NSClassFromString(className) getTableName],foreignKey] value:self[[[self class] idColumn]]];
    
    return w;
}

- (BROrmWrapper*)hasMany:(NSString*)className through:(NSString*)jointable withForeignKey:(NSString*)foreignKey andBaseKey:(NSString*)baseKey{
    //@"SELECT tag.name from image_tag LEFT JOIN tag ON (tag.identifier = image_tag.tag_id) WHERE image_tag.image_id = ?"
    
    Class joinclass = NSClassFromString(className);
    
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:className andDatabaseQueue:_orm.databaseQueue];
    [w join:jointable withConstraints:@[@{
                                               @"type":@"=",
                                               @"column":[NSString stringWithFormat:@"%@.%@",jointable,foreignKey],
                                               @"value":[NSString stringWithFormat:@"%@.%@",[joinclass getTableName],[joinclass idColumn]],
                                               @"trust_value":@(1)}] andAlias:jointable];
    [w whereEquals:[NSString stringWithFormat:@"%@.%@",jointable,baseKey] value:self[[[self class] idColumn]]];
    return w;
}

#pragma mark private
+ (NSString*)getTableName{
    return [NSStringFromClass ([self class]) underscore];
}
+ (NSString*)idColumn{
    return @"identifier";
}

@end





@implementation BROrmWrapper

+ (BROrmWrapper*)factoryForClassName:(NSString*)classname{
    if(!self.defaultQueue) return NULL;
    return [self factoryForClassName:classname andDatabaseQueue:self.defaultQueue];
}
+ (BROrmWrapper*)factoryForClassName:(NSString*)classname andDatabaseQueue:(FMDatabaseQueue*)databaseQueue{
    BROrmWrapper *orm = [[BROrmWrapper alloc] init];
    if(orm){
        Class class = NSClassFromString(classname);
        orm.tableName = [class getTableName];
        orm.databaseQueue = databaseQueue;
        orm.className = classname;
    }
    return orm;
}

- (id)findOne{
    return [self createModelInstance:[super findOne:NULL]];
}

- (id)findOne:(NSString*)identifier{
    return [self createModelInstance:[super findOne:identifier]];
}

- (NSArray*)findMany{
    NSArray *many = [super findMany];
    
    NSMutableArray *returnIt = [@[] mutableCopy];
    
    for (BROrm *orm in many) {
        [returnIt addObject:[self createModelInstance:orm]];
    }
    
    return returnIt;
}

- (id)create:(NSDictionary*)data{
    return [self createModelInstance:[super create:data]];
}

- (id)createModelInstance:(BROrm*)orm{
    if(!orm) return NULL;
    id returnIt = [[NSClassFromString(_className) alloc] initWithOrm:orm];
    return returnIt;
}

@end




