//
//  BRClassListViewController.m
//  BROrm
//
//  Created by Cornelius Horstmann on 13.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BRClassListViewController.h"
#import "BRClassViewController.h"
#import "BRClass.h"
#import "BRSchool.h"

@interface BRClassListViewController (){
    BROrmWrapper *_w;
    BRSchool *_school;
}

@end

@implementation BRClassListViewController


- (id)initWithSchool:(BRSchool*)school{
    self = [super init];
    if(self){
        _school = school;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    _w = [_school hasOneOrMany:@"BRClass"];
    _w.limit = @1;
    
    if(_school){
        UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
        self.navigationItem.rightBarButtonItem = plusButton;
    }
}

- (void)add{
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"BRClass"];
    BRClass *new = [w create:@{
                               @"name":[NSString stringWithFormat:@"Class %i",_school.numberOfClasses+1],
                               @"school_identifier":_school[@"identifier"]}];
    [new save];
    [self.tableView reloadData];
}
- (BRClass*)classAtIndex:(NSInteger)index{
    _w.offset = @(index);
    return (BRClass *)[_w findOne];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}


#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BRClassViewController *classViewController = [[BRClassViewController alloc] initWithClass:[self classAtIndex:indexPath.row]];
    [self.navigationController pushViewController:classViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _school.numberOfClasses;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    cell.textLabel.text = [self classAtIndex:indexPath.row][@"name"];
    cell.detailTextLabel.text = [self classAtIndex:indexPath.row].school[@"name"];
    
    return cell;
}


@end
