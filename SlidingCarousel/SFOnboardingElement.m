//
//  OnboardingElement.m
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

#import "SFOnboardingElement.h"

#import "SFOnboardingConductor.h"

@interface SFOnboardingElement ()

@property (nonatomic) BOOL animatedOnce;

@property (nonatomic, strong) UIView *view;
@property (nonatomic) CGAffineTransform startTransform;
@property (nonatomic) CGAffineTransform appearTransform;
@property (nonatomic) CGAffineTransform endTransform;

@property (nonatomic) CGFloat startScale;
@property (nonatomic) CGFloat appearScale;
@property (nonatomic) CGFloat endScale;
@property (nonatomic) CGPoint startPosition;
@property (nonatomic) CGPoint appearPosition;
@property (nonatomic) CGPoint endPosition;


@property (nonatomic) CGFloat duration;
@property (nonatomic) CGFloat delay;
@property (nonatomic) CGFloat springDamping;
@property (nonatomic) CGFloat springVelocity;

@property (nonatomic) CGFloat disppearanceMultiplier;
@property (nonatomic) CGFloat appearanceDelay;

@property (nonatomic, weak) UIView *viewToAdd;

@property (nonatomic, copy) AnimationBlock appearAnimation; //Takes a "percentage", -1 means full anim
@property (nonatomic, copy) AnimationBlock disappearAnimation; //Takes a "percentage" -1 means a full anim

@end

@implementation SFOnboardingElement

- (id)init {
    if (self = [super init]) {
        self.springDamping = 1.0f;
        self.springVelocity = 1.0f;
        
        self.duration = 0.2f;
        
        self.startScale = 1.0f;
        self.endScale = 1.0f;
        self.appearScale = 1.0f;
        
        self.insertIndex = -1;
        
        self.disppearanceMultiplier = 2.0f;
        
        self.appearanceDelay = 0.0f;
    }
    
    return self;
}

- (id)initWithView:(UIView *)view {
    if (self = [self init]) {
        self.view = view;
    }
    
    return self;
}

- (id)initWithView:(UIView *)view
    startTransform:(CGAffineTransform)startTransform
   appearTransform:(CGAffineTransform)appearTransform
      endTransform:(CGAffineTransform)endTransform {
    if (self = [self initWithView:view]) {
        self.startTransform = startTransform;
        self.view.transform = startTransform;
        self.appearTransform = appearTransform;
        self.endTransform = endTransform;
    }
    
    return self;
}

+ (id)elementWithDictionary:(NSDictionary *)element conductor:(SFOnboardingConductor *)conductor {
    return [[SFOnboardingElement alloc] initWithDictionary:element conductor:conductor];
}

- (id)initWithDictionary:(NSDictionary *)element conductor:(SFOnboardingConductor*)conductor {
    if (self = [self init]) {
        NSString *key = [element objectForKey:@"key"];
        NSArray *viewsArray = [element objectForKey:@"views"];
        NSNumber *startScale = [element objectForKey:@"startScale"];
        NSNumber *appearScale = [element objectForKey:@"appearScale"];
        NSNumber *endScale = [element objectForKey:@"endScale"];
        NSArray *startPosition = [element objectForKey:@"startPosition"];
        NSArray *appearPosition = [element objectForKey:@"appearPosition"];
        NSArray *endPosition = [element objectForKey:@"endPosition"];
        NSString *duration = [element objectForKey:@"duration"];
        NSString *delay = [element objectForKey:@"delay"];
        NSString *springDamping = [element objectForKey:@"springDamping"];
        NSString *springVelocity = [element objectForKey:@"springVelocity"];
        NSArray *itemIndexes = [element objectForKey:@"item"];
        NSArray *appearIndexes = [element objectForKey:@"appear"];
        NSArray *disappearIndexes = [element objectForKey:@"disappear"];
        NSArray *dragDisappearIndexes = [element objectForKey:@"dragDisappear"];
        NSNumber *toRemove = [element objectForKey:@"remove"];
        NSString *superviewKey = [element objectForKey:@"superview"];
        NSString *customAppearAnimationKey = [element objectForKey:@"customAppearAnimation"];
        NSString *customDisappearAnimationKey = [element objectForKey:@"customDisappearAnimation"];
        NSString *customSubviewsKey = [element objectForKey:@"customSubviews"];
        NSNumber *insertIndex = [element objectForKey:@"insertIndex"];
        NSString *appearanceDelay = [element objectForKey:@"appearanceDelay"];
        NSString *disappearanceMultiplier = [element objectForKey:@"disappearanceMultiplier"];
        
        if (key) {
            self.key = key;
        }
        
        NSString *viewKey = nil;
        
        if (viewsArray) {
            if ([viewsArray count] == 1) {
                //Single view, retrieve and set
                viewKey = [viewsArray objectAtIndex:0];
                UIView *theView = [conductor viewForKey:viewKey];;
                if (theView) {
                    self.view = theView;
                }
            } else if ([viewsArray count] > 1) { //0 views is ignored
                //If multiple views, place them on top of each other
                CGSize size = [conductor viewForKey:[viewsArray objectAtIndex:0]].frame.size;
                UIView *rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                rootView.backgroundColor = [UIColor clearColor];
                
                for (NSString *viewKey in viewsArray) {
                    UIView *viewToAdd = [conductor viewForKey:viewKey];
                    [rootView addSubview:viewToAdd];
                }
                
                self.view = rootView;
            }
        }
        
        if (startScale) {
            self.startScale = [startScale floatValue];
        }
        if (appearScale) {
            self.appearScale = [appearScale floatValue];
        }
        if (endScale) {
            self.endScale = [endScale floatValue];
        }
        
        if (startPosition) {
            self.startPosition = [self pointFromArray:startPosition];
        }
        if (appearPosition) {
            self.appearPosition = [self pointFromArray:appearPosition];
        }
        if (endPosition) {
            self.endPosition = [self pointFromArray:endPosition];
        }
        
        if (duration) {
            self.duration = [duration floatValue];
        }
        if (delay) {
            self.delay = [delay floatValue];
        }
        
        if (springDamping) {
            self.springDamping = [springDamping floatValue];
        }
        if (springVelocity) {
            self.springVelocity = [springVelocity floatValue];
        }
        
        if (superviewKey) {
            //Set which view this element's view should be added when it is supposed to appear
            UIView *addView = [conductor viewForKey:superviewKey];
            if (addView) {
                self.viewToAdd = addView;
            }
            
            //If the view has a relative position and a superview, but no key to be related to, then calculate its position in relation to the superview's internal bounds
            NSArray *relativePosition = [[conductor infoForKey:viewKey] objectForKey:@"relativePosition"];
            NSString *relativeKey = [[conductor infoForKey:viewKey] objectForKey:@"relativeKey"];
            if (relativePosition && !relativeKey) {
                CGPoint relative = [self pointFromArray:relativePosition];
                self.view.center = CGPointMake((relative.x * addView.frame.size.width),(relative.y * addView.frame.size.height));
            }
        }
        
        if (toRemove) {
            self.toRemove = [toRemove boolValue];
        }
        
        if (insertIndex) {
            self.insertIndex = [insertIndex integerValue];
        }
        
        //For these, grab one of the custom animations defined and stored in the dictionaries, these are usually more complex
        if (customAppearAnimationKey) {
            self.appearAnimation = [conductor customAnimationForKey:customAppearAnimationKey];
        }
        
        if (customDisappearAnimationKey) {
            self.disappearAnimation = [conductor customAnimationForKey:customDisappearAnimationKey];
        }
        
        //Grab the custom subview defined in-code
        if (customSubviewsKey) {
            self.view = [conductor customSubviewForKey:customSubviewsKey];
        }
        
        if (appearanceDelay) {
            self.appearanceDelay = [appearanceDelay floatValue];
        }
        if (disappearanceMultiplier) {
            self.disppearanceMultiplier = [disappearanceMultiplier floatValue];
        }
        
        self.noTransform = YES;
        self.view.userInteractionEnabled = NO;
        self.view.clipsToBounds = YES;
        
        if (!itemIndexes) {
            itemIndexes = [NSMutableArray array];
        }
        if (!appearIndexes) {
            appearIndexes = [NSMutableArray array];
        }
        if (!disappearIndexes) {
            disappearIndexes = [NSMutableArray array];
        }
        if (!dragDisappearIndexes) {
            dragDisappearIndexes = [NSMutableArray array];
        }
        
        [conductor setElement:self forIndices:@[itemIndexes, appearIndexes, disappearIndexes, dragDisappearIndexes]];
    }
    
    return self;
}

#pragma mark - Animations

- (void)animateDisappearanceWithCompletion:(CompletionBlock)completion {
    if (self.disappearAnimation) {
        self.disappearAnimation(self.view, -1, completion);
        return;
    }
    
    if (self.noTransform) {
        CGPoint translation = CGPointMake(self.endPosition.x - self.appearPosition.x, self.endPosition.y - self.appearPosition.y);
        self.endTransform =  CGAffineTransformConcat(CGAffineTransformMakeTranslation(translation.x, translation.y), CGAffineTransformMakeScale(self.endScale, self.endScale));
    }
    
    [UIView animateWithDuration:self.duration delay:self.delay usingSpringWithDamping:self.springDamping initialSpringVelocity:self.springVelocity options:0 animations:^{
        self.view.transform = self.endTransform;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)animateAppearanceWithCompletion:(CompletionBlock)completion {
    if (self.appearAnimation) {
        self.appearAnimation(self.view, -1, completion);
        return;
    }
    
    if (self.noTransform) {
        CGPoint translation = CGPointMake(self.appearPosition.x - self.startPosition.x, self.appearPosition.y - self.startPosition.y);
        self.appearTransform =  CGAffineTransformConcat(CGAffineTransformMakeTranslation(translation.x, translation.y), CGAffineTransformMakeScale(self.appearScale, self.appearScale));
        self.startTransform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(self.startPosition.x, self.startPosition.y), CGAffineTransformMakeScale(self.startScale, self.startScale));
    }
    
    if (!self.animatedOnce) {
        self.view.transform = self.startTransform;
        self.animatedOnce = YES;
    }
    
    [UIView animateWithDuration:self.duration delay:self.delay usingSpringWithDamping:self.springDamping initialSpringVelocity:self.springVelocity options:0 animations:^{
        self.view.transform = self.appearTransform;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)animateApperance {
    [self animateAppearanceWithCompletion:nil];
}

- (void)animateDisappearance {
    [self animateDisappearanceWithCompletion:nil];
}

- (void)animateAppearanceWithFraction:(CGFloat)fraction {
    if (self.appearAnimation) {
        self.appearAnimation(self.view, fraction, nil);
        return;
    }
    
    CGFloat percentage = 0.0f;
    if (self.appearanceDelay > 0.0) {
        percentage = fraction < self.appearanceDelay ? 0.0 : (fraction - self.appearanceDelay) * (1/self.appearanceDelay);
    } else {
        percentage = fraction;
    }
    
    percentage = percentage > 0.95 ? 1.0 : percentage;
    CGAffineTransform translate = [self calculatePartialTransformBetweenStartPosition:self.startPosition endPosition:self.appearPosition percentage:percentage];
    CGAffineTransform scale = [self calculatePartialTransformBetweenStartScale:self.startScale endScale:self.appearScale percentage:percentage];
    CGAffineTransform finalTransform = CGAffineTransformConcat(translate, scale);
    self.view.transform = finalTransform;
}

- (void)animateDisappearanceWithFraction:(CGFloat)fraction {
    if (self.disappearAnimation) {
        self.disappearAnimation(self.view, fraction, nil);
        return;
    }
    
    CGFloat percentage = fraction * self.disppearanceMultiplier > 1.0 ? 1.0 : fraction * self.disppearanceMultiplier;
    percentage = percentage > 0.95 ? 1.0 : percentage;
    CGAffineTransform translate = [self calculatePartialTransformBetweenStartPosition:self.appearPosition endPosition:self.endPosition percentage:percentage];
    CGAffineTransform scale = [self calculatePartialTransformBetweenStartScale:self.appearScale endScale:self.endScale percentage:percentage];
    CGAffineTransform finalTransform = CGAffineTransformConcat(translate, scale);
    
    self.view.transform = finalTransform;
}

#pragma mark - Helper Calculations

- (CGAffineTransform)calculatePartialTransformBetweenStartPosition:(CGPoint)startPosition endPosition:(CGPoint)endPosition percentage:(CGFloat)percentage {
    if ([self validStartPoint:startPosition finishPoint:endPosition]) {
        CGPoint newPoint = CGPointMake(startPosition.x + (percentage *(endPosition.x - startPosition.x)), startPosition.y + (percentage *(endPosition.y - startPosition.y)));
        return CGAffineTransformMakeTranslation(newPoint.x, newPoint.y);
    }
    
    return CGAffineTransformIdentity;
}

- (CGAffineTransform)calculatePartialTransformBetweenStartScale:(CGFloat)startScale endScale:(CGFloat)endScale percentage:(CGFloat)percentage {
    if ([self validStartScale:startScale finishScale:endScale]) {
        CGFloat partialScale = startScale + (percentage * (endScale - startScale));
        return CGAffineTransformMakeScale(partialScale, partialScale);
    }
    
    return CGAffineTransformIdentity;
}

- (BOOL)validStartPoint:(CGPoint)start finishPoint:(CGPoint)finish {
    return start.x != -1.0 && start.y != -1.0 && finish.x != -1.0 && finish.y != -1.0;
}

- (BOOL)validStartScale:(CGFloat)start finishScale:(CGFloat)finish {
    return start != -1.0 && finish != -1.0;
}

- (CGPoint)pointFromArray:(NSArray *)array {
    if (!array) {
        NSLog(@"Missing Point Array. Should be of format [x,y]");
        return CGPointZero;
    }
    if ([array count] < 2 || [array count] > 2) {
        NSLog(@"Incorrect Point Array: %@ - Should be of format [x,y]", array);
        return CGPointZero;
    }
    return CGPointMake([[array objectAtIndex:0] floatValue], [[array objectAtIndex:1] floatValue]);
}



@end
