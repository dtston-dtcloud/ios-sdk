//
//  Created by JianWei Chen on 16/8/1.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import "RegisterViewController.h"
#import <DTCloudKit/DTCloudKit.h>
#import "NSString+Helper.h"
#import "SVProgressHUD.h"

@interface RegisterViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;    // 手机号输入框
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;   // 密码输入框
@property (weak, nonatomic) IBOutlet UITextField *verifyTF;     // 验证码输入框
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;     // 获取验证码按钮
@property (weak, nonatomic) IBOutlet UIButton *securityEyeBtn;

@end

@implementation RegisterViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.phoneTF.delegate = self;
    self.passwordTF.delegate = self;
    self.verifyTF.delegate = self;
    [self setNavigationBarTitle:@"立即注册"];
    [self setLeftButtonImage:[UIImage imageNamed:@"title_icon_back"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - 获得验证码按钮
- (IBAction)getVerifyCodeBtnAction:(UIButton *)sender
{
    
    if (![_phoneTF.text isMobileNumber]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码.."];
        return;
    }
    
    [self getVerifyCodeNumber];
}

// 获得验证码
- (void)getVerifyCodeNumber
{
    /*
     * 注册账号获取验证码，传入用户名
     */
    [[DTCloudManager defaultJNI_iOS_SDK]getRegisterCodeWithUsername:self.phoneTF.text successCallback:^(NSDictionary *dic) {
        [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
        [self setVerifyBtnTimer];
    } errorCallback:^(NSDictionary *dic) {
        [SVProgressHUD showErrorWithStatus:dic[@"errmsg"]];
    }];
}

// 设置定时器
- (void)setVerifyBtnTimer {
    __block int code_out = 60;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (code_out <= 0) {
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [_codeBtn setTitle:@"获取验证码" forState:0];
                [_codeBtn setTitle:@"60秒后获取" forState:UIControlStateDisabled];
                _codeBtn.enabled = YES;
                code_out = 60;
            });
        } else {
            _codeBtn.enabled = NO;
            NSString * time = [NSString stringWithFormat:@"%d秒后获取",code_out];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_codeBtn setTitle:time forState:UIControlStateDisabled];
            });
            code_out -- ;
        }
    });
    dispatch_resume(timer);
}


#pragma mark - 注册按钮点击
- (IBAction)registerBtnAction:(id)sender {
    
    if (![_phoneTF.text isMobileNumber]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码.."];
        return;
    }
    
    if (![_passwordTF.text isRegexPassword]) {
        [SVProgressHUD showErrorWithStatus:@"请输入6-20位字母或数字密码\n不包含除_@.之外的特殊符号"];
        return;
    }
    
    if (_verifyTF.text.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"亲，还未输入验证码..."];
        return;
    }
    
    if (_verifyTF.text.length < 6 || _verifyTF.text.length > 6) {
        [SVProgressHUD showErrorWithStatus:@"亲，请输入6位验证码..."];
        return;
    }
    
    [self registerActionStart];
}

// 开始注册
- (void)registerActionStart
{
    /*
     * 注册账号，传入用户、密码、验证码
     */
    [[DTCloudManager defaultJNI_iOS_SDK]registerWithUsername:self.phoneTF.text password:self.passwordTF.text securityCode:self.verifyTF.text successCallback:^(NSDictionary *dic) {
        
        [SVProgressHUD showSuccessWithStatus:dic[@"errmsg"]];
        
        [[NSUserDefaults standardUserDefaults]setValue:self.phoneTF.text forKey:@"DTPHONE"];
        [[NSUserDefaults standardUserDefaults]setValue:self.passwordTF.text forKey:@"DTPASSWORD"];
        [self.navigationController popViewControllerAnimated:YES];
        
    } errorCallback:^(NSDictionary *dic) {
        
        [SVProgressHUD showSuccessWithStatus:dic[@"errmsg"]];
        
    }];
}

- (IBAction)securityEyeAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.passwordTF.secureTextEntry = !sender.selected;
}

#pragma mark - 键盘弹起事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark -
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

@end
