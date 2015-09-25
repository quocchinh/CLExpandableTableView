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

- (void)refreshSection:(NSInteger)section
{
    
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
    
    UIView *viewFromDataSource = [self.dataSource expandableTableView:self viewForHeaderInSection:section];
    viewFromDataSource.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView.contentView addSubview:viewFromDataSource];
    
    [headerView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[viewFromDataSource]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(viewFromDataSource)]];
    [headerView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[viewFromDataSource]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(viewFromDataSource)]];
    
    return headerView;
}


@end
