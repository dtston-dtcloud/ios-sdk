//
//  UCInfomationView.m
//  ICAlertViewAndActionSheet
//
//  Created by JianWei Chen on 16/7/26.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import "AlertViewManager.h"
#import <UIKit/UIKit.h>

@interface  AlertViewManager()

@end

@implementation AlertViewManager

+ (AlertViewManager *)shareManager
{
    static AlertViewManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AlertViewManager alloc]init];
    });
    return manager;
}

- (void)initWithTitle:(NSString*)title message:(NSString *)messge cancleButtonTitle:(NSString *)cancleButtonTitle OtherButtonsArray:(NSArray*)otherButtons clickAtIndex:(ClickAtIndexBlock) clickAtIndex;

{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messge preferredStyle:UIAlertControllerStyleAlert];
    NSMutableArray *list = [[NSMutableArray alloc]init];
    [list addObject:cancleButtonTitle];
    [list addObjectsFromArray:otherButtons];
    
    for (NSString *string in list) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:string style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (clickAtIndex) {
                clickAtIndex([list indexOfObject:string],alertController);
            }
        }];
        [alertController addAction:action];
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)initWithMessage:(NSString *)messge cancleButtonTitle:(NSString *)cancleButtonTitle OtherButtonsArray:(NSArray *)otherButtons clickAtIndex:(ClickAtIndexBlock)clickAtIndex
{
    [self initWithTitle:@"提示" message:messge cancleButtonTitle:cancleButtonTitle OtherButtonsArray:otherButtons clickAtIndex:clickAtIndex];
}

- (void)initWithMessage:(NSString *)messge cancleButtonTitle:(NSString *)cancleButtonTitle clickAtIndex:(ClickAtIndexBlock)clickAtIndex
{
    [self initWithTitle:@"提示" message:messge cancleButtonTitle:cancleButtonTitle OtherButtonsArray:nil clickAtIndex:clickAtIndex];
}

- (void)initWithEditActionTitle:(NSString *)title message:(NSString *)messge cancleButtonTitle:(NSString *)cancleButtonTitle OtherButtonsArray:(NSArray *)otherButtons clickAtIndex:(ClickAtIndexBlock)clickAtIndex
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:messge preferredStyle:UIAlertControllerStyleAlert];
    NSMutableArray *list = [[NSMutableArray alloc]init];
    [list addObject:cancleButtonTitle];
    [list addObjectsFromArray:otherButtons];
    
    for (NSString *string in list) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:string style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (clickAtIndex) {
                clickAtIndex([list indexOfObject:string],alertController);
            }
        }];
        [alertController addAction:action];
    }
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}
@end
