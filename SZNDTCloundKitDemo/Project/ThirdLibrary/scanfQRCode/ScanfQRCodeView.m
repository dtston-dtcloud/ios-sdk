//
//  ScanfQRCodeView.m
//  FamilyShow
//
//  Created by guoziyi on 15-1-19.
//  Copyright (c) 2015年 net.sunniwell.sz. All rights reserved.
//

#import "ScanfQRCodeView.h"
#import "BaseViewController.h"

@interface ScanfQRCodeView ()

@property (strong, nonatomic)AVCaptureDevice *device;
@property (strong, nonatomic)AVCaptureDeviceInput *input;
@property (strong, nonatomic)AVCaptureMetadataOutput *output;
@property (strong, nonatomic)AVCaptureSession *session;
@property (strong, nonatomic)AVCaptureVideoPreviewLayer *preview;

@end

@implementation ScanfQRCodeView

@synthesize device;
@synthesize input;
@synthesize output;
@synthesize session;
@synthesize preview;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error = nil;
        
        // Input
        input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (error) {
            [self setBackgroundColor:[UIColor clearColor]];
            AlertContent(@"未被允许使用摄像头，请在设置里设置允许访问摄像头");
            return nil;
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
        preview.frame = self.bounds;
        
        [self.layer addSublayer:preview];
    }
    return self;
}
-(void)stopRunning
{
    [session stopRunning];
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
    //[preview removeFromSuperlayer];
    NSString *val = nil;
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        val = obj.stringValue;
    }
    NSLog(@"扫描结果: %@", val);
    if (_delegate && [_delegate respondsToSelector:@selector(scanfQRCode:result:)]) {
        [_delegate scanfQRCode:self result:val];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
