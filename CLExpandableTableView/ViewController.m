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

@implementation ViewController {
    BOOL loadingDone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    loadingDone = NO;
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

- (UITableViewCell *)expandableTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] init];
}

-(BOOL)expandableTableView:(CLExpandableTableView *)tableView willExpandSection:(NSInteger)section
{
    if (!loadingDone) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            loadingDone = YES;
            [tableView reloadSection:section];
        });
    }
    
    return loadingDone;
}


@end
