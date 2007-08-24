//
//  MFAlertManager.h
//  Meteorologist
//
//  Created by Matthew Fahrenbacher on Fri Mar 14 2003.
//  Copyright (c) 2004 The Meteorologist Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MECity.h"
#import <Message/NSMailDelivery.h>

@class MFSongPlayer, MFMessageDisplay, MFEmailer;

@interface MFAlertManager : NSObject 
{
    NSMutableArray *alertingCities;
    
    MFSongPlayer *player;
	MFEmailer *emailer;

    IBOutlet MFMessageDisplay *displayer;
}

- (void)createAlertForCity:(MECity *)city withTitle:(NSString *)title withDescription:(NSString *)description withURLString:(NSString *)urlString;

- (void)addCity:(MECity *)city;
- (void)addCity:(MECity *)city alertOptions:(int)options email:(NSString *)email song:(NSString *)song warning:(NSArray *)warn;
- (void)removeCity:(MECity *)city;

- (IBAction)kill:(id)sender;

@end

@interface MFSongPlayer : NSObject
{
    NSSound *song;
    NSTimer *timer;
    NSTimer *killer;
}

- (BOOL)playSong:(NSString *)path;
- (void)kill;

@end


@interface MFMessageDisplay : NSObject
{
    IBOutlet NSTextView *message;
}

- (void)appendMessage:(NSString *)msg;
- (IBAction)clearLog:(id)sender;

@end


@interface MFEmailer : NSObject
{
}

- (void)emailMessage:(NSString *)msg toAccount:(NSString *)email;

@end