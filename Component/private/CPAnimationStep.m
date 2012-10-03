
//  Created by Yang Meyer on 26.07.11.
//  Copyright 2011-2012 compeople AG. All rights reserved.

#import "CPAnimationStep.h"

@interface CPAnimationStep()
/** A temporary reverse queue of animation steps, i.e. from last to first.
 It is created when the step is run, and is modified during the animation, 
 and is destroyed when the animation finishes. */
@property (nonatomic, strong) NSMutableArray* consumableSteps;
@end

@implementation CPAnimationStep

@synthesize delay, duration, step, options;
@synthesize consumableSteps;

#pragma mark overrides


#pragma mark construction

+ (id) after:(NSTimeInterval)delay animate:(AnimationStep)step {
	return [self after:delay for:0.0 options:0 animate:step delegate:nil];
}

+ (id) after:(NSTimeInterval)delay animate:(AnimationStep)step delegate:(id<CPAnimationStepDelegate>)delegate {
    return [self after:delay for:0.0 options:0 animate:step delegate:delegate];
}

+ (id) for:(NSTimeInterval)duration animate:(AnimationStep)step {
   return [self after:0.0 for:duration options:0 animate:step delegate:nil];
}

+ (id) for:(NSTimeInterval)duration animate:(AnimationStep)step delegate:(id<CPAnimationStepDelegate>)delegate {
    return [self after:0.0 for:duration options:0 animate:step delegate:delegate];
}

+ (id) after:(NSTimeInterval)delay for:(NSTimeInterval)duration animate:(AnimationStep)step {
	return [self after:delay for:duration options:0 animate:step delegate:nil];
}

+ (id) after:(NSTimeInterval)delay for:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animate:(AnimationStep)step {
    return [self after:delay for:duration options:options animate:step delegate:nil];
}

+ (id) after:(NSTimeInterval)theDelay
		 for:(NSTimeInterval)theDuration
	 options:(UIViewAnimationOptions)theOptions
     animate:(AnimationStep)theStep
    delegate:(id<CPAnimationStepDelegate>)theDelegate {
    
   	CPAnimationStep* instance = [[self alloc] init];
	if (instance) {
		instance.delay = theDelay;
		instance.duration = theDuration;
		instance.options = theOptions;
		instance.step = [theStep copy];
        instance.delegate = theDelegate;
	}
	return instance;
}

#pragma mark action

// From http://stackoverflow.com/questions/4007023/blocks-instead-of-performselectorwithobjectafterdelay
+ (void) runBlock:(AnimationStep)block afterDelay:(NSTimeInterval)delay {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*delay), dispatch_get_current_queue(), block);
}

- (NSArray*) animationStepArray {
	// subclasses must override this!
	return [NSArray arrayWithObject:self];
}

- (AnimationStep) animationStep:(BOOL)animated {
	// override it if needed
	return self.step;
}

- (void) runAnimated:(BOOL)animated {
	if (!self.consumableSteps) { // Recursion start anchor
		self.consumableSteps = [[NSMutableArray alloc] initWithArray:[self animationStepArray]];
        [self.delegate animationDidStart:self];
	}
	if (![self.consumableSteps count]) { // Recursion end anchor
		self.consumableSteps = nil;
		return; // we're done
        [self.delegate animationDidFinish:self];
	}
    
    AnimationCompletionStep completionStep = ^(CPAnimationStep* completedStep){
        [self.consumableSteps removeLastObject];
        NSLog(@"About to tell delegate that we're done");
        if (!self){ NSLog(@"WTF we're nil!"); }
        if (!self.delegate){ NSLog(@"WTF delegate is nil! Our class is %@", [self class]); }
        [self.delegate animationDidFinish:completedStep];
        NSLog(@"Supposedly just told delegate that we're done");
		[self runAnimated:animated]; // recurse!
    };
    
	CPAnimationStep* currentStep = [self.consumableSteps lastObject];
    [self.delegate animationDidStart:currentStep];
	// Note: do not animate to short steps
	if (animated && currentStep.duration >= 0.02) {
        NSLog(@"Actually animation this step");
		[UIView animateWithDuration:currentStep.duration
							  delay:currentStep.delay
							options:currentStep.options
						 animations:[currentStep animationStep:animated]
						 completion:^(BOOL finished) {
							 if (finished) {
								 completionStep(currentStep);
							 }
                             else {
                                 NSLog(@"Step supposedly didn't complete, but notifying delgate anyway");
                                 completionStep(currentStep);
                             }
						 }];
	} else {
        NSLog(@"Skipping animation and just completing");
		void (^execution)(void) = ^{
            NSLog(@"Inside execution block");
			[currentStep animationStep:animated]();
			completionStep(currentStep);
		};
		
		if (animated && currentStep.delay) {
            NSLog(@"Waiting for %f seconds and then completing", currentStep.delay);
			[CPAnimationStep runBlock:execution afterDelay:currentStep.delay];
		} else {
			execution();
		}
	}
}

- (void) run {
	//NSLog(@"%@", self);
	[self runAnimated:YES];
}

#pragma mark - pretty-print

- (NSString*) description {
	NSMutableString* result = [[NSMutableString alloc] initWithCapacity:100];
	[result appendString:@"\n["];
	if (self.delay > 0.0) {
		[result appendFormat:@"after:%.1f ", self.delay];
	}
	if (self.duration > 0.0) {
		[result appendFormat:@"for:%.1f ", self.duration];
	}
	if (self.options > 0) {
		[result appendFormat:@"options:%d ", self.options];
	}
	[result appendFormat:@"animate:%@", self.step];
	[result appendString:@"]"];
	return result;
}

@end
