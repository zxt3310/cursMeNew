//
//  LeveyPopListView.m
//  LeveyPopListViewDemo
//
//  Created by Levey on 2/21/12.
//  Copyright (c) 2012 Levey. All rights reserved.
//

#import "LeveyPopListView.h"
#import "LeveyPopListViewCell.h"

#define POPLISTVIEW_SCREENINSET 100.
#define POPLISTVIEW_HEADER_HEIGHT 40.
#define POPLISTVIEW_HEIGHT 260.
#define RADIUS 5.

@interface LeveyPopListView (private)
- (void)fadeIn;
- (void)fadeOut;
@end

@implementation LeveyPopListView
@synthesize delegate;
#pragma mark - initialization & cleaning up
- (id)initWithTitle:(NSString *)aTitle options:(NSArray *)aOptions
{
//    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    CGRect rect = CGRectMake(0, 0, 320, 480);
    if (self = [super initWithFrame:rect])
    {
        self.backgroundColor = [UIColor clearColor];
        _title = [aTitle copy];
        _options = [[CMDataUtils defaultDataUtil] officeTypeArray];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(POPLISTVIEW_SCREENINSET,
                                                                   0,
//                                                                   POPLISTVIEW_SCREENINSET + POPLISTVIEW_HEADER_HEIGHT, 
                                                                   rect.size.width - 2 * POPLISTVIEW_SCREENINSET,
                                                                   POPLISTVIEW_HEIGHT)];
        _tableView.separatorColor = [UIColor colorWithWhite:0 alpha:.2];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [self addSubview:_tableView];
        NSLog(@"LeveyPopListView init: %@, tableView: %@", self, _tableView);
    }
    return self;    
}

- (void)dealloc
{
}

#pragma mark - Private Methods
- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];

}
- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

#pragma mark - Tableview datasource & delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"PopListViewCell";
    
    NSInteger row = [indexPath row];
    if (!_options || _options.count <= row) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefaultCell"];
        }
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell ==  nil) {
        cell = [[LeveyPopListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentity];
    }
    OfficeTypeUnit *unit = (OfficeTypeUnit *)[_options objectAtIndex:row];
    cell.imageView.image = unit.officeIcon;
    cell.textLabel.text = unit.officeName;
    
    return cell;
}

- (void)dismissFromSuperView
{
    // tell the delegate the cancellation
    if (self.delegate && [self.delegate respondsToSelector:@selector(leveyPopListViewDidCancel)]) {
        [self.delegate leveyPopListViewDidCancel];
    }
    
    // dismiss self
    [self fadeOut];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // tell the delegate the selection
    if (self.delegate && [self.delegate respondsToSelector:@selector(leveyPopListView:didSelectedIndex:)]) {
        [self.delegate leveyPopListView:self didSelectedIndex:[indexPath row]];
    }
    
    // tell the delegate the cancellation
    if (self.delegate && [self.delegate respondsToSelector:@selector(leveyPopListViewDidCancel)]) {
        [self.delegate leveyPopListViewDidCancel];
    }

    // dismiss self
    [self fadeOut];
}
#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissFromSuperView];
}

#pragma mark - DrawDrawDraw
- (void)drawRect:(CGRect)rect
{
//    CGRect bgRect = CGRectInset(rect, POPLISTVIEW_SCREENINSET, POPLISTVIEW_SCREENINSET);
//    CGRect titleRect = CGRectMake(POPLISTVIEW_SCREENINSET + 10, POPLISTVIEW_SCREENINSET + 10 + 5,
//                                  rect.size.width -  2 * (POPLISTVIEW_SCREENINSET + 10), 30);
//    CGRect separatorRect = CGRectMake(POPLISTVIEW_SCREENINSET, POPLISTVIEW_SCREENINSET + POPLISTVIEW_HEADER_HEIGHT - 2,
//                                      rect.size.width - 2 * POPLISTVIEW_SCREENINSET, 2);
    CGRect bgRect = CGRectInset(rect, POPLISTVIEW_SCREENINSET, 0);
//    CGRect titleRect = CGRectMake(POPLISTVIEW_SCREENINSET + 10, 5, rect.size.width - 2 * (POPLISTVIEW_SCREENINSET + 10), 30);
//    CGRect separatorRect = CGRectMake(POPLISTVIEW_SCREENINSET, POPLISTVIEW_HEADER_HEIGHT - 2, rect.size.width - 2 * POPLISTVIEW_SCREENINSET, 2);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw the background with shadow
    CGContextSetShadowWithColor(ctx, CGSizeZero, 6., [UIColor colorWithWhite:0 alpha:.75].CGColor);
    [[UIColor colorWithWhite:0 alpha:.75] setFill];
    
    
    float x = POPLISTVIEW_SCREENINSET;
    float y = 0;
//    float y = POPLISTVIEW_SCREENINSET;
    float width = bgRect.size.width;
    float height = POPLISTVIEW_HEIGHT;
//    float height = bgRect.size.height;
    CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, x, y + RADIUS);
	CGPathAddArcToPoint(path, NULL, x, y, x + RADIUS, y, RADIUS);
	CGPathAddArcToPoint(path, NULL, x + width, y, x + width, y + RADIUS, RADIUS);
	CGPathAddArcToPoint(path, NULL, x + width, y + height, x + width - RADIUS, y + height, RADIUS);
	CGPathAddArcToPoint(path, NULL, x, y + height, x, y + height - RADIUS, RADIUS);
	CGPathCloseSubpath(path);
	CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGPathRelease(path);
    
    // Draw the title and the separator with shadow
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0.5f, [UIColor blackColor].CGColor);
//    [[UIColor colorWithRed:0.020 green:0.549 blue:0.961 alpha:1.] setFill];
//    [_title drawInRect:titleRect withFont:[UIFont systemFontOfSize:16.]];
//    CGContextFillRect(ctx, separatorRect);
}

@end
