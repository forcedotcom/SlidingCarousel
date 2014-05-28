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

/**
 Initalizes the transition object with its index in the onboarding carousel
 
 @param index The transitions index in the array of transitions
 */
- (id)initWithIndex:(NSInteger)index;

/**
 Check if an element should be added to this transition.
 
 @param element The onboarding element to add
 @param indices The indices that this element has transitions in
 */
- (void)addElement:(SFOnboardingElement *)element withIndicesIfValid:(NSArray *)indices;

@end

@interface SFOnboardingTransition (Access)

/////////////////////////////////////////
//           Accessors
/////////////////////////////////////////
@property (nonatomic, readonly) NSArray *animateElements;
@property (nonatomic, readonly) NSArray *appearanceElements;
@property (nonatomic, readonly) NSArray *disappearanceElements;
@property (nonatomic, readonly) NSArray *dragDisappearElements;

@end
