//
//  CarouselOnboardingViewController.m
//  Chatter
//
//  Created by Alex Sikora on 2/13/14.

/*
 Copyright (c) 2014, Salesforce.com, Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of Salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SFCarouselOnboardingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SFOnboardingConductor.h"

@interface SFCarouselOnboardingViewController () <UIScrollViewDelegate, SFOnboardingConductorDelegate>

@property (nonatomic, strong) SFOnboardingConductor *conductor;

@end

@implementation SFCarouselOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"onboarding" withExtension:@"json"]];
    self.conductor = [[SFOnboardingConductor alloc] initWithContainer:self.view jsonSpec:data delegate:self];
    self.conductor.mainScrollView.backgroundColor = [UIColor colorWithRed:0.165 green:0.58 blue:0.839 alpha:1.0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.conductor scrollViewDidScroll:self.conductor.mainScrollView];
}

#pragma mark - SFOnboardingConductorDelegate

/*
 A couple of the pop-up views are a bit too complicated to define in a JSON file,
 so this delegate method is called to ask the delegate if they would like to configure
 custom subviews or animations for elements to use when transitioning
 */
- (void)configureCustomViewsAndAnimations:(SFOnboardingConductor *)conductor {
    [self configureCustomSubviews:conductor];
    [self configureCustomAnimations:conductor];
}

- (void)configureCustomSubviews:(SFOnboardingConductor *)conductor {
    //Custom subview for creating a bubble with localized text in it
    //This view is a bubble with a variety of text views located in it, including some
    //overlapping images and text. This is compressed down into one view and assigned
    //to a key that it used within in the JSON file. Search for "screen2Bubble" in the JSON
    UIImageView *screen2BubbleBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble_01b.png"]];
    UIImageView *screen2BubbleTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble_01a.png"]];
    
    screen2BubbleBottom.layer.anchorPoint = CGPointMake(1.0, 0.0);
    screen2BubbleTop.layer.anchorPoint = CGPointMake(1.0, 0.0);
    
    screen2BubbleBottom.center = CGPointMake(CGRectGetWidth(screen2BubbleTop.frame), 0.0);
    screen2BubbleTop.center = CGPointMake(CGRectGetWidth(screen2BubbleTop.frame), 0.0);
    
    UIView *screen2Bubble = [[UIView alloc] initWithFrame:screen2BubbleTop.frame];
    screen2Bubble.frame = CGRectMake(self.view.frame.origin.x + 30 , self.view.frame.origin.y + 150, screen2Bubble.frame.size.width, screen2Bubble.frame.size.height);
    screen2Bubble.layer.anchorPoint = CGPointMake(0.0, 0.2);
    screen2Bubble.backgroundColor = [UIColor clearColor];
    
    [screen2Bubble addSubview:screen2BubbleBottom];
    
    UILabel *search = [[UILabel alloc] initWithFrame:CGRectMake(83, 28, 77, 20)];
    search.font = [UIFont systemFontOfSize:13.0];
    search.textColor = [UIColor whiteColor];
    search.userInteractionEnabled = NO;
    search.text = NSLocalizedString(@"Supports", @"Supports");
    search.backgroundColor = [UIColor clearColor];
    search.lineBreakMode = NSLineBreakByClipping;
    
    
    UILabel *account = [[UILabel alloc] initWithFrame:CGRectMake(93, 70, 70, 20)];
    account.font = [UIFont systemFontOfSize:13.0];
    account.textColor = [UIColor whiteColor];
    account.userInteractionEnabled = NO;
    account.text = NSLocalizedString(@"Custom", @"Custom");
    account.backgroundColor = [UIColor clearColor];
    account.lineBreakMode = NSLineBreakByClipping;
    
    UILabel *contact = [[UILabel alloc] initWithFrame:CGRectMake(93, 110, 70, 20)];
    contact.font = [UIFont systemFontOfSize:13.0];
    contact.textColor = [UIColor whiteColor];
    contact.userInteractionEnabled = NO;
    contact.text = NSLocalizedString(@"Views", @"Views");
    contact.backgroundColor = [UIColor clearColor];
    contact.lineBreakMode = NSLineBreakByClipping;
    
    [screen2Bubble addSubview:search];
    [screen2Bubble addSubview:account];
    [screen2Bubble addSubview:contact];
    
    [screen2Bubble addSubview:screen2BubbleTop];
    
    screen2Bubble.layer.rasterizationScale = 2.0;
    
    [conductor setCustomSubview:screen2Bubble forKey:@"screen2Bubble"];
    
    //Custom subview for creating a bubble with localized text in it
    //This is a similar view that's slightly less complicated
    UIImageView *screen4BubbleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble_02.png"]];
    UITextView *taskLabel = [[UITextView alloc] initWithFrame:CGRectMake(15, 90, 120, 24)];
    taskLabel.font = [UIFont systemFontOfSize:12.0];
    taskLabel.textColor = [UIColor whiteColor];
    taskLabel.userInteractionEnabled = NO;
    taskLabel.textAlignment = NSTextAlignmentCenter;
    taskLabel.text = NSLocalizedString(@"Fully customizable", @"Fully customizable");
    taskLabel.backgroundColor = [UIColor clearColor];
    
    UIView *screen4Bubble = [[UIView alloc] initWithFrame:screen4BubbleImage.frame];
    screen4Bubble.layer.anchorPoint = CGPointMake(1.0, 0.0);
    screen4Bubble.center = CGPointMake(CGRectGetMaxX(self.view.frame) - 130, 200);
    screen4Bubble.backgroundColor = [UIColor clearColor];
    
    [screen4Bubble addSubview:screen4BubbleImage];
    [screen4Bubble addSubview:taskLabel];
    screen4Bubble.layer.rasterizationScale = 2.0;
    
    [conductor setCustomSubview:screen4Bubble forKey:@"screen4Bubble"];
    
}

- (void)configureCustomAnimations:(SFOnboardingConductor *)conductor {
    /*
     These animation blocks can be assigned to a key as well for any appear/disappear animation.
     They take a percentage completed and a completion block to call when done (not used at this time).
     Your custom code can use this percentage to perform any animation desired. In this particular example, 
     the button grows and then shrinks during the transition.
     */
    //Custom bounce and scale animation for Button
    [conductor setCustomAnimation: ^(UIView *view, CGFloat percentage, CompletionBlock completion){
        CGFloat fraction = percentage * 2.0;
        fraction = fraction > 1.0 ? 1.0 : fraction;
        if (fraction < 0.3) {
            view.transform = CGAffineTransformMakeScale(1.0 + fraction, 1.0 + fraction);
        } else {
            CGFloat scale = 1.3 - ((fraction - 0.3) * 2.0);
            view.transform = CGAffineTransformMakeScale(scale,scale);
        }
    } forKey:@"mdpDisappear"]; //This key is used in the JSON file to specify this transition
    
    //This is a basic alpha transition, if you want a fade only transition
    [conductor setCustomAnimation:^(UIView *view, CGFloat percentage, CompletionBlock completion) {
        view.alpha = percentage;
    } forKey:@"alpha"];
}


#pragma mark - Instance Methods

- (void)bounce:(UITapGestureRecognizer *)tap {
    CABasicAnimation *floatScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    floatScale.toValue = [NSNumber numberWithFloat:0.9];
    floatScale.duration = 0.1f;
    floatScale.autoreverses = YES;
    floatScale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [tap.view.layer addAnimation:floatScale forKey:nil];
}

- (void)didCloseOnPage:(NSInteger)page conductor:(SFOnboardingConductor *)conductor {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0.0f;
    } completion:nil];
}

@end
