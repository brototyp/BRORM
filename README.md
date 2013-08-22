BRORM
=====

Another Objective-C SQLite ORM


Usage
====

Installation
----

You can install `BRORM` via Cocoapod. Just add the following line to your Podfile.
```objectivec
pod 'BRORM', '~> 0.1'
```

Setup
----
I am using [FMDB](https://github.com/ccgus/fmdb) as SQLite wrapper.

``` objectivec
NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"database.sqlite"];
_databaseQueue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
[BROrm setDefaultQueue:_databaseQueue];
```

Add your migrations for the database.

``` objectivec
[BROrm executeUpdate:@"CREATE TABLE IF NOT EXISTS default_class (identifier INTEGER PRIMARY KEY AUTOINCREMENT, string TEXT, int INTEGER, default_class_identifier INTEGER);" withArgumentsInArray:NULL];
```

Create a subclass of BRModel for each Model u want to use.

- Per default the `tableName` is the underscored classname. Override `+ (NSString*)getTableName` if you want to change it. 
- Per default the `idColumn` is `identifier`. Override `+ (NSString*)idColumn` if you want to change it.

If you want do change the table name and or the id column globally you can just subclass `BRModel`, override it in there an then subclass your subclass for each of your models.


``` objectivec
@interface Person : BRModel
@end
@implementation BRTesttable
+ (NSString*)getTableName{
    return @"person";
}
+ (NSString*)idColumn{
    return @"id";
}
@end
```

Read
---
To read or write from the database you have to use a BROrmWrapper with the class name of your model.

_Find Many_ simply selects many results from the database.

- `w.limit`: default none
- `w.tableAlias`: default is the same as the tableName
- `w.distinct`: default no

``` objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
NSArray *persons = [w findMany];
```

_Find One_ sets the limit of the query to 1 and returns the result.

``` objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
Person *person = (Person*)[w findOne];
```

_Find One By Id_

``` objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
Person *person = (Person*)[w findOne:@(2)];
```

_Count_ 

``` objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
int personCount = [w count];
```

Create
---
Creates a new Object. You can either assign an NSDictionary to hydrate the data or change the data on demand.

``` objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
Person *p = [w create:@{@"prename":@"Jason",@"age":@(27)}];
p[@"surname"] = @"Keller";
BOOL success = [p save];
```

Write
---
Assigning data to an object only sets them as dirty if they changed. The save method only lazy saves the values that got changed. If nothing changed the wouldn't be any update.

``` objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
Person *p = (Person*)[w findOne:@"2"];
[p setFromDictionary:@{@"street":@"Some Ave. 1234",@"city":@"somecity"}]
p[@"prename"] = @"Jason";
BOOL success = [p save];
```

Delete
---

``` objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
Person *p = (Person*)[w findOne:@"2"];
BOOL success = [p destroy];
```

Filter
---

``` objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
[w whereEquals:@"prename" value:@"Jason"];
// [w whereNotEquals:@"prename" value:@"Jason"];
// [w whereLike:@"prename" value:@"Ja%"];
// [w whereNotLike:@"prename" value:@"Ja%"];
// [w whereIdIs:@(1)];
NSArray *jasons = [w findMany];
```

Relationships
---
- HasOneOrMany

``` objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
Person *t = (Person*)[w findOne:@"1"];
NSArray *customer = [[t hasOneOrMany:@"Customer"] findMany];
```

- hasAndBelongsToMany

``` objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
Person *t = (Person*)[w findOne:@"1"];
NSArray *customer = [[t hasMany:@"Customer" through:@"customer_person" withForeignKey:@"customer_identifier" andBaseKey:@"person_identifier"] findMany];
```

Limit
---
```objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
w.limit = @1;
NSArray *testentries = [w findMany];
```

Offset
---
```objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
[w orderBy:@"int" withOrdering:@"ASC"];
w.limit = @1;
w.offset = @1;
NSArray *justOne = [w findMany];
```

Group By & Having
---

```objectivec
BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"Person"];
[w select:@"prename" as:@"prename"];
[w select:@"count(*)" as:@"count"];
[w groupBy:@"prename"];
[w having:@"age > 21"];
NSArray *allOverTwentyoneByPrename = [w findMany];
```


Todo
====
- write better documentation
