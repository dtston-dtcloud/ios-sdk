//
//  KTSheetView.h
//  
//
//  Created by hcl on 15/10/13.
//
//

#import <UIKit/UIKit.h>

@protocol KTSheetViewDelegate <NSObject>
- (void)sheetViewDidSelectIndex:(NSInteger)Index selectTitle:(NSString *)title;
@end

@interface KTSheetView : UIView
@property (weak, nonatomic) id<KTSheetViewDelegate> delegate;
@property (assign, nonatomic) CGFloat cellHeight;
@property (strong, nonatomic) NSArray *dataSource;

@property (weak, nonatomic) IBOutlet UIButton *cancleButton;
@end
