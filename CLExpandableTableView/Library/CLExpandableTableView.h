//
//  CLExpandableTableView.h
//  CLExpandableTableView
//
//  Created by Chinh Le on 9/23/15.
//  Copyright © 2015 CL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLExpandableTableView;
@class CLExpandableLoadingTableViewCell;

@protocol CLExpandableTableViewDataSource <NSObject>

- (NSInteger)numberOfSectionsInExpandableTableView:(CLExpandableTableView *)tableView;
- (CGFloat)expandableTableView:(CLExpandableTableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (UIView *)expandableTableView:(CLExpandableTableView *)tableView viewForHeaderInSection:(NSInteger)section;

- (NSInteger)expandableTableView:(CLExpandableTableView *)tableView numberOfRowsInSection:(NSInteger)section;


// For this we need to pass in the private tableView so that data source can ultilize tableview's dequeuereusablecell 
- (UITableViewCell *)expandableTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;


@optional
- (CLExpandableLoadingTableViewCell *)loadingCellForExpandableTableView:(CLExpandableTableView *)tableView;


@optional

@end


@protocol CLExpandableTableViewDelegate <NSObject>

@optional

// This method is called when user taps on a section header, attempting to expand it. If the data is ready to be displayed, delegate returns YES
// Else, return NO, tableView will show a row with activity indicator. Meanwhile we perform loading of data and refresh section when it's done
- (BOOL)expandableTableView:(CLExpandableTableView *)tableView willExpandSection:(NSInteger)section;

// Easy, collapse it, returns NO if dont allow collapsing. But really, who does that ?
- (BOOL)expandableTableView:(CLExpandableTableView *)tableView willCollapseSection:(NSInteger)section;

@end


                                          
                                          
@interface CLExpandableTableView : UIView

@property (nonatomic,weak) IBOutlet id<CLExpandableTableViewDataSource> dataSource;
@property (nonatomic,weak) IBOutlet id<CLExpandableTableViewDelegate> delegate;


- (void)reloadSection:(NSInteger)section;

@end
