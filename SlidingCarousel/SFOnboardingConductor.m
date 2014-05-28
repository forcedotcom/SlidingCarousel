//
//  SFOnboardingConductor.m
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

#import "SFOnboardingConductor.h"

static const CGSize  kMotionEffectRange = { 15, 15 };
static const CGFloat kScrollScale = 0.45;

@interface SFOnboardingConductor () 

//UI Properties
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *skip;

//Onboarding Views
@property (nonatomic, strong) NSMutableDictionary *views;
@property (nonatomic, strong) NSMutableDictionary *customSubviews;
@property (nonatomic, strong) NSMutableDictionary *customAnimations;
@property (nonatomic, strong) NSMutableArray *backgroundViews;
@property (nonatomic, strong) NSArray *textItems;

//Onboarding Elements
@property (nonatomic, strong) NSMutableArray *pageAnimations;
@property (nonatomic, strong) NSMutableArray *pageItems;
@property (nonatomic, strong) NSMutableDictionary *visitedTransitions;
@property (nonatomic) NSInteger previousPage;

//Scroll Properties
@property (nonatomic) CGFloat scrollScale;

@property (nonatomic, strong) NSData *jsonData;
@end

@implementation SFOnboardingConductor

- (id)initWithContainer:(UIView *)containerView jsonSpec:(NSData *)jsonData delegate:(NSObject<SFOnboardingConductorDelegate> *)delegate {
    if (self = [self init]) {
        self.containerView = containerView;
        self.jsonData = jsonData;
        
        self.views = [NSMutableDictionary dictionary];
        self.customSubviews = [NSMutableDictionary dictionary];
        self.customAnimations = [NSMutableDictionary dictionary];
        self.backgroundViews = [NSMutableArray array];
        self.visitedTransitions = [NSMutableDictionary dictionary];
        
        self.delegate = delegate;
        
        
        [self configureOnboardingView];
    }
    
    return self;
}

- (void)configureOnboardingView {
    [self configureScrollView];
    [self parseJson];
}

- (void)configureScrollView {
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.containerView.bounds];
    self.mainScrollView.delegate = self;
    self.mainScrollView.accessibilityIdentifier = @"onboard.scrollview";
    self.mainScrollView.accessibilityLabel = @"Onboarding View";
    self.mainScrollView.pagingEnabled = YES;
    
    [self.containerView addSubview:self.mainScrollView];
}

- (void)configurePageControl {
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    self.pageControl.center = CGPointMake(CGRectGetMidX(self.containerView.bounds), CGRectGetMaxY(self.containerView.bounds) - (25));
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:(39.0/255.0) green:(138/255.0) blue:(199/255.0) alpha:1.0];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:(165/255.0) green:(175/255.0) blue:(183/255.0) alpha:1.0];
    self.pageControl.frame = CGRectIntegral(self.pageControl.frame);
    self.pageControl.userInteractionEnabled = NO;
    [self.containerView addSubview:self.pageControl];
}

- (void)configureSkipButton {
    self.skip = [UIButton buttonWithType:UIButtonTypeCustom];
    self.skip.frame = CGRectMake(0, 0, 100, 20);
    [self.skip.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [self.skip setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.skip setTitle:NSLocalizedString(@"Skip", @"Skip") forState:UIControlStateNormal];
    [self.skip addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    self.skip.center = CGPointMake(CGRectGetMaxX(self.containerView.bounds) - 59, self.containerView.bounds.size.height - 25);
    self.skip.frame = CGRectIntegral(self.skip.frame);
    self.skip.accessibilityIdentifier = @"onboard.skip";
    
    [self setView:self.skip forKey:@"skip" withInfo:nil];
    
    [self.containerView addSubview:self.skip];
}

- (void)parseJson {
    NSError *error;
    NSDictionary *onboardingDictionary = [NSJSONSerialization JSONObjectWithData:self.jsonData options:kNilOptions error:&error];
    if (error) {
        NSLog(@"Error loading JSON: %@", error);
        return;
    }
    
    //Configure a variety of parameters based on the number of pages desired by the user
    NSNumber *pages = onboardingDictionary[@"pages"];
    self.mainScrollView.contentSize = CGSizeMake([pages integerValue] * self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height);
    
    self.pageItems = [NSMutableArray arrayWithCapacity:[pages integerValue] + 1];
    self.pageAnimations = [NSMutableArray arrayWithCapacity:[pages integerValue] + 1];
    for (NSInteger i = 0; i < [pages integerValue] + 1; i++) {
        [self.pageItems addObject:[NSMutableArray array]];
        [self.pageAnimations addObject:[NSMutableDictionary dictionaryWithObjects:@[[NSMutableArray array], [NSMutableArray array], [NSMutableArray array]] forKeys:@[@"Appear", @"Disappear", @"DragDisappear"]]];
    }
    
    BOOL showPageControl = [onboardingDictionary[@"showPageControl"] boolValue];
    if (showPageControl) {
        [self configurePageControl];
        self.pageControl.numberOfPages = pages.integerValue;
    }
    
    BOOL showSkipButton = [onboardingDictionary[@"showSkip"] boolValue];
    if (showSkipButton) {
        [self configureSkipButton];
    }
    
    //This is for the background view parallax speed as a percentage of regular scroll speed
    NSNumber *scrollScale = onboardingDictionary[@"scrollScale"];
    if (scrollScale) {
        self.scrollScale = scrollScale.floatValue;
    } else {
        self.scrollScale = kScrollScale;
    }
    
    //Create all the image views for the "images" array
    [self processViews:onboardingDictionary];
    
    //Allow the delegate to create any custom subviews or animations for the elements to use
    if ([self.delegate respondsToSelector:@selector(configureCustomViewsAndAnimations:)]) {
        [self.delegate configureCustomViewsAndAnimations:self];
    }
    
    //Create textviews/buttons for the onboarding text and dismissal button
    [self processText:onboardingDictionary];
    
    //Parse each element and assign it to the correct transition point
    for (NSDictionary *element in onboardingDictionary[@"elements"]) {
        [SFOnboardingElement elementWithDictionary:element conductor:self];
    }
}

- (void)processViews:(NSDictionary *)onboardingDictionary {
    NSString *baseImageURL = onboardingDictionary[@"baseImageURL"];
    
    //Iterate over each image and configure its parameters
    for (NSDictionary *view in onboardingDictionary[@"images"]) {
        NSString *imageName = [baseImageURL stringByAppendingString:view[@"imageName"]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        NSArray *anchorPoint = view[@"anchorPoint"];
        BOOL addImmediately = [view[@"addImmediately"] boolValue];
        NSString *key = view[@"key"];
        NSArray *relativePosition = view[@"relativePosition"];
        NSArray *relativeKey = view[@"relativeKey"];
        
        if (anchorPoint) {
            imageView.layer.anchorPoint = [self pointFromArray:anchorPoint];
        }
        
        if (relativePosition) {
            CGPoint relative = [self pointFromArray:relativePosition];
            if (relativeKey) {
                /*If a view has a relative position, and a view that its position should be calculated against
                 then set the center based on that relative view's position.
                 These would need to be defined ahead of the sub-view in order to function
                 These positions are based on the width/height of the relativeKey view.
                 
                 For example. View A is relativePosition of (0.5, 0.5) of View B. It will show up in (ViewB.centerX, viewB.centerY).
                 If View A is relativePosition(1.5, 0.5) of View B. It will show up at (ViewB.originX + (1.5 * ViewB.width),ViewB.centerY)
                 */
                
                UIView *relativeView = self.views[relativeKey][@"view"];
                imageView.center = CGPointMake(CGRectGetMinX(relativeView.frame) + (relative.x * CGRectGetWidth(relativeView.bounds)), CGRectGetMinY(relativeView.frame) + (relative.y * CGRectGetHeight(relativeView.bounds)));
            } else {
                //Views with a relative position and no view to relate to are calculated as
                //subviews of the container in terms of positioning.
                imageView.center = CGPointMake(relative.x * CGRectGetWidth(self.containerView.bounds), relative.y * CGRectGetHeight(self.containerView.bounds));
            }
        }
        
        CGRect frame = CGRectIntegral(imageView.frame);
        imageView.frame = CGRectMake(frame.origin.x, frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
        
        if (addImmediately) {
            [self.containerView addSubview:imageView];
        }
        
        //Store the image along with its relative positioning/parent view information
        [self setView:imageView forKey:key withInfo:view];
    }
    
    //Images specified as a background image are handled here.
    [self configureBackground:onboardingDictionary];
}

- (void)configureBackground:(NSDictionary *)onboardingDictionary {
    //Images that are specified as a background image receive their assignment for
    //parallax scrolling as well as any animation/UIMotion effects
    
    NSArray *parallaxBackground = onboardingDictionary[@"parallaxBackground"];
    NSArray *floatingImages = onboardingDictionary[@"floatingImages"];
    NSArray *motionImages = onboardingDictionary[@"motionImages"];
    
    for (NSString *key in parallaxBackground) {
        UIView *view = [self viewForKey:key];
        [self.backgroundViews addObject:view];
        if (!view.superview) {
            NSDictionary *info = [self infoForKey:key];
            NSArray *relativePosition = info[@"relativePosition"];
            if (relativePosition) {
                CGPoint relative = [self pointFromArray:relativePosition];
                view.center = CGPointMake(relative.x * CGRectGetWidth(self.containerView.bounds), relative.y * CGRectGetHeight(self.containerView.bounds));
            }
            [self.containerView insertSubview:view atIndex:1];
        }
    }
    
    for (NSString *key in floatingImages) {
        UIView *view = [self viewForKey:key];
        if (view) {
            [self addBounceToView:view];
        }
    }
    
    for (NSString *key in motionImages) {
        UIView *view = [self viewForKey:key];
        if (view) {
            [self addMotionToView:view];
        }
    }
}

- (void)processText:(NSDictionary *)onboardingDictionary {
    NSMutableArray *array = [NSMutableArray array];
    
    NSDictionary *texts = onboardingDictionary[@"pageTexts"];
    if (!texts) {
        return;
    }
    
    for (NSInteger i = 0; i < self.pageControl.numberOfPages - 1; i++) {
        NSString *text = [texts objectForKey:[NSString stringWithFormat:@"%d",i]];
        if (text) {
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 264, 80)];
            textLabel.font = [UIFont systemFontOfSize:16];
            textLabel.textColor = [UIColor blackColor];
            textLabel.textAlignment = NSTextAlignmentCenter;
            textLabel.text = text;
            textLabel.numberOfLines = 3;
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.userInteractionEnabled = NO;
            textLabel.center = CGPointMake((i * (self.containerView.frame.size.width)) + (self.containerView.frame.size.width * 0.5), CGRectGetMaxY(self.containerView.frame) - (60));
            [self.containerView addSubview:textLabel];
            
            [array addObject:textLabel];
        }
    }
    
    NSString *text = [texts objectForKey:[NSString stringWithFormat:@"%d", self.pageControl.numberOfPages - 1]];
    if (text) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [button.titleLabel setTextAlignment:NSTextAlignmentRight];
        [button setTitle:text forState:UIControlStateNormal];
        [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        
        button.frame = CGRectMake(0, 0, 264, 35);
        button.center = CGPointMake(( (self.pageControl.numberOfPages - 1) * (self.containerView.frame.size.width)) + (self.containerView.frame.size.width * 0.5), CGRectGetMaxY(self.containerView.frame) - (100));
        
        [button addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:button];
        [array addObject:button];
    }
    
    self.textItems = array;
}

#pragma mark - Custom Configuration
- (void)setView:(UIView *)view forKey:(NSString *)key withInfo:(NSDictionary *)info {
    if (info) {
        [self.views setObject:@{@"view": view, @"info": info} forKey:key];
    } else {
        [self.views setObject:@{@"view": view} forKey:key];
    }
}

- (UIView *)viewForKey:(NSString *)key {
    return self.views[key][@"view"];
}

- (NSDictionary *)infoForKey:(NSString *)key {
    return self.views[key][@"info"];
}

- (void)setCustomSubview:(UIView *)customView forKey:(NSString *)key {
    [self.customSubviews setObject:customView forKey:key];
}

- (UIView *)customSubviewForKey:(NSString *)key {
    return [self.customSubviews objectForKey:key];
}

- (void)setCustomAnimation:(AnimationBlock)animation forKey:(NSString *)key {
    [self.customAnimations setObject:animation forKey:key];
}

- (AnimationBlock)customAnimationForKey:(NSString *)key {
    return [self.customAnimations objectForKey:key];
}

- (void)setElement:(SFOnboardingElement *)element forIndices:(NSArray *)indices {
    NSArray *itemIndexes = indices[0];
    NSArray *appearIndexes = indices[1];
    NSArray *disappearIndexes = indices[2];
    NSArray *dragDisappearIndexes = indices[3];
    
    //This index is when the item should animate in
    for (NSNumber *number in itemIndexes) {
        NSMutableArray *itemArray = [self.pageItems objectAtIndex:[number integerValue]];
        [itemArray addObject:element];
    }
    
    //These pages are when the element should animate in on drag
    for (NSNumber *number in appearIndexes) {
        NSMutableArray *itemArray = [[self.pageAnimations objectAtIndex:[number integerValue]] objectForKey:@"Appear"];
        [itemArray addObject:element];
    }
    
    //These pages are when the element should animate away on drag
    for (NSNumber *number in disappearIndexes) {
        NSMutableArray *itemArray = [[self.pageAnimations objectAtIndex:[number integerValue]] objectForKey:@"Disappear"];
        [itemArray addObject:element];
    }
    
    //These pages are when an element should animate away when dragging
    //backwards, used when the element did not appear by drag but should disappear
    for (NSNumber *number in dragDisappearIndexes) {
        NSMutableArray *itemArray = [[self.pageAnimations objectAtIndex:[number integerValue]] objectForKey:@"DragDisappear"];
        [itemArray addObject:element];
    }
}

#pragma mark - Background Animations

- (void)addBounceToView:(UIView *)view {
    CABasicAnimation *floatDown = [CABasicAnimation animationWithKeyPath:@"position.y"];
    floatDown.toValue = [NSNumber numberWithFloat:view.center.y + 5];
    floatDown.duration = 2.0f;
    floatDown.autoreverses = YES;
    floatDown.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    floatDown.repeatCount = HUGE_VALF;
    
    CABasicAnimation *floatSide = [CABasicAnimation animationWithKeyPath:@"position.x"];
    floatSide.toValue = [NSNumber numberWithFloat:view.center.x + 3];
    floatSide.duration = 5.0f;
    floatSide.autoreverses = YES;
    floatSide.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    floatSide.repeatCount = HUGE_VALF;
    
    CABasicAnimation *floatScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    floatScale.toValue = [NSNumber numberWithFloat:1.1];
    floatScale.duration = 3.0f;
    floatScale.autoreverses = YES;
    floatScale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    floatScale.repeatCount = HUGE_VALF;
    
    
    [view.layer addAnimation:floatDown forKey:nil];
    [view.layer addAnimation:floatSide forKey:nil];
    [view.layer addAnimation:floatScale forKey:nil];
}

- (void)addMotionToView:(UIView *)view {
    //Add motion effects if possible
    Class interpolatingMotionEffectClass = NSClassFromString(@"UIInterpolatingMotionEffect");
    if (interpolatingMotionEffectClass) {
        UIInterpolatingMotionEffect *verticalEffect = [[interpolatingMotionEffectClass alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalEffect.minimumRelativeValue = @(-kMotionEffectRange.height);
        verticalEffect.maximumRelativeValue = @(kMotionEffectRange.height);
        
        UIInterpolatingMotionEffect *horizontalEffect = [[interpolatingMotionEffectClass alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalEffect.minimumRelativeValue = @(-kMotionEffectRange.width);
        horizontalEffect.maximumRelativeValue = @(kMotionEffectRange.width);
        
        Class motionEffectGroupClass = NSClassFromString(@"UIMotionEffectGroup");
        UIMotionEffectGroup *group = [motionEffectGroupClass new];
        group.motionEffects = @[ horizontalEffect, verticalEffect ];
        
        [view addMotionEffect:group];
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentX = scrollView.contentOffset.x;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-80 - (scrollView.contentOffset.x * self.scrollScale), 0.0f);
    for (UIView *view in self.backgroundViews) {
        view.transform = transform;
    }
    
    CGAffineTransform textTransform = CGAffineTransformMakeTranslation(0 - scrollView.contentOffset.x, 0.0f);
    for (UIView *view in self.textItems) {
        view.transform = textTransform;
    }
    NSInteger page = MAX(0, MIN(self.pageControl.numberOfPages,((contentX / scrollView.frame.size.width) + 0.5)));
    self.pageControl.currentPage = page;
    
    
    
    if ((fmodf(contentX, scrollView.frame.size.width) == 0)) {
        NSInteger index = (NSInteger)(contentX / scrollView.frame.size.width);
        NSArray *pageAnimations = [self.pageItems objectAtIndex:index];
        for (SFOnboardingElement *element in pageAnimations) {
            [self addElementToView:element];
            [element animateApperance];
        }
        
        [self removeSubviewsFromPreviousPagesWithCurrentPage:index];
        
        [self.visitedTransitions removeAllObjects];
        
        self.previousPage = index;
        
        [self updateAccessibilityElement:[self.textItems objectAtIndex:index]];
    } else if (contentX > 0) {
        NSInteger index = ceilf(contentX / scrollView.frame.size.width);
        [self.visitedTransitions setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d", index]];
        [self animateTransitionWithContentX:contentX index:index];
    }
}

- (void)addElementToView:(SFOnboardingElement *)element {
    if (!element.view.superview) {
        element.view.alpha = 0.0f;
        if (element.viewToAdd) {
            if (element.insertIndex == -1) {
                [element.viewToAdd addSubview:element.view];
            } else {
                [element.viewToAdd insertSubview:element.view atIndex:element.insertIndex];
            }
        } else {
            if (element.insertIndex == -1) {
                [self.containerView addSubview:element.view];
            } else {
                [self.containerView insertSubview:element.view atIndex:element.insertIndex];
            }
        }
        [UIView animateWithDuration:0.1 animations:^{
            element.view.alpha = 1.0f;
        }];
    }
}

- (void)animateTransitionWithContentX:(CGFloat)contentX index:(NSInteger)index {
    NSDictionary *transitions = [self.pageAnimations objectAtIndex:index];
    NSArray *appear = [transitions objectForKey:@"Appear"];
    NSArray *disappear = [transitions objectForKey:@"Disappear"];
    CGFloat percentage = (fmodf(contentX, self.mainScrollView.frame.size.width) ) / self.mainScrollView.frame.size.width;
    if (percentage <= 0.0 || percentage >= 100.0) {
        return;
    }
    for (SFOnboardingElement *element in appear) {
        [self addElementToView:element];
        [element animateAppearanceWithFraction:percentage];
    }
    for (SFOnboardingElement *element in disappear) {
        [self addElementToView:element];
        [element animateDisappearanceWithFraction:percentage];
    }
    
    if (self.previousPage > index - 1) {
        NSArray *dragDisappear = [transitions objectForKey:@"DragDisappear"];
        for (SFOnboardingElement *element in dragDisappear) {
            [element animateDisappearanceWithFraction:1.0 - percentage];
        }
    }
}

- (void)removeSubviewsFromPreviousPagesWithCurrentPage:(NSInteger)index {
    for (NSString *key in self.visitedTransitions) {
        NSInteger i = [key integerValue];
        
        BOOL reverse = i > index;
        
        NSDictionary *transitions = [self.pageAnimations objectAtIndex:i];
        NSArray *appear = reverse ? [transitions objectForKey:@"Disappear"] : [transitions objectForKey:@"Appear"];
        NSArray *disappear = reverse ? [transitions objectForKey:@"Appear"] : [transitions objectForKey:@"Disappear"];
        if (reverse) {
            disappear = [disappear arrayByAddingObjectsFromArray:[transitions objectForKey:@"DragDisappear"]];
        }
        for (SFOnboardingElement *element in appear) {
            reverse ? [element animateDisappearanceWithFraction:0.0] : [element animateAppearanceWithFraction:1.0];
        }
        
        if (i == index) {
            continue;
        }
        
        for (SFOnboardingElement *element in disappear) {
            if (element.view.superview) {
                reverse ? [element animateAppearanceWithFraction:0.0] : [element animateDisappearanceWithFraction:1.0];
                if (element.toRemove) {
                    [UIView animateWithDuration:0.2 animations:^{
                        element.view.alpha = 0.0f;
                    } completion:^(BOOL finished) {
                        [element.view removeFromSuperview];
                    }];
                }
            }
        }
    }
}

#pragma mark - Actions

- (void)closeAction {
    if ([self.delegate respondsToSelector:@selector(didCloseOnPage:conductor:)]) {
        [self.delegate didCloseOnPage:self.pageControl.currentPage conductor:self];
    }
}

- (BOOL)goToPage:(NSInteger)page {
    if (page >= self.pageControl.numberOfPages || page < 0) {
        return NO;
    }
    
    [self.mainScrollView scrollRectToVisible:CGRectMake(self.mainScrollView.frame.size.width * page, 0, self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height) animated:YES];
    return YES;
}

#pragma mark - Helper Methods

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

#pragma mark - Accessibility Methods

- (BOOL)accessibilityPerformEscape {
    [self closeAction];
    return YES;
}

- (BOOL)accessibilityPerformMagicTap {
    if (self.pageControl.currentPage + 1 < self.pageControl.numberOfPages) {
        return [self goToPage:self.pageControl.currentPage + 1];
    } else {
        [self closeAction];
    }
    return YES;
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction {
    if (direction == UIAccessibilityScrollDirectionRight || direction == UIAccessibilityScrollDirectionPrevious) {
        return [self goToPage:self.pageControl.currentPage - 1];
    } else if (direction == UIAccessibilityScrollDirectionLeft || direction == UIAccessibilityScrollDirectionNext) {
        return [self goToPage:self.pageControl.currentPage + 1];
    }
    return NO;
}

- (void)updateAccessibilityElement:(id)element {
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, element);
}

@end
