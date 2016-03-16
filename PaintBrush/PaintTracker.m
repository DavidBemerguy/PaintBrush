//
//  DrawTracker.m
//  PaintBrush
//
//  Created by David Bemerguy on 15/03/2016.
//  Copyright © 2016 David Bemerguy. All rights reserved.
//

#import "PaintTracker.h"

@interface PaintTracker()

@property(nonatomic, assign) const CGFloat *colorComponents;

@end

@implementation PaintTracker

@synthesize red, green, blue;

-(id)init{
    if (self = [super init]) {
        _touchPoints = [NSMutableArray new];
        red = 0.0;
        green = 0.0;
        blue = 0.0;
    }
    
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    PaintTracker *tracker = [[PaintTracker allocWithZone:zone] init];
    tracker.isErasing = self.isErasing;
    tracker.touchPoints = [self.touchPoints copy];
    tracker.color = [self.color copy];
    return tracker;
}

-(void)setColor:(UIColor *)color
{
    _color = color;
    
    if(!self.colorComponents){
        self.colorComponents = CGColorGetComponents(_color.CGColor);
    }
}

-(CGFloat)red
{
    return self.colorComponents[0];
}

-(CGFloat)green
{
    return self.colorComponents[1];
}

-(CGFloat)blue
{
    return self.colorComponents[2];
}


@end
