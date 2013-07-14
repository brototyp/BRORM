//
//  BRModel.h
//  BROrm
//
//  Created by Cornelius Horstmann on 15.06.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BROrm.h"

@class FMDatabaseQueue, BROrm, BROrmWrapper;

@interface BRModel : NSObject

@property (nonatomic,retain) BROrm *orm;

//- (id)initWithDatabaseQueue:(FMDatabaseQueue*)databaseQueue;
- (id)initWithOrm:(BROrm*)orm;

- (BOOL)save;
- (BOOL)destroy;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
- (void)setFromDictionary:(NSDictionary*)dictionary;


/*
 * Select * from <className> where <className>.<this tableName>_identifier = ?
 */
- (BROrmWrapper*)hasOneOrMany:(NSString*)className;
- (BROrmWrapper*)hasOneOrMany:(NSString*)className withForeignKey:(NSString*)foreignKey;

- (BROrmWrapper*)hasMany:(NSString*)className through:(NSString*)jointable withForeignKey:(NSString*)foreignKey andBaseKey:(NSString*)baseKey;

+ (NSString*)getTableName;
+ (NSString*)idColumn;

@end

@interface BROrmWrapper : BROrm

@property (nonatomic,retain) NSString *className;

+ (BROrmWrapper*)factoryForClassName:(NSString*)classname;
+ (BROrmWrapper*)factoryForClassName:(NSString*)classname andDatabaseQueue:(FMDatabaseQueue*)databaseQueue;

@end