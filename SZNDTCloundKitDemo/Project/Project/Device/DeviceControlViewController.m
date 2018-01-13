//
//  Created by JianWei Chen on 16/8/1.
//  Copyright © 2016年 JianWei Chen. All rights reserved.
//

#import "DeviceControlViewController.h"
#import "APNumberPad.h"
#import "APDarkPadStyle.h"
#import "APBluePadStyle.h"

@interface DeviceControlViewController ()<APNumberPadDelegate>

@property (weak, nonatomic) IBOutlet UITextView *commondtext;
@property (weak, nonatomic) IBOutlet UITextView *backcmdcomodtext;

@end

@implementation DeviceControlViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    [self textField];
    
    [self setNavigationBarTitle:@"设备控制"];
    [self setLeftButtonImage:[UIImage imageNamed:@"title_icon_back"]];
    
    self.backcmdcomodtext.editable = NO;
}

- (IBAction)sendcmd:(id)sender
{

}

- (IBAction)clear:(id)sender
{
    self.backcmdcomodtext.text = @"";
}

- (void )textField
{
    self.commondtext.inputView = ({
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
    if ([textInput isEqual:self.commondtext]) {
        [functionButton setTitle:@"#" forState:UIControlStateNormal];
        [textInput insertText:@"#"];
    } else {
        Class currentSyle = [numberPad styleClass];
        
        Class nextStyle = currentSyle == [APDarkPadStyle class] ? [APBluePadStyle class] : [APDarkPadStyle class];
        self.commondtext.inputView = ({
            APNumberPad *numberPad = [APNumberPad numberPadWithDelegate:self numberPadStyleClass:nextStyle];
            [numberPad.leftFunctionButton setTitle:@"Change Style" forState:UIControlStateNormal];
            numberPad.leftFunctionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
            numberPad;
        });
    }
}

@end
