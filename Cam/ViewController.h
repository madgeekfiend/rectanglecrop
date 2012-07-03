//
//  ViewController.h
//  Cam
//
//  Created by Sam Contapay on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CropperController.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, CropperControllerDelegate>

- (IBAction)clickedCamera:(id)sender;
@end
