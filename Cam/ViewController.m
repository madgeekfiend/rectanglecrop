//
//  ViewController.m
//  Cam
//
//  Created by Sam Contapay on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "CircleViewFinder.h"

const float PIXEL_X_RATIO = 7.65f;
const float PIXEL_Y_RATIO = 6.8f;

static inline double radians (double degrees) {return degrees * M_PI/180;}

@interface ViewController ()
    -(UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
    -(UIImage *)fixOrientation : (UIImage *)img;
    -(UIImage*)cropImage:(UIImage*)originalImage toRect:(CGRect)rect;
    -(UIImage*)cropImageToPoint:(UIImage*)oldImage;
- (CGRect) TransformCGRectForUIImageOrientation: (CGRect) source: (UIImageOrientation) orientation: (CGSize) imageSize;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)clickedCamera:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = (id)self;
    picker.allowsEditing = NO;
    //picker.wantsFullScreenLayout = YES;
    
    //UIView *vi = [[UIView alloc] initWithFrame:CGRectMake(100, 20, 200, 130)];
    //CircleViewFinder *vi = [[CircleViewFinder alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    //vi.backgroundColor = [UIColor clearColor];
    
    //picker.cameraOverlayView = vi;
    
    [self presentModalViewController:picker animated:YES];
}

#pragma UIPickerController delegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"HERE"); 
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    
    /*
    NSLog(@"%f X %f", img.size.width, img.size.height);
    //CGRect square = CGRectMake( 10 * ((img.size.width * img.scale)/320.0f) * img.scale, 90 * img.scale * ((img.size.height * img.scale)/480.0f), 300 * img.scale * ((img.size.width * img.scale)/320.0f), 300 * img.scale * ((img.size.height * img.scale)/480.0f));
    //UIImage *cropped = [self imageByCropping:img toRect:square];
    //CGRect square = CGRectMake( roundf( 61 * PIXEL_Y_RATIO ), roundf( 33 * PIXEL_X_RATIO ), roundf(300 * PIXEL_Y_RATIO) * 2.0, roundf( 300 * PIXEL_X_RATIO ) * 2.0);
    
    int x = roundf(img.size.width/2 - (.9 * img.size.width)/2);
    int y = roundf(img.size.height/2 - (.9 * img.size.width)/2);
    int radius = roundf(img.size.width * .9);
    CGRect square = CGRectMake( y + 180, x, radius, radius);
    
    
    //CGAffineTransform scaleTrans =  CGAffineTransformMakeScale(PIXEL_X_RATIO, PIXEL_Y_RATIO);
    
    //CGAffineTransform newSquare = CGAffineTransformScale(transformers, PIXEL_X_RATIO, PIXEL_Y_RATIO);
    
    //CGAffineTransform newSquare = CGAffineTransformMakeTranslation(img.size.width * img.scale, img.size.height * img.scale);
    //CGRect thisrect = CGRectApplyAffineTransform(square, newSquare);
    
    UIImageWriteToSavedPhotosAlbum([self cropImage:img toRect:square], nil, nil, nil);
*/
    [picker dismissModalViewControllerAnimated:NO];
    
    // now we have an image
    CropperController *cc = [[CropperController alloc] initWithPhoto:img delegate:self];
    [cc setMinZoomScale:0.75f];
    [cc setMaxZoomScale:1.50f];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:cc];
    [self presentModalViewController:nav animated:YES];
    


}

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect {
    CGImageRef cropped = CGImageCreateWithImageInRect(imageToCrop.CGImage, rect);
    UIImage *retImage = [UIImage imageWithCGImage: cropped];
    CGImageRelease(cropped);
    
    [self fixOrientation:retImage];
    return retImage;
}

- (CGRect) TransformCGRectForUIImageOrientation: (CGRect) source: (UIImageOrientation) orientation: (CGSize) imageSize {
    
    switch (orientation) {
        case UIImageOrientationLeft: { // EXIF #8
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(
                                                                             imageSize.height, 0.0);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,
                                                                   M_PI_2);
            return CGRectApplyAffineTransform(source, txCompound);
        }
        case UIImageOrientationDown: { // EXIF #3
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(
                                                                             imageSize.width, imageSize.height);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,
                                                                   M_PI);
            return CGRectApplyAffineTransform(source, txCompound);
        }
        case UIImageOrientationRight: { // EXIF #6
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(
                                                                             0.0, imageSize.width);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,
                                                                   M_PI + M_PI_2);
            return CGRectApplyAffineTransform(source, txCompound);
        }
        case UIImageOrientationUp: // EXIF #1 - do nothing
        default: // EXIF 2,4,5,7 - ignore
            return source;
    }
}

// For some reason we have to use this to fix orientation on saved images because this is DUMB as usual - Screw iOS shit should be easier
- (UIImage *)fixOrientation : (UIImage *)img
{
    if (img.imageOrientation == UIImageOrientationUp) return img;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (img.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, img.size.width, img.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, img.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, img.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
    }
    
    switch (img.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, img.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, img.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, img.size.width, img.size.height,
                                             CGImageGetBitsPerComponent(img.CGImage), 0,
                                             CGImageGetColorSpace(img.CGImage),
                                             CGImageGetBitmapInfo(img.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (img.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,img.size.height,img.size.width), img.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,img.size.width,img.size.height), img.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img1 = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img1;
    
}

-(UIImage*)cropImage:(UIImage*)originalImage toRect:(CGRect)rect
{
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], rect);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    CGContextRef bitmap = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
    
    if (originalImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -rect.size.height);
        
    } else if (originalImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -rect.size.width, 0);
        
    } else if (originalImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (originalImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, rect.size.width, rect.size.height);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, rect.size.width, rect.size.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    
    UIImage *resultImage=[UIImage imageWithCGImage:ref];
    CGImageRelease(imageRef);
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return resultImage;
}

-(UIImage*)cropImageToPoint:(UIImage*)oldImage
{
    UIGraphicsBeginImageContextWithOptions( CGSizeMake( 300 * PIXEL_X_RATIO,
                                                       300 * PIXEL_Y_RATIO),
                                           NO,
                                           0.);
    [oldImage drawAtPoint:CGPointMake( 0, -100)
                blendMode:kCGBlendModeCopy
                    alpha:1.];
    
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return croppedImage;
}

#pragma mark - Cropper Controller
-(void)photoCropper:(CropperController *)photoCropper didCropPhoto:(UIImage *)photo
{
    UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil);
}

-(void)photoCropperDidCancel:(CropperController *)photoCropper
{
    [photoCropper dismissModalViewControllerAnimated:YES];
}

@end
