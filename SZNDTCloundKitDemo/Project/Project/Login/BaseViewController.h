//
//  Created by JianWei Chen on 16/8/1.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define AlertContent(content) \
UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" \
message:content \
delegate:nil   \
cancelButtonTitle:@"确定" \
otherButtonTitles:nil];  \
[alert show];  \

@interface BaseViewController : UIViewController<UITextFieldDelegate>

@property (strong, nonatomic)UIButton *leftButton;
@property (strong, nonatomic)UIButton *rightButton;

- (void)setNavigationBarTitle:(NSString *)title;
- (void)setLeftButtonImage:(UIImage *)image;
- (void)setLeftButtonTitle:(NSString *)title;
- (void)setRightButtonTitle:(NSString *)title;
- (void)setRightButtonImage:(UIImage *)image;
- (void)onLeftButtonClick:(id)sender;
- (void)onRightButtonClick:(id)sender;
- (void)refreshInformation;
- (void)refreshBaseControlValue;
@end
