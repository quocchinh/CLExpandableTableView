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
- (UITableViewHeaderFooterView *)expandableTableView:(CLExpandableTableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (NSInteger)expandableTableView:(CLExpandableTableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)expandableTableView:(CLExpandableTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;



@optional
- (CGFloat)expandableTableView:(CLExpandableTableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)expandableTableView:(CLExpandableTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

// This is optional if you want to supply different section header view when it's expanded
- (UITableViewHeaderFooterView *)expandableTableView:(CLExpandableTableView *)tableView viewForExpandedHeaderInSection:(NSInteger)section;

// If not supplied, we will use the default loading cell
- (CLExpandableLoadingTableViewCell *)expandableTableView:(CLExpandableTableView *)tableView loadingCellForSection:(NSInteger)section;


@optional

@end


@protocol CLExpandableTableViewDelegate <NSObject>

@optional

// This method is called when user taps on a section header, attempting to expand it. If the data is ready to be displayed, delegate returns YES
// Else, return NO, tableView will show a row with activity indicator. Meanwhile we perform loading of data and refresh section when it's done
- (BOOL)expandableTableView:(CLExpandableTableView *)tableView willExpandSection:(NSInteger)section;

// Easy, collapse it, returns NO if dont allow collapsing. But really, who does that ?
- (BOOL)expandableTableView:(CLExpandableTableView *)tableView willCollapseSection:(NSInteger)section;


- (void)expandableTableView:(CLExpandableTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end


                                          
                                          
@interface CLExpandableTableView : UIView

@property (nonatomic,weak) IBOutlet id<CLExpandableTableViewDataSource> dataSource;
@property (nonatomic,weak) IBOutlet id<CLExpandableTableViewDelegate> delegate;

@property (nonatomic,strong) UITableView *tableView;

- (void)collapseAndExpandSection:(NSInteger)section;


/*
 If section is collapsed, attempt to expand the section, subject to delegate's willExpandSection permissions
 If section is expanded, collapse it
 */
- (void)toggleSectionState:(NSInteger)section;

- (void)reloadData;

- (void)setSectionSpacing:(CGFloat)spacing;

@end
