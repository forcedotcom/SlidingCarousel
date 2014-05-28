//
//  SFOnboardingTransition.m
//  SlidingCarousel
//
//  Created by Alex Sikora on 5/28/14.
//  Copyright (c) 2014 Alex Sikora. All rights reserved.
//

#import "SFOnboardingTransition.h"
#import "SFOnboardingElement.h"

@interface SFOnboardingTransition ()

@property (nonatomic, strong) NSMutableArray *animateElements;
@property (nonatomic, strong) NSMutableArray *appearanceElements;
@property (nonatomic, strong) NSMutableArray *disappearanceElements;
@property (nonatomic, strong) NSMutableArray *dragDisappearElements;

@property (nonatomic) NSInteger index;

@end

@implementation SFOnboardingTransition

-(id)init {
    if (self = [super init]) {
        self.animateElements = [NSMutableArray array];
        self.appearanceElements = [NSMutableArray array];
        self.disappearanceElements = [NSMutableArray array];
        self.dragDisappearElements = [NSMutableArray array];
    }
    
    return self;
}

- (id)initWithIndex:(NSInteger)index {
    if (self = [self init]) {
        self.index = index;
    }
    
    return self;
}

- (void)addElement:(SFOnboardingElement *)element withIndicesIfValid:(NSArray *)indices {
    NSArray *animateIndexes = indices[0];
    NSArray *appearIndexes = indices[1];
    NSArray *disappearIndexes = indices[2];
    NSArray *dragDisappearIndexes = indices[3];
    
    //This index is when the item should animate in
    for (NSNumber *number in animateIndexes) {
        if ([number integerValue] == self.index) {
            [self.animateElements addObject:element];
        }
    }
    
    //These pages are when the element should animate in on drag
    for (NSNumber *number in appearIndexes) {
        if ([number integerValue] == self.index) {
            [self.appearanceElements addObject:element];
        }
    }
    
    //These pages are when the element should animate away on drag
    for (NSNumber *number in disappearIndexes) {
        if ([number integerValue] == self.index) {
            [self.disappearanceElements addObject:element];
        }
    }
    
    //These pages are when an element should animate away when dragging
    //backwards, used when the element did not appear by drag but should disappear
    for (NSNumber *number in dragDisappearIndexes) {
        if ([number integerValue] == self.index) {
            [self.dragDisappearElements addObject:element];
        }
    }
}

@end
