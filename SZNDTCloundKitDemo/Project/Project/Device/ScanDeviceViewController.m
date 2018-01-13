//
//  ScanDeviceViewController.m
//  DTSTON
//
//  Created by 陈剑伟 on 16/5/5.
//  Copyright © 2016年 Demo. All rights reserved.
//
#import "ScanfQRCodeView.h"
#import "ScanDeviceViewController.h"
#import "SVProgressHUD.h"
#import <DTCloudKit/DTCloudKit.h>

@interface ScanDeviceViewController()<ScanfQRCodeViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *scanImageView;

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIImageView *line;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
@implementation ScanDeviceViewController
{
    
    ScanfQRCodeView *scanfView_;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setLeftButtonImage:[UIImage imageNamed:@"title_icon_back"]];
    [self setNavigationBarTitle:@"扫一扫"];

    self.view.backgroundColor=[UIColor blackColor];
    scanfView_ = [[ScanfQRCodeView alloc]initWithFrame:self.view.bounds];
    scanfView_.delegate = self;
    
    [self.view addSubview:scanfView_];
    [self.view sendSubviewToBack:scanfView_];
    
    [SVProgressHUD showWithStatus:@"加载中"];
    [SVProgressHUD dismissWithDelay:1.0];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [scanfView_ CancelRunning];
    [self.scanImageView.layer removeAllAnimations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [scanfView_ startScan];
    
    [self bgView];
    [self line];
    //启动动画
    
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionRepeat animations:^{
        _line.center = CGPointMake(_line.center.x, self.scanImageView.frame.size.height);
    } completion:nil];
}

- (UIImageView *)line
{
    if (!_line) {
        _line = [[UIImageView alloc]initWithFrame:CGRectMake(30, 0, self.scanImageView.frame.size.width - 60, 5)];
        [_line setImage:[UIImage imageNamed:@"scan_line"]];
        [self.scanImageView addSubview:_line];
    }
    return _line;
}

- (UIView *)bgView
{
    if (!_bgView) {
        CGRect frame = [UIScreen mainScreen].bounds;
        UIView * bgView = [[UIView alloc]initWithFrame:frame];
        _bgView = bgView;
        bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65];
        [self.view addSubview:bgView];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
        [path appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.scanImageView.frame.origin.x, self.scanImageView.frame.origin.y, self.scanImageView.frame.size.width, self.scanImageView.frame.size.height) cornerRadius:0] bezierPathByReversingPath]];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        [bgView.layer setMask:shapeLayer];
        [self.view bringSubviewToFront:self.label];
    }
    return _bgView;
}

- (void) scanfQRCode:(ScanfQRCodeView *)scanfview result:(NSString *)result
{    
    [self.scanImageView.layer removeAllAnimations];
    
    NSArray *resultList = [result componentsSeparatedByString:@" "];
    if (resultList.count == 3) {//mac地址长度
        if ([[resultList firstObject] isEqualToString:@"SZN"]) {
            
            NSString *macString = [resultList lastObject];
            NSString *productId = [resultList objectAtIndex:1];
            DTDevice *device = [[DTDevice alloc]init];
            device.macAddress = macString;
            device.deviceName = @"设备";
            device.deviceTypeID = productId;
            
            [[DTCloudManager defaultJNI_iOS_SDK]bindDeviceByName:device.deviceName macAddress:device.macAddress productId:device.deviceTypeID deviceType:DeviceUsedByWiFi successCallback:^(NSDictionary *dic) {
                [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
                [scanfView_ startScan];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } errorCallback:^(NSDictionary *dic) {
                [scanfView_ startScan];
                [SVProgressHUD showInfoWithStatus:dic[@"errmsg"]];
            }];
        }
    }
}

@end
