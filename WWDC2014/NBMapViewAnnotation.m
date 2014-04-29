//
//  NBMapViewAnnotation.m
//  WWDC2014
//
//  Created by Neeraj Baid on 4/8/14.
//  Copyright (c) 2014 Neeraj Baid. All rights reserved.
//

#import "NBMapViewAnnotation.h"

@implementation NBMapViewAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subtitle:(NSString *)subtitle
{
    if ((self = [super init]))
    {
        self.coordinate = coordinate;
        self.title = title;
    }
    return self;
}

@end
