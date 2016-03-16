//
//  PaintTracker.m
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
    CGFloat alpha;
    BOOL canConvert = [_color getRed:&red green:&green blue:&blue alpha:&alpha];
}



@end
