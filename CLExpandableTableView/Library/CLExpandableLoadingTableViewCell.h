//
//  CLExpandableLoadingTableViewCell.h
//  CLExpandableTableView
//
//  Created by Chinh Le on 9/25/15.
//  Copyright © 2015 CL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLExpandableLoadingTableViewCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;

+ (instancetype)loadFromXib;
+ (NSString *)reuseIdentifier;

@end
