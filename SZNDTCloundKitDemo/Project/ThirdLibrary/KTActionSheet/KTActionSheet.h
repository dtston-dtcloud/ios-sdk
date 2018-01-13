//
//  KTActionSheet.h
//  
//
//  Created by hcl on 15/10/13.
//
//

#import <UIKit/UIKit.h>

typedef void (^SelectIndexBlock)(NSInteger index, NSString *title);

@protocol KTActionSheetDelegate <NSObject>
- (void)sheetViewDidSelectIndex:(NSInteger)index title:(NSString *)title sender:(id)sender;
@end

@interface KTActionSheet : UIView
@property (weak, nonatomic) id delegate;

///初始化方法,title不传则不显示,itemTitles个数大于6时,才可滑动tableView
- (id)initWithTitle:(NSString *)title itemTitles:(NSArray *)itemTitles;

///回调block中包含选中的index和title---也可实现代理方法获取选中的数据
- (void)didFinishSelectIndex:(SelectIndexBlock)block;

@end
