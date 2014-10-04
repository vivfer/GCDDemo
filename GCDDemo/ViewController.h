//
//  ViewController.h
//  GCDDemo
//
//  Created by jianleer on 14-10-4.
//  Copyright (c) 2014年 jianleer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) IBOutlet UITextView *GCDTextView;

- (IBAction)click:(id)sender;
- (IBAction)CGDClick:(id)sender;

@end

