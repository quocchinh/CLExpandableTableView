//
//  CLExpandableTableView.m
//  CLExpandableTableView
//
//  Created by Chinh Le on 9/23/15.
//  Copyright © 2015 CL. All rights reserved.
//

#import "CLExpandableTableView.h"
#import "CLExpandableLoadingTableViewCell.h"

static NSString* const kHeaderViewIdentifier = @"HeaderViewIdentifier";
static const CGFloat kDefaultSectionSpacing = 20.0;
static const CGFloat kDefaultRowHeight = 100;
static const CGFloat kDefaultSectionHeaderHeight = 150;


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



// Key = @(section id) , value = @(SectionState)
@property (nonatomic,strong) NSMutableDictionary *sectionStateDict;

@end

@implementation CLExpandableTableView {
}

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
    self.tableView.delegate = self;
    
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kHeaderViewIdentifier];
    
    self.tableView.sectionFooterHeight = kDefaultSectionSpacing;
    
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
#pragma mark - Properties

- (void)setDataSource:(id<CLExpandableTableViewDataSource>)dataSource
{
    _dataSource = dataSource;
    self.tableView.dataSource = self;
}




#pragma mark -
#pragma mark - Public methods

- (void)collapseAndExpandSection:(NSInteger)section
{
    [self collapseSection:section];
    [self attemptToExpandSection:section];
}

- (void)setSectionSpacing:(CGFloat)spacing
{
    self.tableView.sectionFooterHeight = spacing;
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
            return [self.dataSource expandableTableView:self numberOfRowsInSection:section];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource respondsToSelector:@selector(expandableTableView:heightForRowAtIndexPath:)]) {
        return [self.dataSource expandableTableView:self heightForRowAtIndexPath:indexPath];
    } else {
        return kDefaultRowHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SectionState state = [self sectionState:indexPath.section];
    
    switch (state) {
        case SectionStateLoading: {
            
            CLExpandableLoadingTableViewCell *cell;
            
            if ([self.dataSource respondsToSelector:@selector(tableView:loadingCellForSection:)]) {
                cell = [self.dataSource tableView:tableView loadingCellForSection:indexPath.section];
            } else {
                cell = [tableView dequeueReusableCellWithIdentifier:[CLExpandableLoadingTableViewCell reuseIdentifier]];
                if (!cell) {
                    NSLog(@"New default Loading cell");
                    cell = [CLExpandableLoadingTableViewCell loadFromXib];
                }
            }
            
            [cell.activityIndicatorView startAnimating];
            return cell;
            break;
        }
            
        case SectionStateExpanded:
            return [self.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
            break;
        
        default:
            return [[UITableViewCell alloc] init];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return kDefaultSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(expandableTableView:heightForHeaderInSection:)]) {
        return [self.dataSource expandableTableView:self heightForHeaderInSection:section];
    } else {
        return kDefaultSectionHeaderHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SectionState state = [self sectionState:section];
    
    UITableViewHeaderFooterView *headerView;
    
    if ((state == SectionStateExpanded || state == SectionStateLoading) && [self.dataSource respondsToSelector:@selector(tableView:viewForExpandedHeaderInSection:)] ) {
        headerView = [self.dataSource tableView:self.tableView viewForExpandedHeaderInSection:section];
    } else
    if ([self.dataSource respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        headerView = [self.dataSource tableView:self.tableView viewForHeaderInSection:section];
    }
    
    // Add invisible button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    btn.tag = section;
    [btn addTarget:self action:@selector(sectionHeaderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [headerView.contentView addSubview:btn];
    
    [headerView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btn]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
    [headerView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btn]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(expandableTableView:didSelectRowAtIndexPath:)]) {
        [self.delegate expandableTableView:self didSelectRowAtIndexPath:indexPath];
    }
}


@end
