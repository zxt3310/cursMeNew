//
//  UINewBubbleTableView.h
//
//  Created by Alex Barinov
//  StexGroup, LLC
//  http://www.stexgroup.com
//
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>

#import "UINewBubbleTableViewDataSource.h"
#import "UINewBubbleTableViewCell.h"
#import "UINewBubbleTableViewBookInfoCell.h"
#import "CMNewMyBookListCell.h"
#import "UINewBubbleTableViewBookInfoUptCell.h"
#import "UINewBubbleTableViewTelephoneCell.h"
#import "UINewBubbleTableViewMapInfoCell.h"
#import "UINewBubbleTableViewTextRemindCell.h"

@class CMNewQueryViewController;

@interface UINewBubbleTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

{
    IBOutlet UINewBubbleTableViewCell *bubbleCell;
}

@property (nonatomic, strong) CMNewQueryViewController *chatViewController;
@property (nonatomic, assign) id<UINewBubbleTableViewDataSource> bubbleDataSource;
@property (nonatomic) NSTimeInterval snapInterval;

@end
