//
//  TKViewController.m
//  TKEngineSound
//
//  Created by Timofey Korchagin on 27/07/2012.
//  Copyright (c) 2012 MIPT. All rights reserved.
//

#import "TKViewController.h"

@interface TKViewController ()
{
    bool started; // Заведен ли двигатель?
    bool buttonPressed; // Нажат ли газ?
    float rpmValue; // Обороты мотора
    ALChannelSource *channel;
	ALSource *source;
    ALSource *secondSource;
    NSMutableArray *audioOnBuffers;
    NSMutableArray *audioOffBuffers;
    NSMutableArray *audioStartIdle;
    NSDate *timeLastPressed;
    NSDate *timeLastPressedOff;
    int lastOnRPM;
    int lastOffRPM;
}
@end

@implementation TKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Initialize the OpenAL device and context here so that it doesn't happen
	// prematurely.
	
	// We'll let OALSimpleAudio deal with the device and context.
	// Sbince we're not going to use it for playing effects, don't give it any sources.
	[OALSimpleAudio sharedInstance].reservedSources = 0;
    
//    You could do all mp3 or any other format supported by iOS software decoding.
//    Any format requiring the hardware will only work on the first track that starts playing.
    
    audioStartIdle = [NSMutableArray arrayWithCapacity:1];
    audioOnBuffers = [NSMutableArray arrayWithCapacity:1];
    audioOffBuffers = [NSMutableArray arrayWithCapacity:1];
    
//    [self bufferStartIdle:@"shelby_startup_Starter3.wav"];
//    [self bufferStartIdle:@"firebird_idle.wav"];
//    
//    [self bufferTrackOff:@"firebird_offlow.wav"];
//    [self bufferTrackOff:@"firebird_offmid.wav"];
//    [self bufferTrackOff:@"firebird_offhigh.wav"];
//    
//    [self bufferTrackOn:@"firebird_onlow.wav"];
//    [self bufferTrackOn:@"firebird_onmid.wav"];
//    [self bufferTrackOn:@"firebird_onhigh.wav"];
    
    [self bufferStartIdle:@"audi_startup_Starter.wav"];
    [self bufferStartIdle:@"SL65_onidle.wav"];
    
    [self bufferTrackOff:@"SL65_offlow.wav"];
    [self bufferTrackOff:@"SL65_offmid.wav"];
    [self bufferTrackOff:@"SL65_offhigh.wav"];
    
    [self bufferTrackOn:@"SL65_onlow.wav"];
    [self bufferTrackOn:@"SL65_onmid.wav"];
    [self bufferTrackOn:@"SL65_onhigh.wav"];
    
    source = [ALSource source];
    secondSource = [ALSource source];
    rpmValue = 0;
    started = FALSE;
    buttonPressed = FALSE;
    timeLastPressed = [NSDate date];
    timeLastPressedOff = [NSDate date];
    
    [source stop];
    [source clear];
    ALBuffer *buffer = [audioStartIdle objectAtIndex:1];
    [source play:buffer loop:YES];
    source.volume = 1;
    lastOnRPM = -1;
    lastOffRPM = -1;
}

-(IBAction)accelerate:(id)sender{
    // Нажали кнопку газа
    buttonPressed = TRUE;
    timeLastPressed = [NSDate date];
    //[self accelerateOff];
    [self performSelectorInBackground:@selector(accelerateOn) withObject:self];    
}

-(IBAction)pressedOff:(id)sender{
    // Отпустили кнопку газа
    buttonPressed = FALSE;
    timeLastPressedOff = [NSDate date];
    //[self accelerateOff];
    [self performSelectorInBackground:@selector(accelerateOff) withObject:self];  
}

-(void)accelerateOn{
    [source stop];
    [source clear];
    
    
    ALBuffer *buffer = [audioOnBuffers objectAtIndex:2];
    [source play:buffer loop:YES];
    
    float firstRPM = rpmValue;
    float dt = 0;
    while(buttonPressed){
        dt = -[timeLastPressed timeIntervalSinceNow];
        if(firstRPM + dt * 0.8 < 3){
            rpmValue = firstRPM + dt*0.8;
            source.pitch = 0.3 + 0.8 * rpmValue/3;
            source.volume = 1;
        }
        label.text = [NSString stringWithFormat:@"%f",rpmValue];
    }

//    ALBuffer *buffer = [audioOnBuffers objectAtIndex:(int)rpmValue];
//    [source play:buffer loop:YES];
//    
//    float firstRPM = rpmValue;
//    float dt = 0;
//    while(buttonPressed){
//        dt = -[timeLastPressed timeIntervalSinceNow];
//        if(firstRPM + dt * 0.8 < 3){
//            rpmValue = firstRPM + dt*0.8;
//            float tmp = (rpmValue - (int)rpmValue);
//            source.pitch = 0.6+ 0.5 * tmp;
//            source.volume = 1 - 0.3 * tmp*tmp;
//        }
//        if( !((int)rpmValue == lastOnRPM)){
//            [source stop];
//            [source clear];
//            ALBuffer *buffer = [audioOnBuffers objectAtIndex:(int)rpmValue];
//            [source play:buffer loop:YES];
//            lastOnRPM = (int)rpmValue;
//        }
//        label.text = [NSString stringWithFormat:@"%f",rpmValue];
//    }
}

-(void)accelerateOff{
    [source stop];
    [source clear];
    ALBuffer *buffer = [audioOffBuffers objectAtIndex:1];
    [source play:buffer loop:YES];
    
    float firstRPM = rpmValue;
    float dt = 0;
    float minPitch = 0.5;
    while(!buttonPressed){
        if(firstRPM - dt * 0.6 > 0){
            rpmValue = firstRPM - dt * 0.6;
            dt = -[timeLastPressedOff timeIntervalSinceNow];
            source.pitch = 0.5 + 0.8*rpmValue/3;
            source.volume = 1;
        }
        label.text = [NSString stringWithFormat:@"%f",rpmValue];
    }
    
//    float firstRPM = rpmValue;
//    float dt = 0;
//    while(!buttonPressed){
//        dt = -[timeLastPressedOff timeIntervalSinceNow];
//        if(firstRPM - dt * 0.6 > 0){
//            rpmValue = firstRPM - dt * 0.6;
//            float tmp = (rpmValue - (int)rpmValue);
//            source.pitch = 0.6 + 0.5 * tmp;
//            source.volume = 1 - 0.3 * tmp*tmp;
//        }
//        if(!((int)rpmValue == lastOffRPM)){
//            [source stop];
//            [source clear];
//            ALBuffer *buffer = [audioOffBuffers objectAtIndex:(int)rpmValue];
//            [source play:buffer loop:YES];
//            lastOffRPM = (int)rpmValue;
//        }
//        label.text = [NSString stringWithFormat:@"%f",rpmValue];
//    }
}

-(void) bufferTrackOn:(NSString*) filename
{
    ALBuffer *trackBuffer = [[OpenALManager sharedInstance] bufferFromFile:filename reduceToMono:NO];
	[audioOnBuffers addObject:trackBuffer];
}

-(void) bufferTrackOff:(NSString*) filename
{
    ALBuffer *trackBuffer = [[OpenALManager sharedInstance] bufferFromFile:filename reduceToMono:NO];
	[audioOffBuffers addObject:trackBuffer];
}

-(void) bufferStartIdle:(NSString*) filename
{
    ALBuffer *trackBuffer = [[OpenALManager sharedInstance] bufferFromFile:filename reduceToMono:NO];
	[audioStartIdle addObject:trackBuffer];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
