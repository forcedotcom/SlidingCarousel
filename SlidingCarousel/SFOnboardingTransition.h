//
//  SFOnboardingTransition.h
//  SlidingCarousel
//
//  Created by Alex Sikora on 5/28/14.

/*
 Copyright (c) 2014, Salesforce.com, Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of Salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
