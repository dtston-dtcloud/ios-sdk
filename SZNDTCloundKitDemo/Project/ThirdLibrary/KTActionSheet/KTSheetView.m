//
//  KTSheetView.m
//  
//
//  Created by hcl on 15/10/13.
//
//

#import "KTSheetView.h"
#import "KTSheetCell.h"

#define kWH ([[UIScreen mainScreen] bounds].size.height)
#define kWW ([[UIScreen mainScreen] bounds].size.width)


@interface KTSheetView()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divLineHeight;

@end

@implementation KTSheetView

- (void)awakeFromNib
{
    _cancleButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    if (kWH == 667) {
        _cancleButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    } else if (kWH > 667) {
        _cancleButton.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    }
    _divLineHeight.constant = 0.5;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled = NO;
}


- (void)didMoveToSuperview
{
    if (_dataSource.count > 6) {
        _tableView.scrollEnabled = YES;
    }
}

#pragma mark - UITableView数据源和代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"KTSheetCell";
    KTSheetCell *cell= [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KTSheetCell" owner:self options:nil].lastObject;
    }
    cell.myLabel.text = _dataSource[indexPath.row];
    
    cell.myLabel.font = [UIFont systemFontOfSize:17];
    if (kWH == 667) {
        cell.myLabel.font = [UIFont systemFontOfSize:20];
    } else if (kWH > 667) {
        cell.myLabel.font = [UIFont systemFontOfSize:21];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger index = indexPath.row;
    KTSheetCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTitle = cell.myLabel.text;

    if ([self.delegate respondsToSelector:@selector(sheetViewDidSelectIndex:selectTitle:)]) {
        [self.delegate sheetViewDidSelectIndex:index selectTitle:cellTitle];
    }
}


@end
