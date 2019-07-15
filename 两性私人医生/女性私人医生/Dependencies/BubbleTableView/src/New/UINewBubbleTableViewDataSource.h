//
//  UINewBubbleTableViewDataSource.h
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

#import <Foundation/Foundation.h>

@class NSBubbleData;
@class UINewBubbleTableView;
@protocol UINewBubbleTableViewDataSource <NSObject>

@optional

@required

- (NSInteger)rowsForBubbleTable:(UINewBubbleTableView *)tableView;
- (NSBubbleData *)bubbleTableView:(UINewBubbleTableView *)tableView dataForRow:(NSInteger)row;

@end
