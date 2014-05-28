//
//  SFOnboardingTransition.h
//  SlidingCarousel
//
//  Created by Alex Sikora on 5/28/14.
//  Copyright (c) 2014 Alex Sikora. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFOnboardingElement;

@interface SFOnboardingTransition : NSObject

- (id)initWithIndex:(NSInteger)index;
- (void)addElement:(SFOnboardingElement *)element withIndicesIfValid:(NSArray *)indices;

@end

@interface SFOnboardingTransition (Access)

@property (nonatomic, readonly) NSArray *animateElements;
@property (nonatomic, readonly) NSArray *appearanceElements;
@property (nonatomic, readonly) NSArray *disappearanceElements;
@property (nonatomic, readonly) NSArray *dragDisappearElements;

@end
