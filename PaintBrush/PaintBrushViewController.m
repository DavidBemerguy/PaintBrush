//
//  PaintBrushViewController.m
//  PaintBrush
//
//  Created by David Bemerguy on 15/03/2016.
//  Copyright © 2016 David Bemerguy. All rights reserved.
//

#import "PaintBrushViewController.h"
#import "PaintTracker.h"

@interface PaintBrushViewController ()

@property(nonatomic, weak) IBOutlet UIImageView *imageView;
@property(nonatomic, weak) IBOutlet UISlider *slider;

@property(nonatomic, strong) NSMutableDictionary *touches;

@property(nonatomic, assign) CGPoint lastTouchPoint;
@property(nonatomic, assign) NSUInteger touchOrder;

@property(nonatomic, strong) NSDictionary *touchBeganDic;

@property(nonatomic, assign) CGFloat opacity;
@property(nonatomic, assign) CGFloat brush;
@property(nonatomic, assign) CGFloat red;
@property(nonatomic, assign) CGFloat green;
@property(nonatomic, assign) CGFloat blue;
@property(nonatomic, assign) BOOL isErasing;

-(IBAction)erase:(id)sender;
-(IBAction)slide:(id)sender;

@end

@implementation PaintBrushViewController

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        self.touches = [NSMutableDictionary new];
        self.touchOrder = 0;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.red = 0;
    self.green = 0;
    self.blue = 0;
    self.brush = 10.0;
    self.opacity = 1.0;
    self.isErasing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    self.lastTouchPoint = [[touches anyObject] locationInView:self.imageView];
    
    NSDictionary *dic = @{
                          @"lastTouchPoint" : [NSValue valueWithCGPoint:self.lastTouchPoint],
                          @"order"     : @(self.touchOrder++),
                          };
    
    [self.touches setObject:[NSMutableArray new] forKey:dic];
    
    self.touchBeganDic = dic;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.imageView];
    
    NSValue *value = [NSValue valueWithCGPoint:currentPoint];
    
    PaintTracker *track = [PaintTracker new];
    track.red = self.red;
    track.blue = self.blue;
    track.green = self.green;
    track.currentPoint = value;
    track.isErasing = self.isErasing;
    track.brush = self.brush;
    
    NSMutableArray *tracks = self.touches[self.touchBeganDic];
    if(![tracks containsObject:track]){
        [tracks addObject:track];
    }
    
    [self drawInPoint:currentPoint];
}

-(void)drawInPoint:(CGPoint)currentPoint
{
    UIGraphicsBeginImageContext(self.imageView.frame.size);
    [self.imageView.image drawInRect:CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), self.lastTouchPoint.x, self.lastTouchPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), self.brush);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, 1.0);

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
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *sortedArray = [self.touches.allKeys sortedArrayUsingDescriptors:@[descriptor]];
    
    for(NSDictionary *dic in sortedArray){
        
        self.lastTouchPoint = [dic[@"lastTouchPoint"] CGPointValue];
        
        NSArray *array = self.touches[dic];
        for(PaintTracker *track in array){
            self.red = track.red;
            self.green = track.green;
            self.blue = track.blue;
            self.isErasing = track.isErasing;
            if(self.isErasing){
                self.brush = track.brush;
            }else{
                self.brush = self.slider.value;
            }
            
            [self drawInPoint:track.currentPoint.CGPointValue];
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

