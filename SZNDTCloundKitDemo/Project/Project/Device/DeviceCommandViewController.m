//
//  DeviceCommandViewController.m
//  SZNDTCloundKitDemo
//
//  Created by JianWei Chen on 16/12/14.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import "DeviceCommandViewController.h"
#import <DTCloudKit/DTCloudKit.h>
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "APNumberPad.h"
#import "APDarkPadStyle.h"
#import "APBluePadStyle.h"
#import "KTActionSheet.h"

@interface DeviceCommandViewController ()<APNumberPadDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView    *tableView;
@property (weak, nonatomic) IBOutlet UIButton *communicationButton;
@property (weak, nonatomic) IBOutlet UIButton *protocolButton;

@property (weak, nonatomic) IBOutlet UIButton *timerStartButton;
@property (weak, nonatomic) IBOutlet UIButton *timerPauseButton;
@property (weak, nonatomic) IBOutlet UITextField *timerTextField;

@property (nonatomic, strong) NSTimer *sendTimer;
@property (strong, nonatomic) UITextField *functionCodeTextField;
@property (strong, nonatomic) UITextField *functionCommandTextField;
@property (strong, nonatomic) UITextView *deviceBackTextView;
@property (nonatomic, strong) UIWebView *webView;
@property (strong, nonatomic) UITextView *functionCommandTextView;
@property (assign, nonatomic) CGFloat commandHeight;


@end

@implementation DeviceCommandViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notifyMQTTBack:) name:NOTIFY_MQTT_BACK object:nil];
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

- (void)refreshBaseControlValue
{
    [self setNavigationBarTitle:[NSString stringWithFormat:@"设备控制(%@)",self.device.macAddress]];
    [self setLeftButtonImage:[UIImage imageNamed:@"title_icon_back"]];
    [self setRightButtonTitle:@"发送"];
    self.communicationButton.tag = DeviceUsedByWiFi;
    self.protocolButton.tag = DTSDKProtocolTypeSecond;
    self.tableView.scrollEnabled = NO;
    self.tableView.clipsToBounds = YES;
    
    self.timerTextField.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"timeValue"];
    int protocol = [[[NSUserDefaults standardUserDefaults]valueForKey:@"protocol"]intValue];
    if (protocol) {
        self.protocolButton.tag = protocol;
        [self.protocolButton setTitle:@[@"第二套",@"第三套"][protocol - 2] forState:UIControlStateNormal];
    }
    int communication = [[[NSUserDefaults standardUserDefaults]valueForKey:@"communication"]intValue];
    if (communication) {
        self.communicationButton.tag = communication;
        [self.communicationButton setTitle:@[@"WiFi设备",@"蓝牙设备",@"GPRS设备(MQTT）",@"GPRS设备(TCP)"][communication - 1] forState:UIControlStateNormal];
    }
    if (self.device.macAddress.length > 12) {
        self.protocolButton.tag = DTSDKProtocolTypeThird;
        [self.protocolButton setTitle:@"第三套" forState:UIControlStateNormal];
        self.communicationButton.tag = DeviceUsedByGPRS_MQTT;
        [self.communicationButton setTitle:@"GPRS设备(MQTT）" forState:UIControlStateNormal];
    }
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"DeviceCommandTableViewCell_%d%d",(int)indexPath.section,(int)indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.clipsToBounds = YES;
    if (indexPath.row == 0 && indexPath.section == 0) {
        if (self.timerPauseButton == nil) {
            self.timerPauseButton = [cell viewWithTag:2];
            [self.timerPauseButton addTarget:self action:@selector(timerPause:) forControlEvents:UIControlEventTouchUpInside];
            self.timerPauseButton.selected = YES;
        }
        if (self.timerStartButton == nil) {
            self.timerStartButton = [cell viewWithTag:1];
            [self.timerStartButton addTarget:self action:@selector(timerStart:) forControlEvents:UIControlEventTouchUpInside];
            self.timerStartButton.selected = NO;
        }
        
        self.timerTextField = [cell viewWithTag:3];
    }else if (indexPath.row == 1 && indexPath.section == 0) {
        if (self.functionCodeTextField == nil) {
            self.functionCodeTextField = [cell viewWithTag:1];
            self.functionCodeTextField.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"functionCode"];
        }
        self.functionCodeTextField = [cell viewWithTag:1];
        self.functionCodeTextField.inputView = ({
            APNumberPad *numberPad = [APNumberPad numberPadWithDelegate:self];
            numberPad.backgroundColor=[UIColor redColor];
            [numberPad.leftFunctionButton setTitle:@"#" forState:UIControlStateNormal];
            numberPad.leftFunctionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            numberPad;
        });
    }else if (indexPath.row == 2 && indexPath.section == 0){
        if (self.functionCommandTextView == nil) {
            self.functionCommandTextField = [cell viewWithTag:1];
            self.functionCommandTextView = [cell viewWithTag:2];
            self.functionCommandTextView.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"functionCommand"];
            if (self.functionCommandTextView.text.length != 0) {
                self.functionCommandTextField.text = @" ";
            }
        }
        self.functionCommandTextView = [cell viewWithTag:2];
        self.functionCommandTextView.delegate = self;
        self.functionCommandTextView.inputView = ({
            APNumberPad *numberPad = [APNumberPad numberPadWithDelegate:self];
            numberPad.backgroundColor=[UIColor redColor];
            [numberPad.leftFunctionButton setTitle:@"#" forState:UIControlStateNormal];
            numberPad.leftFunctionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            numberPad;
        });
        self.functionCommandTextField = [cell viewWithTag:1];
        self.functionCommandTextField.userInteractionEnabled = NO;
    }else if (indexPath.row == 3 && indexPath.section == 0){
        self.deviceBackTextView = [cell viewWithTag:1];
        self.webView = [cell viewWithTag:2];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 40;
    if (self.commandHeight < 40) {
        self.commandHeight = height;
    }
    if (indexPath.row == 3 && indexPath.section == 0) {
        if (self.commandHeight < height) {
            return self.view.frame.size.height - height*3 - 20;
        }else{
            return self.view.frame.size.height - height*3 - self.commandHeight - 20;
        }
    }
    else if (indexPath.row == 2 && indexPath.section == 0) {
        return self.commandHeight;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

- (void )textField:(UITextField *)textField
{
    textField.inputView = ({
        APNumberPad *numberPad = [APNumberPad numberPadWithDelegate:self];
        numberPad.backgroundColor=[UIColor redColor];
        [numberPad.leftFunctionButton setTitle:@"#" forState:UIControlStateNormal];
        numberPad.leftFunctionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        numberPad;
    });
}

#pragma mark - APNumberPadDelegate
- (void)numberPad:(APNumberPad *)numberPad functionButtonAction:(UIButton *)functionButton textInput:(UIResponder<UITextInput> *)textInput
{

}

- (void)timerStart:(UIButton *)sender
{
    if (self.timerStartButton.selected == NO) {
        if (self.timerTextField.text.floatValue <= 0) {
            [SVProgressHUD showInfoWithStatus:@"定时时间不能小于0"];
            return;
        }
        if (self.functionCodeTextField.text.length != 4) {
            [SVProgressHUD showInfoWithStatus:@"功能码长度为4"];
            return;
        }
        
        [self.sendTimer invalidate];
        self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:self.timerTextField.text.floatValue target:self selector:@selector(sendCommand) userInfo:nil repeats:YES];
        
        [self.sendTimer setFireDate:[NSDate distantPast]];
        self.timerStartButton.selected = YES;
    }else{
        [SVProgressHUD showInfoWithStatus:@"请先点击（定时关）按钮"];
    }
}

- (void)timerPause:(UIButton *)sender
{
    if (self.timerPauseButton.selected == NO) {
        [self.sendTimer setFireDate:[NSDate distantFuture]];
        [self.sendTimer invalidate];
        self.sendTimer = nil;
        
        self.timerStartButton.selected = NO;
        self.timerPauseButton.selected = YES;
        self.functionCodeTextField.enabled = YES;
        self.functionCommandTextField.enabled = YES;
        self.timerTextField.enabled = YES;
        self.functionCommandTextView.userInteractionEnabled = YES;
        self.rightButton.enabled = YES;
    }else{
        [SVProgressHUD showInfoWithStatus:@"定时还没有开启"];
    }
}

- (void)onLeftButtonClick:(id)sender
{
    [self.sendTimer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendCommand
{
    self.timerStartButton.selected = YES;
    self.timerPauseButton.selected = NO;
    
    self.functionCodeTextField.enabled = NO;
    self.functionCommandTextField.enabled = NO;
    self.timerTextField.enabled = NO;
    self.functionCommandTextView.userInteractionEnabled = NO;
    self.rightButton.enabled = NO;
    
    [self onRightButtonClick:nil];
}

- (IBAction)cleanDeviceBackContent:(UIButton *)sender
{
    self.deviceBackTextView.text = @"";
    [self.webView loadHTMLString:self.deviceBackTextView.text baseURL:nil];
}

- (IBAction)moreAction:(UIButton *)sender
{
    if (self.sendTimer) {
        [SVProgressHUD showInfoWithStatus:@"正在进行定时指令发送"];
        return;
    }
    KTActionSheet *sheet=[[KTActionSheet alloc]initWithTitle:@"功能" itemTitles:@[@"固件升级",@"全选复制"]];
    sheet.delegate=self;
    sheet.tag = 100;
    [self.view endEditing:YES];
    [sheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
        if (index == 0) {
            [SVProgressHUD showWithStatus:@"固件检测中"];
            [[DTCloudManager defaultJNI_iOS_SDK]getFirmwareVersionByMacAddress:self.device.macAddress deviceType:DeviceUsedByWiFi protocolType:self.protocolButton.tag resultCallback:^(NSDictionary *dic) {
                if ([dic[@"errcode"]intValue] == 0) {
                    [SVProgressHUD dismiss];
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"发现有新的固件" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [SVProgressHUD showWithStatus:@"升级中,请勿退出应用" maskType:SVProgressHUDMaskTypeBlack];
                        [[DTCloudManager defaultJNI_iOS_SDK]updateFirmwareVersionByMacAddress:self.device.macAddress deviceType:DeviceUsedByWiFi protocolType:self.protocolButton.tag resultCallback:^(NSDictionary *dic) {
                            [SVProgressHUD dismiss];
                            if ([dic[@"errcode"]intValue] == 0) {
                                [SVProgressHUD showInfoWithStatus:@"升级成功"];
                            }else{//检查是否升级成功
                                [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
                            }
                        }];
                    }];
                    [alertController addAction:cancelAction];
                    [alertController addAction:okAction];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                }else{
                    [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
                }
            }];
        }else if (index == 1){
            [self.deviceBackTextView selectAll:self];
        }
    }];
}

- (IBAction)communicationSelect:(UIButton *)sender
{
    KTActionSheet *sheet=[[KTActionSheet alloc]initWithTitle:@"设备种类" itemTitles:@[@"WiFi设备",@"蓝牙设备",@"GPRS(MQTT）",@"GPRS(TCP)"]];
    sheet.delegate=self;
    sheet.tag = 100;
    [self.view endEditing:YES];
    [sheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
        [sender setTitle:@[@"WiFi设备",@"蓝牙设备",@"GPRS设备(MQTT）",@"GPRS设备(TCP)"][index] forState:UIControlStateNormal];
        sender.tag = index + 1;
    }];
}

- (IBAction)protocolSelect:(UIButton *)sender
{
    KTActionSheet *sheet=[[KTActionSheet alloc]initWithTitle:@"协议类型" itemTitles:@[@"第二套",@"第三套"]];
    sheet.delegate=self;
    sheet.tag = 100;
    [self.view endEditing:YES];
    [sheet didFinishSelectIndex:^(NSInteger index, NSString *title) {
        [sender setTitle:@[@"第二套",@"第三套"][index] forState:UIControlStateNormal];
        sender.tag = index + 2;
    }];
}

- (void)onRightButtonClick:(id)sender
{
    if (self.functionCodeTextField.text.length != 4) {
        [SVProgressHUD showInfoWithStatus:@"功能码长度为4"];
        return;
    }
    int status = [[DTCloudManager defaultJNI_iOS_SDK]sendCommandByFunctionCode:self.functionCodeTextField.text functionCommand:self.functionCommandTextView.text deviceMacAddress:self.device.macAddress deviceType:self.communicationButton.tag protocolType:self.protocolButton.tag];
    
    if (status == 0) {
        [[NSUserDefaults standardUserDefaults]setValue:self.timerTextField.text forKey:@"timeValue"];
        [[NSUserDefaults standardUserDefaults]setValue:@(self.protocolButton.tag).stringValue forKey:@"protocol"];
        [[NSUserDefaults standardUserDefaults]setValue:@(self.communicationButton.tag).stringValue forKey:@"communication"];
        [[NSUserDefaults standardUserDefaults]setValue:self.functionCodeTextField.text forKey:@"functionCode"];
        [[NSUserDefaults standardUserDefaults]setValue:self.functionCommandTextView.text forKey:@"functionCommand"];
        
        [SVProgressHUD showInfoWithStatus:@"发送成功"];
        
        self.deviceBackTextView.text = [NSString stringWithFormat:@"%@\n\n发送：code:%@  command:%@",self.deviceBackTextView.text,self.functionCodeTextField.text,self.functionCommandTextView.text];
        [self.webView loadHTMLString:self.deviceBackTextView.text baseURL:nil];
    }else{
        [SVProgressHUD showInfoWithStatus:@"发送失败"];
    }
    
    [self.view endEditing:YES];
}

- (void)notifyMQTTBack:(NSNotification *)notify
{
    NSDictionary *dataDic = notify.object;
    if (![self.device.macAddress.lowercaseString isEqualToString:[dataDic[@"mac"]lowercaseString]] ) {
        return;
    }
    
    self.deviceBackTextView.text = [NSString stringWithFormat:@"%@\n\n返回：code:%@  command:%@",self.deviceBackTextView.text,dataDic[@"backCode"],dataDic[@"backContent"]];
    [self.webView loadHTMLString:self.deviceBackTextView.text baseURL:nil];
}

#pragma mark -

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView isEqual:self.functionCommandTextView]) {
        self.functionCommandTextField.text = (textView.text.length == 0)?@"":@" ";
        self.commandHeight = [self.functionCommandTextView sizeThatFits:CGSizeMake(self.functionCommandTextView.frame.size.width, FLT_MAX)].height + 10;
        self.functionCommandTextField.bounds = CGRectMake(0, 0, CGRectGetWidth(self.functionCommandTextView.frame), self.commandHeight);
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}
@end
