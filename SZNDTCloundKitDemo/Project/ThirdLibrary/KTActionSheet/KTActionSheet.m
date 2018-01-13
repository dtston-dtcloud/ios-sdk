//
//  KTActionSheet.m
//  
//
//  Created by hcl on 15/10/13.
//
//

#import "KTActionSheet.h"
#import "KTSheetView.h"

#define kWH ([[UIScreen mainScreen] bounds].size.height)
#define kWW ([[UIScreen mainScreen] bounds].size.width)
#define kCellHeight 50

@interface KTActionSheet()<KTSheetViewDelegate>
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) UIButton *bgButton;
@property (strong, nonatomic) UIButton *myTitleBtn;
@property (strong, nonatomic) KTSheetView *sheetView;

@property (strong, nonatomic) NSIndexPath *selectIndex;
@property (strong, nonatomic) SelectIndexBlock selectBlock;

@property (strong, nonatomic) NSArray *dataSource;
@property (assign, nonatomic) CGFloat sheetHeight;
@end

@implementation KTActionSheet

- (instancetype)initWithTitle:(NSString *)title itemTitles:(NSArray *)itemTitles
{
    if (self = [super init]) {
    
        _dataSource = itemTitles;
        int cellCount = (int)itemTitles.count;
        if (cellCount > 6) {
            cellCount = 6;
        }
        [[UIApplication sharedApplication].keyWindow addSubview:self];

        _view = [UIApplication sharedApplication].keyWindow;
        //半透明背景按钮
        _bgButton = [[UIButton alloc] init];
        [_view addSubview:_bgButton];
        [_bgButton addTarget:self action:@selector(dismissSheetView) forControlEvents:UIControlEventTouchUpInside];
        _bgButton.backgroundColor = [UIColor blackColor];
        _bgButton.alpha = 0.2;
        _bgButton.frame = CGRectMake(0, 0, kWW, kWH);
        
        //标题
        if (title.length > 0) {
            _myTitleBtn = [[UIButton alloc] init];
            [_view addSubview:_myTitleBtn];
            _myTitleBtn.backgroundColor = [UIColor whiteColor];
            _myTitleBtn.frame = CGRectMake(0, kWH, kWW, kCellHeight);
            [_myTitleBtn setTitle:title forState:UIControlStateNormal];
            [_myTitleBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [_myTitleBtn setTitle:title forState:UIControlStateHighlighted];
            [_myTitleBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
            _myTitleBtn.titleLabel.font = [UIFont systemFontOfSize:17];
            if (kWH == 667) {
                _myTitleBtn.titleLabel.font = [UIFont systemFontOfSize:20];
            } else if (kWH > 667) {
                _myTitleBtn.titleLabel.font = [UIFont systemFontOfSize:21];
            }
        }
        
        //选择TableView
        _sheetView = [[NSBundle mainBundle] loadNibNamed:@"KTSheetView" owner:self options:nil].lastObject;
        _sheetView.delegate = self;
        _sheetView.dataSource = _dataSource;
        [_view addSubview:_sheetView];
        
        _sheetHeight = kCellHeight * (cellCount + 1) + 5;
        _sheetView.frame = CGRectMake(0, kWH + kCellHeight, kWW, _sheetHeight);
        [_sheetView.cancleButton addTarget:self action:@selector(dismissSheetView) forControlEvents:UIControlEventTouchUpInside];
        
        [self pushSheetView];
    }
    return self;
}


- (void)didFinishSelectIndex:(SelectIndexBlock)block
{
    _selectBlock = block;
}

//点击了哪行
- (void)sheetViewDidSelectIndex:(NSInteger)Index selectTitle:(NSString *)title
{
    if (_selectBlock) {
        _selectBlock(Index,title);
    }
    
    if ([self.delegate respondsToSelector:@selector(sheetViewDidSelectIndex:title:sender:)]) {
        [self.delegate sheetViewDidSelectIndex:Index title:title sender:self];
    }
    [self dismissSheetView];
}

//出现
- (void)pushSheetView
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.myTitleBtn.frame = CGRectMake(0, kWH - weakSelf.sheetHeight - kCellHeight, kWW, kCellHeight);
        weakSelf.sheetView.frame = CGRectMake(0, kWH - weakSelf.sheetHeight, kWW, weakSelf.sheetHeight);
        weakSelf.bgButton.alpha = 0.2;
    }];
}

//消失
- (void)dismissSheetView
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.myTitleBtn.frame = CGRectMake(0, kWH, kWW, kCellHeight);
        weakSelf.sheetView.frame = CGRectMake(0, kWH + kCellHeight, kWW, weakSelf.sheetHeight);
        weakSelf.bgButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        [weakSelf.sheetView removeFromSuperview];
        [weakSelf.bgButton removeFromSuperview];
        [weakSelf.myTitleBtn removeFromSuperview];
        [weakSelf removeFromSuperview];
    }];
}

@end
