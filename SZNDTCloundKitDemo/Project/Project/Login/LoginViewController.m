//
//  Created by JianWei Chen on 16/8/1.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import <DTCloudKit/DTCloudKit.h>
#import "DeviceListViewController.h"
#import "LoginViewController.h"
#import "NSString+Helper.h"
#import "SVProgressHUD.h"
#import "KTActionSheet.h"

#define DTCloudKitAppId     @"<#深智云开发者平台申请的APPID#>"
#define DTCloudKitAppKey    @"<#深智云开发者平台申请的APPKEY#>"

@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *securityEyeBtn;

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    [self setNavigationBarTitle:@"登录"];
    self.navigationItem.leftBarButtonItem = nil;
    
    self.passwordTF.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"DTPASSWORD"];
    self.phoneTF.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"DTPHONE"];
    
    [self setNavigationBarTitle:@"登录"];
    [self setRightButtonTitle:@"开发环境"];
}

- (IBAction)loginBtnAction:(UIButton *)sender
{
    if (![_phoneTF.text isMobileNumber]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码.."];
        return;
    }
    
    if (![_passwordTF.text isRegexPassword]) {
        [SVProgressHUD showErrorWithStatus:@"请输入6-20位字母或数字密码\n不包含除_@.之外的特殊符号"];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showInfoWithStatus:@"正在登录..."];
    });
    
    [self loginActionStart];
}

// 开始登录
- (void)loginActionStart
{
    /*
     * 登录，传入用户名和密码
     */
    [SVProgressHUD showWithStatus:@"登录中。。。"];
    [[DTCloudManager defaultJNI_iOS_SDK]loginWithUsername:self.phoneTF.text password:self.passwordTF.text successCallback:^(NSDictionary *dict) {
        if ([dict[@"errcode"] intValue] == 0) {
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DeviceListViewController *controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"DeviceListViewController"];
            [self.navigationController pushViewController:controller animated:YES];
            
            [[NSUserDefaults standardUserDefaults]setValue:self.phoneTF.text forKey:@"DTPHONE"];
            [[NSUserDefaults standardUserDefaults]setValue:self.passwordTF.text forKey:@"DTPASSWORD"];
            
            [SVProgressHUD showSuccessWithStatus:@"您已安全登录！"];
        } else {
            [SVProgressHUD showInfoWithStatus:dict[@"errmsg"]];
        }
    } errorCallback:^(NSDictionary *dic) {
        [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
    }];
}

- (IBAction)securityEyeAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.passwordTF.secureTextEntry = !sender.selected;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)onRightButtonClick:(UIButton *)sender
{
    KTActionSheet *sheet=[[KTActionSheet alloc]initWithTitle:@"手机网络环境切换" itemTitles:@[@"开发环境",@"正式生产环境",@"亚马逊服务器"]];
    sheet.delegate=self;
    sheet.tag = 100;
    
    [sheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
        [sender setTitle:title forState:UIControlStateNormal];
        if (index == 0) {
            [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
            [[DTCloudManager defaultJNI_iOS_SDK]setSanBox:YES];
            [[DTCloudManager defaultJNI_iOS_SDK]startAppId:DTCloudKitAppId appKey:DTCloudKitAppKey successCallback:nil errorCallback:nil];
        }else if (index == 1){
            [[DTCloudManager defaultJNI_iOS_SDK]setSanBox:NO];
            [[DTCloudManager defaultJNI_iOS_SDK]startAppId:DTCloudKitAppId appKey:DTCloudKitAppKey successCallback:nil errorCallback:nil];
        }else if (index == 2){
            [[DTCloudManager defaultJNI_iOS_SDK]setServerURL:@"<#服务器URL#>"];
            [[DTCloudManager defaultJNI_iOS_SDK]setMQTTURL:@"<#推送服务器#>"];
            [[DTCloudManager defaultJNI_iOS_SDK]startAppId:DTCloudKitAppId appKey:DTCloudKitAppKey successCallback:nil errorCallback:nil];
        }
    }];
}

- (void)onLeftButtonClick:(id)sender
{
    
}
@end
