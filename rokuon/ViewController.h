//
//  ViewController.h
//  rokuon
//
//  Created by ビザンコムマック０７ on 2014/10/24.
//  Copyright (c) 2014年 mycompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btn;

- (IBAction)rokuon:(id)sender;

- (IBAction)saisei:(id)sender;
@end

