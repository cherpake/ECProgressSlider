//
//  ECProgressSlider.m
//
//  Created by Evgeny Cherpak on 11/21/12.
//
//

#import "ECProgressSlider.h"
#import <QuartzCore/QuartzCore.h>

@interface ECProgressSlider()

@property (nonatomic, assign) CGFloat progressValue;
@property (nonatomic, assign) CGFloat loadValue;

@property (nonatomic, assign) BOOL scrubbing;

@end

@implementation ECProgressSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setThumbImage:[UIImage imageNamed:@"SwitcherSliderThumb"] forState:UIControlStateNormal];
        [self setThumbImage:[UIImage imageNamed:@"SwitcherSliderThumb"] forState:UIControlStateHighlighted];
        
        self.layer.zPosition = NSIntegerMax;
        
        [self monitorScrubbing];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setThumbImage:[UIImage imageNamed:@"SwitcherSliderThumb"] forState:UIControlStateNormal];
    [self setThumbImage:[UIImage imageNamed:@"SwitcherSliderThumb"] forState:UIControlStateHighlighted];
    
    // HACK: interface builder doesn't allow to change the height of the UISlider
    CGRect frame = self.frame;
    CGFloat yOffset = (frame.size.height - 10.0) / 2.0;
    
    frame.origin.y += ceil(yOffset);
    frame.size.height = 10.0f;
    
    self.frame = frame;
    
    self.layer.zPosition = NSIntegerMax;
    
    [self monitorScrubbing];
}

- (void)monitorScrubbing
{
    [self addTarget:self action:@selector(scrubingHasStarted:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(scrubingHasFinished:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(scrubingHasFinished:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)scrubingHasStarted:(id)sender
{
    self.scrubbing = YES;
    [self setNeedsDisplay];
}

- (void)scrubingHasFinished:(id)sender
{
    self.scrubbing = NO;
    [self setNeedsDisplay];
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent*)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -20.0, -20.0);
    return CGRectContainsPoint(bounds, point);
}

- (BOOL) beginTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event {
    return YES;
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect result = [super trackRectForBounds:bounds];
    result.size.height = 0;
    return result;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    CGRect trackRect = [self trackRectForBounds:bounds];
    trackRect.size.height = bounds.size.height;
    CGRect result = [super thumbRectForBounds:bounds trackRect:trackRect value:value];
    return result;
}

- (void)setProgressValue:(CGFloat)progressValue
{
    if ( !self.scrubbing ) {
        self.value = progressValue;
    }
    _progressValue = progressValue;
    [self setNeedsDisplay];
}

- (void)setLoadValue:(CGFloat)loadValue
{
    _loadValue = loadValue;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGRect r = self.bounds;
    CGFloat cornerRadius = r.size.height / 2.0;
    CGMutablePathRef p = CGPathCreateMutable();
	
	CGPathMoveToPoint(p, NULL, r.origin.x + cornerRadius, r.origin.y );
	
	CGFloat maxX = CGRectGetMaxX( r );
	CGFloat maxY = CGRectGetMaxY( r );
	
	CGPathAddArcToPoint( p, NULL, maxX, r.origin.y, maxX, r.origin.y + cornerRadius, cornerRadius );
	CGPathAddArcToPoint( p, NULL, maxX, maxY, maxX - cornerRadius, maxY, cornerRadius );
	
	CGPathAddArcToPoint( p, NULL, r.origin.x, maxY, r.origin.x, maxY - cornerRadius, cornerRadius );
	CGPathAddArcToPoint( p, NULL, r.origin.x, r.origin.y, r.origin.x + cornerRadius, r.origin.y, cornerRadius );
    
    CGPathCloseSubpath(p);
    CGContextAddPath(c, p);
    CGContextClip(c);
        
    CGContextSetFillColorWithColor(c, [UIColor colorWithWhite:0.667 alpha:0.2].CGColor);
    CGContextFillRect(c, CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height));
    
    CGContextSetFillColorWithColor(c, [UIColor colorWithWhite:0.667 alpha:0.4].CGColor);
    CGContextFillRect(c, CGRectMake(r.origin.x, r.origin.y, ceil(r.size.width * self.loadValue), r.size.height));
    
    CGContextSetFillColorWithColor(c, [UIColor colorWithWhite:0.667 alpha:1.0].CGColor);
    
    // when scrubbing we should show the current progress and when not,
    // we should show current progress to the middle of the thumb (more accurate)
    if ( self.scrubbing ) {
        CGContextFillRect(c, CGRectMake(r.origin.x, r.origin.y, ceil(r.size.width * self.progressValue), r.size.height));
    } else {
        CGRect trackRect = [self trackRectForBounds:r];
        CGRect thumbRect = [self thumbRectForBounds:r trackRect:trackRect value:self.value];
        
        CGContextFillRect(c, CGRectMake(r.origin.x, r.origin.y, CGRectGetMidX(thumbRect), r.size.height));
    }
}

@end
