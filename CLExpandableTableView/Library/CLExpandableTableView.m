//
//  CLExpandableTableView.m
//  CLExpandableTableView
//
//  Created by Chinh Le on 9/23/15.
//  Copyright © 2015 CL. All rights reserved.
//

#import "CLExpandableTableView.h"

static NSString* const kHeaderViewIdentifier = @"HeaderViewIdentifier";


typedef NS_ENUM(NSInteger, SectionState) {
    SectionStateCollapsed,
    SectionStateLoading,
    SectionStateExpanded
};



@interface CLExpandableTableView()
<
UITableViewDataSource,
UITableViewDelegate
>

@property (nonatomic,strong) UITableView *tableView;

// Key = @(section id) , value = @(SectionState)
@property (nonatomic,strong) NSMutableDictionary *sectionStateDict;

@end

@implementation CLExpandableTableView

#pragma mark -
#pragma mark - Init

- (instancetype)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    [self setupTableView];
    [self setInitialSectionState];
}

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kHeaderViewIdentifier];
    
    [self positionTableView];
}

- (void)positionTableView
{
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.tableView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:@{@"tableView":self.tableView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:nil views:@{@"tableView":self.tableView}]];
}

- (void)setInitialSectionState
{
    self.sectionStateDict = [NSMutableDictionary new];
}



#pragma mark -
#pragma mark - Public methods

- (void)reloadSection:(NSInteger)section
{
    [self collapseSection:section];
    [self attemptToExpandSection:section];
}




#pragma mark -
#pragma mark - Private Methods

- (SectionState)sectionState:(NSInteger)section
{
    if (self.sectionStateDict[@(section)]) {
        return [self.sectionStateDict[@(section)] integerValue];
    } else {
        [self setSectionState:SectionStateCollapsed forSection:section];
        return SectionStateCollapsed;
    }
}

- (void)setSectionState:(SectionState)state forSection:(NSInteger)section
{
    [self.sectionStateDict setObject:@(state) forKey:@(section)];
}

-(NSArray*) indexPathsForSection:(NSInteger)section withNumberOfRows:(NSInteger)numberOfRows {
    NSMutableArray* indexPaths = [NSMutableArray new];
    for (int i = 0; i < numberOfRows; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

- (void)sectionHeaderTouchUpInside:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSInteger section = btn.tag;
    SectionState state = [self sectionState:section];
    
    if (state == SectionStateCollapsed) {
        [self attemptToExpandSection:section];
    } else {
        [self attemptToCollapseSection:section];
    }
}

- (void)attemptToExpandSection:(NSInteger)section
{
    BOOL expandable = YES;
    if ([self.delegate respondsToSelector:@selector(expandableTableView:willExpandSection:)]) {
        expandable = [self.delegate expandableTableView:self willExpandSection:section];
    }
    
    if (expandable) {
        [self expandSection:section];
    } else {
        [self showLoadingSection:section];
    }
}

- (void)expandSection:(NSInteger)section
{
    [self setSectionState:SectionStateExpanded forSection:section];
    NSInteger numOfRowsToInsert = [self.dataSource expandableTableView:self numberOfRowsInSection:section];

    [self.tableView beginUpdates];
    NSArray *indexPaths = [self indexPathsForSection:section withNumberOfRows:numOfRowsToInsert];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)showLoadingSection:(NSInteger)section
{
    if ([self sectionState:section] == SectionStateLoading) return;
    
    [self setSectionState:SectionStateLoading forSection:section];
    NSInteger numOfRowsToInsert = 1;
    
    [self.tableView beginUpdates];
    NSArray *indexPaths = [self indexPathsForSection:section withNumberOfRows:numOfRowsToInsert];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)attemptToCollapseSection:(NSInteger)section
{
    BOOL collapsable = YES;
    if ([self.delegate respondsToSelector:@selector(expandableTableView:willCollapseSection:)]) {
        collapsable = [self.delegate expandableTableView:self willCollapseSection:section];
    }
    
    if (!collapsable) return;
    
    [self collapseSection:section];
}

- (void)collapseSection:(NSInteger)section
{
    SectionState state = [self sectionState:section];
    NSInteger numOfRowsToDelete;
    if (state == SectionStateExpanded) {
        numOfRowsToDelete = [self.dataSource expandableTableView:self numberOfRowsInSection:section];
    } else {
        numOfRowsToDelete = 1;
    }
    [self setSectionState:SectionStateCollapsed forSection:section];
    
    [self.tableView beginUpdates];
    NSArray *indexPaths = [self indexPathsForSection:section withNumberOfRows:numOfRowsToDelete];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}



#pragma mark -
#pragma mark - TableView Delegate and DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch ([self sectionState:section]) {
        case SectionStateCollapsed:
            return 0;
            break;
            
        case SectionStateLoading:
            return 1;
            break;
            
        case SectionStateExpanded:
            return 2;
            break;
            
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource numberOfSectionsInExpandableTableView:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SectionState state = [self sectionState:indexPath.section];
    
    switch (state) {
        case SectionStateLoading:
            if ([self.dataSource respondsToSelector:@selector(expandableTableView:loadingCellForSection:)]) {
                return [self.dataSource expandableTableView:self loadingCellForSection:indexPath.section];
            } else {
                // TODO: default loading cell
                return [[UITableViewCell alloc] init];
            }
            break;
            
        case SectionStateExpanded:
            return [self.dataSource expandableTableView:self cellForRowAtIndexPath:indexPath];
            break;
        
        default:
            return [[UITableViewCell alloc] init];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kHeaderViewIdentifier];
    [[headerView.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Add view from data source
    UIView *viewFromDataSource = [self.dataSource expandableTableView:self viewForHeaderInSection:section];
    viewFromDataSource.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView.contentView addSubview:viewFromDataSource];
    
    [headerView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[viewFromDataSource]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(viewFromDataSource)]];
    [headerView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[viewFromDataSource]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(viewFromDataSource)]];
    
    // Add invisible button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = section;
    [btn addTarget:self action:@selector(sectionHeaderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [headerView.contentView addSubview:btn];
    
    [headerView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btn]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
    [headerView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btn]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
    
    return headerView;
}


@end
