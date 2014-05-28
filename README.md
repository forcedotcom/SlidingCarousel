#SlidingCarousel

 A tool used to create the onboarding experience for Salesforce1's hybrid application on iOS. Define your onboarding experience with images and a JSON file (and any custom views with Objective-C code), and the conductor takes care of the rest!



##How to Use:
####Instantiate an Onboarding Conductor:
>NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"OnboardingData" withExtension:@"json"]];
>self.conductor = [[SFOnboardingConductor alloc] initWithContainer:self.view jsonSpec:data delegate:self];


##Define your JSON:

###JSON Format:
Root Dictionary: Contains the keys defined below.

>"baseImageURL" - String prefix for all UIImage retrievals  
>"pages" - Integer, number of pages  
>"parallaxBackground" - Array of keys for custom or defined images that will make up the background.  
>"floatingImages" - Array of keys to apply a built-in floating animation  
>"motionEnabled" - Boolean Whether the background supports Apple's UIMotionEffect (on supported devices)  
>"showSkip" - Boolean Whether to show the built in skip control. Creates an image with the key "skip". Can customize its transitions.  
>"showPageControl" - Boolean Whether to show the built in page control.  
>"scrollScale" - Parallax scale for background images. Default is 0.45 if not defined  
>"pageText" - Dictionary of String Index Keys and Titles to show under each onboarding screen if desired.
    numberOfPages - 1 key is the dismiss button.

images - Array of Image dictionary defined below.

####Image Definition:
Can contain any of the following keys
>{
>The key to reference this image, one of the few mandatory keys. Used for transitions (Defined below) to   
>specify what view they are affecting
>>"key": "Name",

>The name of the image to load. Only the final part of the path if you have a baseImageURL  
>>"imageName: "ImageName.png",

>The anchor point for positioning and animation. In this example, it's the left wall half way down the image.  
>>"anchorPoint" : [0.0, 0.5],

>(Optional) If this key is supplied, the relative position will be calculated against the position of the  
>image referenced in this String. AnotherImageKey must be defined ahead of this image.  
>>"relativeKey" : "AnotherImageKey"

>This key defines the 0,0 appearance position of this image. If no relativeKey is provided  
>this calculates against the root view's bounds, otherwise it calculates against the relativeKey's position.  
>Note: Values can be <0 and >1. If you wanted an image to be centered above another one, you could use [0.5, 0.5].  
>If you wanted it to be on its right wall you could use [1.0, 0.5]. If you wanted it to be left of the parent image, you   
>could use [-0.25, 0.5].   
>This calculates using the frame width of the parent.   
>For the example below, here is how the position would be calculated:  
>>X: AnotherImageKey.frame.origin.x + (0.65 * AnotherImageKey.frame.size.width)  
>>Y: AnotherImageKey.frame.origin.y + (0.24 * AnotherImageKey.frame.size.height)  
>Use this + anchorPoint to truly specify your  
>>"relativePosition" : [0.65, 0.24],  

>(Optional)Boolean value for whether or not the view should be added when its created (otherwise  
>the transition element adds it as needed)  
>>"addImmediately": 1
>}

>"elements" - Array of Transition dictionaries defined below.

####Transition Definition:
May contain any of the following keys. 
>{
>This is the key to reference this transition by. Useful for debugging  
>String
>>"key": "Key",

>The array of views. These views can be defined in the views array or customized in code.  
>One view key will use one view, otherwise it will add additional views as subviews on top of the 0 index view.  
>Array of Strings  
>>"views" : ["ViewKey"],

>What view to add this view to (and also create its relative positions). This can be  
>a view defined in the images array or a custom subview defined in code.  
>String  
>>"superview": "SuperView",

>The scale of the view at the beginning of its inbound animation (and if going backwards)  
>Float  
>>"startScale": 1.2, 

>The scale of the view when finished transitioning and at its rest state  
>Float  
>>"appearScale": 1.0,

>The scale of the view when animating away (forward) In this example the view  
>Float  
>>"endScale": 0.2,

>The position of the view relative to its appearance position when beginning its transition.  
>In this example, the view starts 250 points to the "right" of it's appear position.  
>Defined as an array of [x,y] coordinates  
>Array of Floats  
>>"startPosition": [250.0, 0.0],  

>The position of the view after its animating in transition, as defined by the given view's superview.  
>This is often 0,0 but if you want to play with it you can as well  
>Defined as an array of [x,y] coordinates  
>Array of Floats  
>>"appearPosition": [0.0, 0.0],

>The position of the view when transitioning away from it.  
>Defined as an array of [x,y] coordinates  
>Array of Floats  
>>"endPosition": [0.0, 0.0],

>The springDamping value to use in an animation. Same properties as Apple's UIView animation methods.  
>Float  
>>"springDamping": 0.4,

>The springVelocity value to use in an animation. Same properties as Apple's UIView animation methods.  
>Float  
>>"springVelocity": 10.0,

>The fraction with which to delay  
>Float  
>>"appearanceDelay": 0.5,

#####These arrays indicate when this element should appear

>If the item animates in (i.e. The items that pop up on Page 3 of the demo) on a particular index.  
>Start from 0. In this example on the second page the item would animate in.  
>Array of Integers, Starting from 0  
>>"item": [2],

>If you want the item to disappear if you drag backwards from a page where it animated in.  
>Example: The bubble on Page 2 of the demo. It animates in when you finish dragging, but  
>transitions with the drag on the way back.  
>Set to the same value as the indices in the "item" key.  
>Array of Integers, Starting from 0  
>>dragDisappear": [2],

>If the item appears as you drag to display a page, add that page index here.  
>Array of Integers, Starting from 0  
>>"appear": [4], 

>If the item disappears as you drag to a particular page, add that page index here.  
>Starting from 0. List the index of the page you are going to. In this example, the element  
>appears as you drag in to page 4, and disappears as you drag on to page 5.   
>Array of Integers, Starting from 0  
>>"disappear": [5],

>Allows you to use a custom animation defined in Objective-C (See above for how to add a custom animation)  
>for your appearance.  
>String  
>>"customAppearAnimation": "ACustomAnimationKey",

>Allows you to use a custom animation defined in Objective-C (See above for how to add a custom animation)  
>for your appearance.  
>String  
>>"customDisappearAnimation": "ACustomAnimationKey"

>What subview index to insert this view in (useful when layering multiple objects)  
>Integer  
>>"insertIndex": 3,

>Whether or not to remove this view when its animated away from.  
>Boolean  
>>"remove": 1

>}

Note: Multiple Transitions can apply to the same views, so you can create custom animations for an object for different page indices. Do not apply multiple transitions to the same object for one transition. 


###Objective-C:
####Creating a custom view or animation:
>You can set a view for a particular key that your Transition Elements can use above.   
>Simply implement the SFOnboardingConductorDelegate method  
>>- (void)configureCustomViewsAndAnimations:(SFOnboardingConductor *)conductor

>In this method you can call [conductor setCustomSubview:view forKey:key] or [conductor setCustomAnimation:animationBlock forKey:key]  
>with a custom UIView or AnimationBlock instances.  
>These keys are used by the Transition dictionaries above!  