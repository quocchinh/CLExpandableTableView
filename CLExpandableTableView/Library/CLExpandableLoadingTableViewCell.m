//
//  CLExpandableLoadingTableViewCell.m
//  CLExpandableTableView
//
//  Created by Chinh Le on 9/25/15.
//  Copyright © 2015 CL. All rights reserved.
//

#import "CLExpandableLoadingTableViewCell.h"

@implementation CLExpandableLoadingTableViewCell

+ (instancetype)loadFromXib
{
    CLExpandableLoadingTableViewCell *cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] firstObject];
    
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
