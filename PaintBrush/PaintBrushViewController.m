//
//  PaintBrushViewController.m
//  PaintBrush
//
//  Created by David Bemerguy on 15/03/2016.
//  Copyright © 2016 David Bemerguy. All rights reserved.
//

#import "PaintBrushViewController.h"
#import "PaintTracker.h"

CGFloat DefaultBrush = 10.0;
CGFloat DefaultOpacity = 1.0;

@interface PaintBrushViewController ()

@property(nonatomic, weak) IBOutlet UIImageView *imageView;
@property(nonatomic, weak) IBOutlet UISlider *slider;

@property(nonatomic, strong) NSMutableArray<PaintTracker *> *touches;

@property(nonatomic, assign) CGPoint lastTouchPoint;

@property(nonatomic, strong) UIColor *currentColor;
@property(nonatomic, assign) CGFloat opacity;
@property(nonatomic, assign) CGFloat brush;
@property(nonatomic, assign) BOOL isErasing;

-(IBAction)erase:(id)sender;
-(IBAction)slide:(id)sender;

@end

@implementation PaintBrushViewController

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        self.touches = [NSMutableArray new];
        self.currentColor = [UIColor blackColor];
        self.brush = DefaultBrush;
        self.opacity = DefaultOpacity;
        self.isErasing = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    self.lastTouchPoint = [[touches anyObject] locationInView:self.imageView];
    
    PaintTracker *track = [PaintTracker new];
    track.color = self.currentColor;
    [track.touchPoints addObject:[NSValue valueWithCGPoint:self.lastTouchPoint]];
    track.isErasing = self.isErasing;
    track.brush = self.brush;
    [self.touches addObject:track];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.imageView];
    
    NSValue *value = [NSValue valueWithCGPoint:currentPoint];
    
    PaintTracker *track = self.touches.lastObject;
    [track.touchPoints addObject:value];
    
    [self drawInPoint:currentPoint];
}

-(void)drawInPoint:(CGPoint)currentPoint
{
    UIGraphicsBeginImageContext(self.imageView.frame.size);
    
    // Draw
    [self.imageView.image drawInRect:CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastTouchPoint.x, self.lastTouchPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brush);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0);

    CGBlendMode mode = kCGBlendModeNormal;
    if(self.isErasing){
        mode = kCGBlendModeClear;
    }
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),mode);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.imageView setAlpha:self.opacity];
    UIGraphicsEndImageContext();
    
    CGContextRelease(UIGraphicsGetCurrentContext());
    
    self.lastTouchPoint = currentPoint;
}

-(void)redrawAllPoints
{
    self.imageView.image = nil;
    
    for(PaintTracker *track in self.touches){
        
        self.lastTouchPoint = [track.touchPoints[0] CGPointValue];
        
        self.currentColor = track.color;
        self.isErasing = track.isErasing;
        if(self.isErasing){
            self.brush = track.brush;
        }else{
            self.brush = self.slider.value;
        }
        
        for(NSValue *value in track.touchPoints){
            [self drawInPoint:value.CGPointValue];
        }
        
        
    }
}

-(IBAction)slide:(id)sender
{
    UISlider *slider = sender;
    
    if(fabs(slider.value - self.brush) > (slider.maximumValue - slider.minimumValue) / 10){
        self.brush = slider.value;
        [self redrawAllPoints];
    }

}

-(IBAction)erase:(id)sender
{
    self.isErasing = YES;
}

@end


