//
//  UCInfomationView.h
//  ICAlertViewAndActionSheet
//
//  Created by JianWei Chen on 16/7/26.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^ClickAtIndexBlock)(NSInteger buttonIndex,UIAlertController *alertController);

@interface AlertViewManager : NSObject

+ (AlertViewManager *)shareManager;

- (void)initWithTitle:(NSString*)title message:(NSString *)messge cancleButtonTitle:(NSString *)cancleButtonTitle OtherButtonsArray:(NSArray*)otherButtons clickAtIndex:(ClickAtIndexBlock) clickAtIndex;
- (void)initWithMessage:(NSString *)messge cancleButtonTitle:(NSString *)cancleButtonTitle OtherButtonsArray:(NSArray*)otherButtons clickAtIndex:(ClickAtIndexBlock) clickAtIndex;
- (void)initWithMessage:(NSString *)messge cancleButtonTitle:(NSString *)cancleButtonTitle clickAtIndex:(ClickAtIndexBlock) clickAtIndex;

- (void)initWithEditActionTitle:(NSString *)title message:(NSString *)messge cancleButtonTitle:(NSString *)cancleButtonTitle OtherButtonsArray:(NSArray *)otherButtons clickAtIndex:(ClickAtIndexBlock)clickAtIndex;
@end
