//
//  BRSchoolListViewController.m
//  BROrm
//
//  Created by Cornelius Horstmann on 13.09.13.
//  Copyright (c) 2013 brototyp.de. All rights reserved.
//

#import "BRSchoolListViewController.h"
#import "BRSchool.h"
#import "BRSchoolViewController.h"

@interface BRSchoolListViewController (){
    BROrmWrapper *_w;
}

@end

@implementation BRSchoolListViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    _w = [BROrmWrapper factoryForClassName:@"BRSchool"];
    _w.limit = @1;
    
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    self.navigationItem.rightBarButtonItem = plusButton;
}

- (void)add{
    BROrmWrapper *w = [BROrmWrapper factoryForClassName:@"BRSchool"];
    BRSchool *new = [w create:@{@"name":[NSString stringWithFormat:@"School %i",[[BROrmWrapper factoryForClassName:@"BRSchool"] count]+1]}];
    [new save];
    [self.tableView reloadData];
}

- (BRSchool*)schoolAtIndex:(NSInteger)index{
    _w.offset = @(index);
    return (BRSchool *)[_w findOne];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BRSchoolViewController *schoolViewController = [[BRSchoolViewController alloc] initWithSchool:[self schoolAtIndex:indexPath.row]];
    [self.navigationController pushViewController:schoolViewController animated:YES];
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[BROrmWrapper factoryForClassName:@"BRSchool"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    

    cell.textLabel.text = [self schoolAtIndex:indexPath.row][@"name"];
    
    return cell;
}

@end
