//
//  KTSheetCell.m
//  
//
//  Created by hcl on 15/10/13.
//
//

#import "KTSheetCell.h"

@interface KTSheetCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *divLineHeight;

@end

@implementation KTSheetCell

- (void)awakeFromNib {
    _divLineHeight.constant = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
