//
//  OnboardingElement.h
//  Chatter
//
//  Created by Alex Sikora on 2/27/14.

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

@class SFOnboardingConductor;

typedef void (^CompletionBlock)(BOOL finished);
typedef void (^AnimationBlock)(UIView *view, CGFloat percentage, CompletionBlock completion);

@interface SFOnboardingElement : NSObject

@property (nonatomic) NSInteger insertIndex;

@property (nonatomic, strong) NSString *key;

@property (nonatomic) BOOL toRemove;
@property (nonatomic) BOOL noTransform;

@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readonly, weak) UIView *viewToAdd;

/////////////////////////////////////////
// Constructor methods
/////////////////////////////////////////
- (id)initWithView:(UIView *)view;
- (id)initWithView:(UIView *)view
    startTransform:(CGAffineTransform)startTransform
   appearTransform:(CGAffineTransform)appear
      endTransform:(CGAffineTransform)endTransform;
- (id)initWithDictionary:(NSDictionary *)element conductor:(SFOnboardingConductor*)conductor;
+ (id)elementWithDictionary:(NSDictionary *)element conductor:(SFOnboardingConductor *)conductor;

/////////////////////////////////////////
// Perform the appropriate animation in its entirety on the element's view
/////////////////////////////////////////
- (void)animateDisappearanceWithCompletion:(CompletionBlock)completion;
- (void)animateAppearanceWithCompletion:(CompletionBlock)completion;
- (void)animateApperance;
- (void)animateDisappearance;

/////////////////////////////////////////
// Perform a partial animation on the element's view
/////////////////////////////////////////
- (void)animateAppearanceWithFraction:(CGFloat)fraction;
- (void)animateDisappearanceWithFraction:(CGFloat)fraction;
@end
