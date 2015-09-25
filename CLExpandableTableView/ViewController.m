//
//  ViewController.m
//  CLExpandableTableView
//
//  Created by Chinh Le on 9/23/15.
//  Copyright © 2015 CL. All rights reserved.
//

#import "ViewController.h"
#import "CLExpandableTableView.h"


@interface ViewController () <CLExpandableTableViewDataSource, CLExpandableTableViewDelegate>

@property (nonatomic,weak) IBOutlet CLExpandableTableView *expandableTableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInExpandableTableView:(CLExpandableTableView *)tableView
{
    return 6;
}

- (CGFloat)expandableTableView:(CLExpandableTableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100;
}

- (UIView *)expandableTableView:(CLExpandableTableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = section % 2 == 0 ? [UIColor redColor] : [UIColor blueColor];
    return v;
}

- (NSInteger)expandableTableView:(CLExpandableTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)expandableTableView:(CLExpandableTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] init];
}

-(BOOL)expandableTableView:(CLExpandableTableView *)tableView willExpandSection:(NSInteger)section
{
    return NO;
}


@end
