//
//  CircleViewFinder.m
//  Cam
//
//  Created by Sam Contapay on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CircleViewFinder.h"

@implementation CircleViewFinder

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    /*
     [[UIColor blackColor] setFill];
     UIRectFill(rect);
     
     
     //NSLog(@"SIZE: %f x %f", rect.size.width, rect.size.height);
     CGRect square = CGRectMake(rect.origin.x+1, rect.origin.y+80, rect.size.width-2, 301);
     CGRect squareIntersection = CGRectIntersection(square, rect);
     [[UIColor clearColor] setFill];
     UIRectFill( squareIntersection );
     
     // This is the square view
     
     [[UIColor whiteColor] setFill];
     // Create white border around the thing this is dumb as I have to draw 4 rectangles so stupid
     CGRect top = CGRectMake(square.origin.x, square.origin.y, square.size.width, 2);
     UIRectFill(top);
     CGRect bottom = CGRectMake(square.origin.x, square.origin.y + square.size.height, square.size.width, 2);
     UIRectFill(bottom);
     CGRect left = CGRectMake(square.origin.x, square.origin.y, 2, square.size.height);
     UIRectFill(left);
     CGRect right = CGRectMake(square.origin.x + square.size.width, square.origin.y, 2, square.size.height);
     UIRectFill(right);
     */
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, rect);
    
    
    // Full size portrait image is 2448x3264 from the iphone
    
    CGRect square = CGRectMake(rect.origin.x+10, rect.origin.y+90, 300, 300);
    
    
    // Intersect for circle becuase it does intercept
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetBlendMode(context, kCGBlendModeClear);
    //CGContextFillEllipseInRect(context, square);
    CGContextFillRect(context, square);
    
    [self setAlpha:0.6];
}


@end
