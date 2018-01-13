//
//  ScanfQRCodeViewController.m
//  flycam
//
//  Created by sunniwell on 14-12-23.
//  Copyright (c) 2014年 bruce. All rights reserved.
//

#import "ScanfQRCodeViewController.h"

@interface ScanfQRCodeViewController ()

@property (strong, nonatomic)AVCaptureDevice *device;
@property (strong, nonatomic)AVCaptureDeviceInput *input;
@property (strong, nonatomic)AVCaptureMetadataOutput *output;
@property (strong, nonatomic)AVCaptureSession *session;
@property (strong, nonatomic)AVCaptureVideoPreviewLayer *preview;

@end

@implementation ScanfQRCodeViewController{
    UIImageView *_line;
    BOOL upOrdown;
    NSInteger scanlineHeight;
    NSTimer *scanTimer;
}

@synthesize device;
@synthesize input;
@synthesize output;
@synthesize session;
@synthesize preview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super setNavigationBarTitle:@"二维码"];
    [super setLeftButtonTitle:@"返回"];
    
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  
    NSError *error = nil;
 
    // Input
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        [self.view setBackgroundColor:[UIColor blackColor]];
        AlertContent(@"未被允许使用摄像头，请在设置里设置允许访问摄像头");
        return;
    }

    // Output
    output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    // Session
    session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([session canAddInput:input]) {
        [session addInput:input];
    }

    if ([session canAddOutput:output]) {
        [session addOutput:output];
    }
    
    // 条码类型
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    // Preview
    preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = self.view.bounds;
    
    [self.view.layer addSublayer:preview];
    
    [self startScan];
    
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60)];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    
    UIImageView *pick_bg = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., self.view.frame.size.width - 40., self.view.frame.size.width - 40.)];
    pick_bg.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height - 60)/2);
    [pick_bg setImage:[UIImage imageNamed:@"pick_bg.png"]];
    [view addSubview:pick_bg];
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, pick_bg.frame.size.width-20, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [pick_bg addSubview:_line];
    
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)CancelRunning {
    // 1. 如果扫描完成，停止会话
    [session stopRunning];
 
    // 2. 删除预览图层
    [preview removeFromSuperlayer];
 
    [output setMetadataObjectsDelegate:nil queue:nil];
}

- (void)startScan {
    // Start

    [session startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {

    // 1. 如果扫描完成，停止会话
    [session stopRunning];

    // 2. 删除预览图层
    [preview removeFromSuperlayer];
    NSString *val = nil;
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        val = obj.stringValue;
    }
    NSLog(@"scan %@", val);
    if (_delegate && [_delegate respondsToSelector:@selector(ScanfQRCode:result:)]) {
 
        [_delegate ScanfQRCode:self result:val];
    }
    [self returnview];
}

-(void) animation1
{
    if (upOrdown == NO) {
        scanlineHeight ++;
        _line.frame = CGRectMake(10, 10+2*scanlineHeight, self.view.frame.size.width - 60., 2);
        if (2*scanlineHeight == self.view.frame.size.width - 60) {
            upOrdown = YES;
        }
    }
    else {
        scanlineHeight --;
        _line.frame = CGRectMake(10, 10+2*scanlineHeight, self.view.frame.size.width - 60., 2);
        if (scanlineHeight == 0) {
            upOrdown = NO;
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self returnview];
}

- (void) pressback:(id)sender
{
    [self CancelRunning];
    [self returnview];
}

- (void) returnview
{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
