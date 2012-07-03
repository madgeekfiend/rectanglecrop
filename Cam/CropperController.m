    //
//  CropperController.m
//  Cam
//
//  Created by Sam Contapay on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CropperController.h"

@interface CropperController ()
    - (void) loadPhoto;
    - (void) setScrollViewBackground;
    - (IBAction) saveAndClose:(id)sender;
    - (IBAction) cancelAndClose:(id)sender;
    - (BOOL) isRectanglePositionValid:(CGPoint)pos;
    - (IBAction) imageMoved:(id)sender withEvent:(UIEvent *)event;
    - (IBAction) imageTouch:(id)sender withEvent:(UIEvent *)event;
@end

@implementation CropperController
@synthesize cropButton;
@synthesize scrollView;
@synthesize delegate;
@synthesize photo;
@synthesize minZoomScale;
@synthesize maxZoomScale;
@synthesize photoCropperTitle;
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.photo = nil;
        self.delegate = nil;
    }
    return self;
}

- (id) initWithPhoto:(UIImage *)aPhoto
            delegate:(id<CropperControllerDelegate>)aDelegate
{
    if (!(self = [super initWithNibName:@"CropperController" bundle:nil])) {
        return self;
    }
    
    self.photo = aPhoto;
    self.delegate = aDelegate;
    
    self.photoCropperTitle = @"Crop Image";
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //
    // setup view ui
    //
    UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                        target:self
                                                                        action:@selector(saveAndClose:)];
    self.navigationItem.rightBarButtonItem = bi;
    bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                       target:self
                                                       action:@selector(cancelAndClose:)];
    self.navigationItem.leftBarButtonItem = bi;
    self.title = self.photoCropperTitle;
    
    //
    // photo cropper ui stuff
    //
    [self setScrollViewBackground];
    [scrollView setMinimumZoomScale: minZoomScale];
    [scrollView setMaximumZoomScale: maxZoomScale];
    
    [cropButton addTarget:self
                                 action:@selector(imageTouch:withEvent:)
                       forControlEvents:UIControlEventTouchDown];
    [cropButton addTarget:self
                                 action:@selector(imageMoved:withEvent:)
                       forControlEvents:UIControlEventTouchDragInside];
    
    if (self.photo != nil) {
        [self loadPhoto];
    }

}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma UIScrollViewDelegate Methods

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void) setScrollViewBackground
{
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"photo_cropper_bg"]];
}

- (void) loadPhoto
{
    if (self.photo == nil) {
        return;
    }
    
    CGFloat w = self.photo.size.width;
    CGFloat h = self.photo.size.height;
    CGRect imageViewFrame = CGRectMake(0.0f, 0.0f, roundf(w / 2.0f), roundf(h / 2.0f));
    self.scrollView.contentSize = imageViewFrame.size;
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:imageViewFrame];
    iv.image = self.photo;
    [self.scrollView addSubview:iv];
    self.imageView = iv;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setCropButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL) isRectanglePositionValid:(CGPoint)pos
{
    CGRect innerRect = CGRectMake((pos.x + 15), (pos.y + 15), 150, 150);
    return CGRectContainsRect(self.scrollView.frame, innerRect);
}

- (UIImage *) croppedPhoto
{
    CGFloat ox = self.scrollView.contentOffset.x;
    CGFloat oy = self.scrollView.contentOffset.y;
    CGFloat zoomScale = self.scrollView.zoomScale;
    CGFloat cx = (ox + self.cropButton.frame.origin.x + 15.0f) * 2.0f / zoomScale;
    CGFloat cy = (oy + self.cropButton.frame.origin.y + 15.0f) * 2.0f / zoomScale;
    CGFloat cw = 300.0f / zoomScale;
    CGFloat ch = 300.0f / zoomScale;
    CGRect cropRect = CGRectMake(cx, cy, cw, ch);
    
    NSLog(@"---------- cropRect: %@", NSStringFromCGRect(cropRect));
    NSLog(@"--- self.photo.size: %@", NSStringFromCGSize(self.photo.size));
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.photo CGImage], cropRect);
    UIImage *result = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSLog(@"------- result.size: %@", NSStringFromCGSize(result.size));
    
    return result;
}

- (IBAction) saveAndClose:(id)sender
{    
    NSLog(@"----------- zoomScale: %.04f", self.scrollView.zoomScale);
    NSLog(@"------- contentOffset: %@", NSStringFromCGPoint(self.scrollView.contentOffset));
    NSLog(@"-- contentScaleFactor: %.04f", self.scrollView.contentScaleFactor);
    NSLog(@"--------- contentSize: %@", NSStringFromCGSize(self.scrollView.contentSize));
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCropper:didCropPhoto:)]) {
        [self.delegate photoCropper:self didCropPhoto:[self croppedPhoto]];
    }
}

- (IBAction) cancelAndClose:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCropperDidCancel:)]) {
        [self.delegate photoCropperDidCancel:self];
    }
}

- (IBAction) imageMoved:(id)sender withEvent:(UIEvent *)event
{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    
    CGPoint prev = _lastTouchDownPoint;
    _lastTouchDownPoint = point;
    CGFloat diffX = point.x - prev.x;
    CGFloat diffY = point.y - prev.y;
    
    UIControl *button = sender;
    CGRect newFrame = button.frame;
    newFrame.origin.x += diffX;
    newFrame.origin.y += diffY;
    if ([self isRectanglePositionValid:newFrame.origin]) {
        button.frame = newFrame;
    }
}

- (IBAction) imageTouch:(id)sender withEvent:(UIEvent *)event
{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    _lastTouchDownPoint = point;
}

@end
