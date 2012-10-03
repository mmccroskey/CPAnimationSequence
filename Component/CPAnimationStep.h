
//  Created by Yang Meyer on 26.07.11.
//  Copyright 2011 compeople AG. All rights reserved.

#import <Foundation/Foundation.h>

@class CPAnimationStep;

/** Helper type definitions for the component. */
typedef void (^AnimationStep)(void);
typedef void(^AnimationCompletionStep)(CPAnimationStep* step);

@protocol CPAnimationStepDelegate <NSObject>
@optional
- (void)animationDidStart:(CPAnimationStep*)animation;
- (void)animationDidFinish:(CPAnimationStep*)animation;
@end

/** 
 A CPAnimationStep defines a single animation object with a delay, duration, execution block and animation options.
 */
@interface CPAnimationStep : NSObject

#pragma mark - constructors

+ (id) after:(NSTimeInterval)delay
	 animate:(AnimationStep)step;

+ (id) after:(NSTimeInterval)delay
     animate:(AnimationStep)step
    delegate:(id<CPAnimationStepDelegate>)delegate;

+ (id) for:(NSTimeInterval)duration
   animate:(AnimationStep)step;

+ (id) for:(NSTimeInterval)duration
   animate:(AnimationStep)step
  delegate:(id<CPAnimationStepDelegate>)delegate;

+ (id) after:(NSTimeInterval)delay
		 for:(NSTimeInterval)duration
	 animate:(AnimationStep)step;

+ (id) after:(NSTimeInterval)delay
		 for:(NSTimeInterval)duration
	 options:(UIViewAnimationOptions)theOptions
	 animate:(AnimationStep)step;

+ (id) after:(NSTimeInterval)delay
		 for:(NSTimeInterval)duration
	 options:(UIViewAnimationOptions)theOptions
     animate:(AnimationStep)step
    delegate:(id<CPAnimationStepDelegate>)delegate;

#pragma mark - properties (normally already set by the constructor)

@property (nonatomic) NSTimeInterval delay;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, copy) AnimationStep step;
@property (nonatomic) UIViewAnimationOptions options;
@property (nonatomic, strong) id<CPAnimationStepDelegate> delegate;

#pragma mark - execution

/** Starts the step execution. */
- (void) runAnimated:(BOOL)animated;
/** Shortcut for [step runAnimated:YES] */
- (void) run;

@end
