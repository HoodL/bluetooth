//
//  TableViewCell.m
//  bluetooth
//
//  Created by Lihui on 14-9-18.
//  Copyright (c) 2014年 Lihui. All rights reserved.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       _connectButton=[[UIButton alloc]initWithFrame:CGRectMake(320-44, 0, 44, 44)];
        _connectButton.backgroundColor=[UIColor blueColor];
        [self.contentView addSubview:_connectButton];
        [_connectButton setTitle:@"连接" forState:UIControlStateNormal];

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
