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

static const NSInteger kNumberOfVisibleSectionBelowWhenCollapsing = 8; // This one is used to fix an auto layout problem when collapsing a section causing a few sections below mis laid out


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
    self.backgroundColor = [UIColor clearColor];
    [self setupTableView];
    [self setInitialSectionState];
}

- (void)setupTableView
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    
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
    [self clearAllSectionState];
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

- (void)clearAllSectionState
{
    self.sectionStateDict = [NSMutableDictionary new];
}

- (void)toggleSectionState:(NSInteger)section
{
    SectionState state = [self sectionState:section];
    
    if (state == SectionStateCollapsed) {
        [self attemptToExpandSection:section];
    } else {
        [self attemptToCollapseSection:section];
    }
}

- (void)reloadData
{
    [self.tableView reloadData];
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
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
//    [CATransaction begin];
//    [CATransaction setCompletionBlock:^{
//        [[self.tableView headerViewForSection:section] setNeedsLayout];
//    }];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [CATransaction commit];
    
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [[self.tableView headerViewForSection:section] setNeedsLayout];
}

- (void)showLoadingSection:(NSInteger)section
{
    if ([self sectionState:section] == SectionStateLoading) return;
    
    [self setSectionState:SectionStateLoading forSection:section];
    NSInteger numOfRowsToInsert = 1;
    
    [self.tableView beginUpdates];
    NSArray *indexPaths = [self indexPathsForSection:section withNumberOfRows:numOfRowsToInsert];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
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
    [self setSectionState:SectionStateCollapsed forSection:section];
    NSInteger numOfRowsToDelete;
    if (state == SectionStateExpanded) {
        numOfRowsToDelete = [self.dataSource expandableTableView:self numberOfRowsInSection:section];
    } else {
        numOfRowsToDelete = 1;
    }   
    
    [self.tableView beginUpdates];
    NSArray *indexPaths = [self indexPathsForSection:section withNumberOfRows:numOfRowsToDelete];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
    // This part is to fix a nasty UItableview autolayout when u collapse a section, all the section headers below won't be properly laid out
    for (NSInteger i=section; i<section + kNumberOfVisibleSectionBelowWhenCollapsing; i++) {
        [[self.tableView headerViewForSection:i] setNeedsLayout];
    }
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
            
            if ([self.dataSource respondsToSelector:@selector(expandableTableView:loadingCellForSection:)]) {
                cell = [self.dataSource expandableTableView:self loadingCellForSection:indexPath.section];
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
            return [self.dataSource expandableTableView:self cellForRowAtIndexPath:indexPath];
            break;
        
        default:
            return [[UITableViewCell alloc] init];
    }
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
    
    if ((state == SectionStateExpanded || state == SectionStateLoading) && [self.dataSource respondsToSelector:@selector(expandableTableView:viewForExpandedHeaderInSection:)] ) {
        headerView = [self.dataSource expandableTableView:self viewForExpandedHeaderInSection:section];
    } else
    if ([self.dataSource respondsToSelector:@selector(expandableTableView:viewForHeaderInSection:)]) {
        headerView = [self.dataSource expandableTableView:self viewForHeaderInSection:section];
    }
    
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
