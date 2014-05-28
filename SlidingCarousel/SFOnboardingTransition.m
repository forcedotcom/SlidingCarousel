//
//  SFOnboardingTransition.m
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
