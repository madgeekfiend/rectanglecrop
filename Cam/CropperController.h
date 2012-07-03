//
//  CropperController.h
//  Cam
//
//  Created by Sam Contapay on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CropperControllerDelegate;


@interface CropperController : UIViewController
{
    id<CropperControllerDelegate> delegate;

    UIImage *photo;
    UIImageView *imageView;

    CGPoint _lastTouchDownPoint;
    
    CGFloat minZoomScale;
    CGFloat maxZoomScale;
    NSString *photoCropperTitle;
    
    UIButton *cropButton;
    UIScrollView *scrollView;
}

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong)UIImage *photo;
@property(nonatomic, assign) CGFloat minZoomScale;
@property(nonatomic, assign) CGFloat maxZoomScale;
@property(nonatomic, strong) NSString *photoCropperTitle;

@property (retain, nonatomic) IBOutlet UIButton *cropButton;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,retain) id<CropperControllerDelegate> delegate;


- (id) initWithPhoto:(UIImage *)aPhoto
            delegate:(id<CropperControllerDelegate>)aDelegate;

@end



@protocol CropperControllerDelegate<NSObject>
@optional
- (void) photoCropper:(CropperController *)photoCropper
         didCropPhoto:(UIImage *)photo;
- (void) photoCropperDidCancel:(CropperController *)photoCropper;
@end