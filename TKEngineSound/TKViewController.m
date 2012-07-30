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
    float firstRPM;
    
    int mode;
    int gears;
    int gearNow;
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
    gears = 4;
    mode = 0;
    gearNow = 1;
    firstRPM = rpmValue;
    
    [source stop];
    [source clear];
    ALBuffer *buffer = [audioStartIdle objectAtIndex:1];
    [source play:buffer loop:YES];
    source.volume = 1;
    lastOnRPM = -1;
    lastOffRPM = -1;
}

-(IBAction)pressedOn:(id)sender{
    // Нажали кнопку газа
    buttonPressed = TRUE;
    timeLastPressed = [NSDate date];
//    switch (mode) {
//        case 0:
//            [self performSelectorInBackground:@selector(neutralOn) withObject:self];
//            break;
//        case 1:
//            [self performSelectorInBackground:@selector(comfortOn) withObject:self];
//            break;
//        case 2:
//            [self performSelectorInBackground:@selector(sportOn) withObject:self];
//            break;
//        default:
//            [self performSelectorInBackground:@selector(stopEngine) withObject:self];
//            break;
//    }
    [self performSelectorInBackground:@selector(comfortOn) withObject:self];
}

-(IBAction)pressedOff:(id)sender{
    // Отпустили кнопку газа
    buttonPressed = FALSE;
    timeLastPressedOff = [NSDate date];
//    switch (mode) {
//        case 0:
//            [self performSelectorInBackground:@selector(neutralOff) withObject:self];
//            break;
//        case 1:
//            [self performSelectorInBackground:@selector(comfortOff) withObject:self];
//            break;
//        case 2:
//            [self performSelectorInBackground:@selector(sportOff) withObject:self];
//            break;
//        default:
//            [self performSelectorInBackground:@selector(stopEngine) withObject:self];
//            break;
//    }
    [self performSelectorInBackground:@selector(comfortOff) withObject:self];
}

-(void)neutralOn{
    [source stop];
    [source clear];
    ALBuffer *buffer = [audioOnBuffers objectAtIndex:2];
    [source play:buffer loop:YES];
    
    firstRPM = rpmValue;
    float dt = 0;
    while(buttonPressed){
        dt = -[timeLastPressed timeIntervalSinceNow];
        if(firstRPM + dt * 0.8 < 3){
            rpmValue = firstRPM + dt * 0.8;
            source.pitch = 0.2 + 0.7 * rpmValue/3;
            source.volume = 1;
        }
        [label performSelectorOnMainThread:@selector(setText:)
                                withObject:[NSString stringWithFormat:@"%f",rpmValue]
                             waitUntilDone:NO];
    }
}

-(void)neutralOff{
    [source stop];
    [source clear];
    ALBuffer *buffer = [audioOffBuffers objectAtIndex:0];
    [source play:buffer loop:YES];
    
    firstRPM = rpmValue;
    float dt = 0;
    while(!buttonPressed){
        if(firstRPM - dt * 0.6 > 0){
            rpmValue = firstRPM - dt * 0.6;
            dt = -[timeLastPressedOff timeIntervalSinceNow];
            source.pitch = 0.7 + 1.8 * rpmValue/3;
            source.volume = 1;
        }
        [label performSelectorOnMainThread:@selector(setText:)
                                withObject:[NSString stringWithFormat:@"%f",rpmValue]
                             waitUntilDone:NO];
    }
}

-(void)comfortOn{
    [source stop];
    [source clear];
    ALBuffer *buffer = [audioOnBuffers objectAtIndex:1];
    [source play:buffer loop:YES];
    
    firstRPM = rpmValue;
    float dt = 0;
    while(buttonPressed){
        dt = -[timeLastPressed timeIntervalSinceNow];
        
        if(firstRPM + dt * 0.8 < 2){
            rpmValue = firstRPM + dt*0.8;
            source.pitch = 0.4 + 0.4*rpmValue;
            source.volume = 1;
        } else{
            if (gearNow < gears) {
                [source stop];
                [source clear];
                ALBuffer *buffer = [audioOffBuffers objectAtIndex:1];
                [source play:buffer loop:YES];
                firstRPM = rpmValue;
                timeLastPressed = [NSDate date];
                dt = -[timeLastPressed timeIntervalSinceNow];
                while (firstRPM - dt * 2 > 1) {
                    rpmValue = firstRPM - dt * 2;
                    float tmp = rpmValue - (int)rpmValue;
                    source.pitch = 0.8 + tmp*0.4;
                    source.volume = 1;
                    dt = -[timeLastPressed timeIntervalSinceNow];
                    [label performSelectorOnMainThread:@selector(setText:)
                                            withObject:[NSString stringWithFormat:@"%f",rpmValue]
                                         waitUntilDone:NO];
                }
                firstRPM = 1;
                timeLastPressed = [NSDate date];
                gearNow++;
            }
        }
        [label performSelectorOnMainThread:@selector(setText:)
                                withObject:[NSString stringWithFormat:@"%f",rpmValue]
                             waitUntilDone:NO];
    }
}

-(void)comfortOff{
    [source stop];
    [source clear];
    ALBuffer *buffer = [audioOffBuffers objectAtIndex:1];
    [source play:buffer loop:YES];
    
    firstRPM = rpmValue;
    float dt = 0;
    while(!buttonPressed){
        dt = -[timeLastPressed timeIntervalSinceNow];
        if(firstRPM - dt * 0.6 > 1){
            rpmValue = firstRPM - dt * 0.6;
            source.pitch = 0.5 + 0.3*rpmValue;
            source.volume = 1;
        } else{
            if (gearNow > 1) {
                [source stop];
                [source clear];
                ALBuffer *buffer = [audioOnBuffers objectAtIndex:1];
                [source play:buffer loop:YES];
                firstRPM = rpmValue;
                timeLastPressed = [NSDate date];
                dt = -[timeLastPressed timeIntervalSinceNow];
                while (firstRPM + dt * 2.5 < 2) {
                    rpmValue = firstRPM + dt * 2.5;
                    float tmp = rpmValue - (int)rpmValue;
                    source.pitch = 0.9 + tmp*0.2;
                    source.volume = 1;
                    dt = -[timeLastPressed timeIntervalSinceNow];
                    [label performSelectorOnMainThread:@selector(setText:)
                                            withObject:[NSString stringWithFormat:@"%f",rpmValue]
                                         waitUntilDone:NO];
                }
                firstRPM = 2;
                timeLastPressed = [NSDate date];
                gearNow--;
            } else{
                if(firstRPM - dt * 0.6 > 0){
                    rpmValue = firstRPM - dt * 0.6;
                    source.pitch = 0.5 + 0.3*rpmValue;
                    source.volume = 1;
                }
            }
        }
        [label performSelectorOnMainThread:@selector(setText:)
                                withObject:[NSString stringWithFormat:@"%f",rpmValue]
                             waitUntilDone:NO];
    }
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
