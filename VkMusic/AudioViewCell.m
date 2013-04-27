//
//  AudioViewCell.m
//  VkMusic
//
//  Created by keepcoder on 23.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "AudioViewCell.h"
#import "SIMenuConfiguration.h"
#import "SICellSelection.h"
#import "QuartzCore/QuartzCore.h"
#import "Consts.h"
#import "UIImage+Extension.h"
@implementation AudioViewCell
@synthesize accessoryTarget;
@synthesize accessorySelector;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bg = [[UIView alloc] initWithFrame:CGRectZero];
        bg.backgroundColor =  [UIColor whiteColor]; //[UIColor colorWithRed:0.137 green:0.137 blue:0.137 alpha:1];
        self.backgroundView = bg;
        self.backgroundColor = [UIColor colorWithRed:0.137 green:0.137 blue:0.137 alpha:1];
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[SIMenuConfiguration selectionColor]]];
        self.textLabel.font = [UIFont fontWithName:FONT_BOLD size:18];
        self.textLabel.textColor = [UIColor colorWithRed:0.266 green:0.266 blue:0.266 alpha:1];
        self.detailTextLabel.font = [UIFont fontWithName:FONT_BOLD size:13];
        self.detailTextLabel.textColor = [UIColor colorWithRed:0.552 green:0.552 blue:0.552 alpha:1];
    }
    return self;
}

-(void)addAccessoryTarget:(id)target selector:(SEL)selector {
    self.accessoryTarget = target;
    self.accessorySelector = selector;
}

-(void)setState:(AudioState)state {
    NSString *icon;
    switch (state) {
        case AUDIO_DEFAULT:
            icon = @"download";
            break;
        case AUDIO_IN_SAVE_QUEUE:
            icon = @"queued";
            break;
        case AUDIO_SAVED:
            icon = @"success_gray";
            break;
        case AUDIO_IN_PROGRESS_SAVE:
            icon = @"queued";
            break;
        default:
            icon = nil;
            break;
    }
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:icon];
    btn.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:accessoryTarget action:accessorySelector forControlEvents:UIControlEventTouchUpInside];
    self.accessoryView = btn;
}




@end