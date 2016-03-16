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

@interface PaintBrushViewController ()

@property(nonatomic, weak) IBOutlet UIImageView *imageView;
@property(nonatomic, weak) IBOutlet UISlider *slider;

@property(nonatomic, strong) NSMutableArray<PaintTracker *> *touches;

@property(nonatomic, assign) CGPoint lastTouchPoint;

@property(nonatomic, strong) UIColor *currentColor;
@property(nonatomic, assign) CGFloat currentBrush;
@property(nonatomic, assign) BOOL isErasing;

-(IBAction)erase:(id)sender;
-(IBAction)slide:(id)sender;
-(IBAction)undo:(id)sender;
-(IBAction)blue:(id)sender;
-(IBAction)orange:(id)sender;
-(IBAction)green:(id)sender;
-(IBAction)red:(id)sender;
-(IBAction)yellow:(id)sender;

@end

@implementation PaintBrushViewController

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        self.touches = [NSMutableArray new];
        self.currentColor = [UIColor blueColor];
        self.currentBrush = DefaultBrush;
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
    track.brush = self.currentBrush;
    [self.touches addObject:track];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.imageView];
    
    NSValue *value = [NSValue valueWithCGPoint:currentPoint];
    
    PaintTracker *track = self.touches.lastObject;
    [track.touchPoints addObject:value];
    
    [self drawInPoint:currentPoint withTracker:track];
}

-(void)drawInPoint:(CGPoint)currentPoint withTracker:(PaintTracker *)tracker
{
    UIGraphicsBeginImageContext(self.imageView.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw
    [self.imageView.image drawInRect:CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height)];
    CGContextMoveToPoint(ctx, self.lastTouchPoint.x, self.lastTouchPoint.y);
    CGContextAddLineToPoint(ctx, currentPoint.x, currentPoint.y);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, tracker.brush);
    CGContextSetRGBStrokeColor(ctx, tracker.red, tracker.green, tracker.blue, 1.0);

    CGBlendMode mode = kCGBlendModeNormal;
    if(self.isErasing){
        mode = kCGBlendModeClear;
    }
    
    CGContextSetBlendMode(ctx,mode);
    CGContextStrokePath(ctx);
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
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
            self.currentBrush = track.brush;
        }else{
            self.currentBrush = self.slider.value;
        }
        
        for(NSValue *value in track.touchPoints){
            [self drawInPoint:value.CGPointValue withTracker:track];
        }
        
        
    }
}

-(IBAction)slide:(UISlider *)slider
{    
    if(fabs(slider.value - self.currentBrush) > (slider.maximumValue - slider.minimumValue) / 10){
        self.currentBrush = slider.value;
    }

}

-(IBAction)erase:(id)sender
{
    self.isErasing = YES;
}

-(IBAction)undo:(id)sender{
    if(self.touches.count){
        PaintTracker *lastTracker = self.touches.lastObject;
        if(lastTracker.touchPoints.lastObject){
            [lastTracker.touchPoints removeLastObject];
            [self redrawAllPoints];
        }
    }
}

-(IBAction)blue:(id)sender{
    self.currentColor = [UIColor blueColor];
}
-(IBAction)orange:(id)sender{
    self.currentColor = [UIColor orangeColor];
}
-(IBAction)green:(id)sender{
    self.currentColor = [UIColor greenColor];
}
-(IBAction)red:(id)sender{
    self.currentColor = [UIColor redColor];
}
-(IBAction)yellow:(id)sender{
    self.currentColor = [UIColor yellowColor];
}

@end


