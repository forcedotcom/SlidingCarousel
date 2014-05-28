//
//  SFOnboardingConductor.h
//  SlidingCarousel
//
//  Created by Alex Sikora on 5/8/14.

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

#import "SFOnboardingElement.h"

@protocol SFOnboardingConductorDelegate <NSObject>

@required
/** If the skip button was pressed or the completion button
 
 @param page The page the onboarding view closed on
 @param conductor The instance of the conductor that closed
 */
- (void)didCloseOnPage:(NSInteger)page conductor:(SFOnboardingConductor *)conductor;

@optional
/** Add any custom subivews/animations using the helper methods if desired by the delegate
 
 @param conductor The conductor that is being initalized, can call helper methods on it
 */
- (void)configureCustomViewsAndAnimations:(SFOnboardingConductor *)conductor;

@end

@interface SFOnboardingConductor : NSObject <UIScrollViewDelegate>

@property (nonatomic, readonly) UIScrollView *mainScrollView;
@property (nonatomic, weak) NSObject<SFOnboardingConductorDelegate> *delegate;


/////////////////////////////////////////
//           Initializers
/////////////////////////////////////////

- (id)initWithContainer:(UIView *)containerView jsonSpec:(NSData *)jsonData delegate:(NSObject<SFOnboardingConductorDelegate> *)delegate;


/////////////////////////////////////////
//           View Management
/////////////////////////////////////////

/** Retrieve an imageview created by the JSON file
 
 @param key The key the imageview was stored under
 @return The UIView stored for the key
 */
- (UIView *)viewForKey:(NSString *)key;

/** Retrieve the properties for a particular view
 
 @param key The key for the view
 @return A dictionary with parameters for the view like anchorPoint, relativePosition, relativeParent
 */
- (NSDictionary *)infoForKey:(NSString *)key;

/////////////////////////////////////////
//     Custom Subivews/Animation
//  Used for display or transitions
/////////////////////////////////////////


/** Set a custom subview to use an OnboardingElement's view
 
 @param customView the view to use
 @Param key The key that view should be stored with
 */
- (void)setCustomSubview:(UIView *)customView forKey:(NSString *)key;

/** Set a custom animation to use as an OnboardingElement's animation block
 for appearance or disappearance
 
 @param animation The animation block to use for an Element
 @param key The key to store this animation with
 */
- (void)setCustomAnimation:(AnimationBlock)animation forKey:(NSString *)key;

/** Return a custom subview for a particular key
 
 @param key The key to retrieve the subview
 @return The UIView stored for that key
 */
- (UIView *)customSubviewForKey:(NSString *)key;

/** Return a custom animation stored in a particular key
 
 @param key The key the animation is stored under
 @return An animation block stored for a particular key
 */
- (AnimationBlock)customAnimationForKey:(NSString *)key;

// Set a particular element for a section of appear/disappear indices
/** Configure an onboarding element to appear and disappear as appropriate
 depending on the indices defined in the JSON element it was created with. 
 
 @param element The element that is being positioned
 @param indices An array of index arrays that list the page that the element
 should perform its varied transitions
 */
- (void)setElement:(SFOnboardingElement *)element forIndices:(NSArray *)indices;

/////////////////////////////////////////
//               Actions
/////////////////////////////////////////

// Useful actions on the onboarding view
/** Calls the close action on the delegate with the current page number
 */
- (void)closeAction;

/** Moves the onboarding screen to a particular page
 */
- (BOOL)goToPage:(NSInteger)page;

@end
