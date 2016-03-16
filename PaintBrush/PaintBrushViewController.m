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

/**
 *  Wether or not the eraser is selected
 */
@property(nonatomic, assign) BOOL isErasing;

-(IBAction)erase:(id)sender;
-(IBAction)slide:(id)sender;
-(IBAction)undo;
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
    
    // Keeps the last touch point to be used while drawing tracks
    self.lastTouchPoint = [[touches anyObject] locationInView:self.imageView];
    
    // All touch began creates a new tracker
    // This tracker will keep all touches until touches ended
    // All touches inside the tracker should contain the same behaviour (like color, brush and etc.)
    PaintTracker *track = [PaintTracker new];
    track.color = self.currentColor;
    [track.touchPoints addObject:[NSValue valueWithCGPoint:self.lastTouchPoint]];
    track.isErasing = self.isErasing;
    track.brush = self.currentBrush;
    [self.touches addObject:track];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint currentPoint = [[touches anyObject] locationInView:self.imageView];

    // Gets the current track when touches began and add the new touch point
    PaintTracker *track = self.touches.lastObject;
    [track.touchPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
    
    [self drawInPoint:currentPoint withTracker:track];
}

-(void)drawInPoint:(CGPoint)currentPoint withTracker:(PaintTracker *)tracker
{
    UIGraphicsBeginImageContext(self.imageView.frame.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // As we create a new context, the image created before is not shown, so we draw the last image in the new context and continue drawing the new points
    [self.imageView.image drawInRect:CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height)];
    
    CGContextMoveToPoint(ctx, self.lastTouchPoint.x, self.lastTouchPoint.y);
    CGContextAddLineToPoint(ctx, currentPoint.x, currentPoint.y);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, tracker.brush);
    CGContextSetRGBStrokeColor(ctx, tracker.red, tracker.green, tracker.blue, 1.0);

    // Set eraser
    CGContextSetBlendMode(ctx, self.isErasing ? kCGBlendModeClear : kCGBlendModeNormal);
    CGContextStrokePath(ctx);
    self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Keeps the current point so we can start drawing from it when touches moved
    self.lastTouchPoint = currentPoint;
}

-(void)redrawAllPoints
{
    self.imageView.image = nil;
    
    for(PaintTracker *track in self.touches){
        
        // The first point on the tracker is always the start point we need to draw
        self.lastTouchPoint = [track.touchPoints[0] CGPointValue];
        
        self.currentColor = track.color;
        self.isErasing = track.isErasing;
        self.currentBrush = track.brush;
        
        // Go tru all touched points of the tracker
        for(NSValue *value in track.touchPoints){
            [self drawInPoint:value.CGPointValue withTracker:track];
        }
        
        
    }
}

-(IBAction)slide:(UISlider *)slider
{
    self.currentBrush = slider.value;
}

-(IBAction)erase:(id)sender
{
    self.isErasing = YES;
}

-(IBAction)undo{
    if(!self.touches.count)
        return;
    
    PaintTracker *lastTracker = self.touches.lastObject;
    if(lastTracker.touchPoints.lastObject){
        [lastTracker.touchPoints removeLastObject];
        
        if(!lastTracker.touchPoints.count){
            [self.touches removeObject:lastTracker];
        }
        
        [self redrawAllPoints];
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


