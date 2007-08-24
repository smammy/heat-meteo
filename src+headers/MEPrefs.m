//
//  MEPrefs.m
//  Meteorologist
//
//  Created by Matthew Fahrenbacher on Thu Sep 05 2002.
//  Copyright (c) 2004 The Meteorologist Group. All rights reserved.
//

#import "MEPrefs.h"
#import <Carbon/Carbon.h>

@implementation MEPrefs 

#define defaults	([NSUserDefaults standardUserDefaults])
#define NUM_YES 	([NSNumber numberWithBool:YES])
#define NUM_NO		([NSNumber numberWithBool:NO])
#define NUM(x)		([NSNumber numberWithFloat:x])
#define ARC(x)		([NSArchiver archivedDataWithRootObject:x])
#define UNARC(x)	([NSUnarchiver unarchiveObjectWithData:x])

- (void)moveOldDefaults
{
    NSDictionary *old = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Library/Preferences/Meteorologist.plist",NSHomeDirectory()]];
    
    if(old)
    {
        [[NSFileManager defaultManager] removeFileAtPath:[NSString stringWithFormat:@"%@/Library/Preferences/Meteorologist.plist",NSHomeDirectory()] handler:nil];
        
        NSEnumerator *keyEnum = [old keyEnumerator];
        NSString *key;
        
        while(key = [keyEnum nextObject])
            [defaults setObject:[old objectForKey:key] forKey:key];
    }
}

- (id)init
{
    self = [super init];
    if(self)
    {
        [self moveOldDefaults];
    
        NSString *ver = [defaults objectForKey:@"version"];
		
        if(![self written] || NSOrderedAscending == [ver compare:@"01.04.00a"])
            [self resetDefaults]; 
        else if(NSOrderedAscending == [ver compare:VERSION])
            [self applyNewDefaults];
        else
            [self validateDefaults];
    }
    return self;
}

- (void)awakeFromNib
{
    NSArray *fonts = allFonts();
    
    [menuFontName addItemsWithTitles:fonts];
    [tempFont addItemsWithTitles:fonts];
    
    [self updateInterfaceFromDefaults];
    [self outletAction:nil];
    
    [checkProgress setUsesThreadedAnimation:YES];
    
    NSString *ver = @"";
    NSString *ser = @"";
    
    [checkProgress startAnimation:nil];
    
    if([self checkNewVersions])
    {
        ver = [self checkNewVersion];
        if(!ver)
            ver = @"No new versions of Meteo available.";
        else
        {
            [[checkResult window] makeKeyAndOrderFront:nil];
            [NSApp activateIgnoringOtherApps:YES];
        }
    }
    
    if([self checkNewServerErrors])
    {
        ser = [self checkForNewServerErrors];
        if(!ser)
            ser = @"No server errors to report.";
        else
        {
            [[checkResult window] makeKeyAndOrderFront:nil];
            [NSApp activateIgnoringOtherApps:YES];
        }
    }
    
    [checkProgress stopAnimation:nil];
    
	if (ver && ser)
		[checkResult setString:[NSString stringWithFormat:@"%@\n%@",ver,ser]];
    
    [[checkResult window] setDelegate:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self /* JRC */
			selector:@selector(textDidChange:)
			name:NSControlTextDidChangeNotification
			object:autoUpdateTime];
	[[NSNotificationCenter defaultCenter] addObserver:self /* JRC */
			selector:@selector(textDidChange:)
			name:NSControlTextDidChangeNotification
			object:cycleUpdateTime];
	[[NSNotificationCenter defaultCenter] addObserver:self /* JRC */
			selector:@selector(textDidChange:)
			name:NSControlTextDidChangeNotification
			object:changeUpdateTime];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
    [self checkUnsavedPrefs];
}

- (void)checkUnsavedPrefs
{
    if([applyButton isEnabled])
    {
		int result = NSRunAlertPanel(@"Unsaved preferences",
                                     @"Would you like to save the preferences you have not applied yet?",
                                     @"Save",
                                     @"Ignore",
                                     nil);

        if(result == NSOKButton)
            [self applyPrefs:nil];
    }
}

#pragma mark IBActions
- (IBAction)applyPrefs:(id)sender
{
    [self updateDefaultsFromInterface];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MEPrefsChanged" object:nil];
    [self outletAction:nil];
}

// "Reset to Defaults" button
- (IBAction)resetPrefs:(id)sender
{
	NSBeginAlertSheet(@"Confirm",@"Cancel",@"OK",
					  nil,prefsWindow, self, NULL,
					  @selector(endResetPrefsSheet:returnCode:contextInfo:),
					  NULL,
					  @"This operation will reset ALL preferences to their default values, including preferences displayed in other tabs.  Do you want to continue?");
}

- (IBAction)revertPrefs:(id)sender
{
	
    [self updateInterfaceFromDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MEPrefsChanged" object:nil];
    [self outletAction:nil];
}

- (IBAction)outletAction:(id)sender
{
    if(!updatingMenu)
    {
        [applyButton setEnabled:(sender != nil)];
        [revertButton setEnabled:(sender != nil)];
    }
    else
    {
        shouldActivateApply = YES;
        shouldActivateRevert = YES;
    }
}

#pragma mark -
// called when above sheet exits.
- (void)endResetPrefsSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertDefaultReturn) // Default is cancel
		;
	else if (returnCode == NSAlertAlternateReturn) {
		
		[self resetDefaults];               // sets to "defaults" to default values
		[self updateInterfaceFromDefaults]; // sets the states of all of the interface items.
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MEPrefsChanged" object:nil];
		[self outletAction:nil];
	}
}

#pragma mark -

- (NSString *)checkNewVersion
{
	return nil;
 /*   NSURL *url = [NSURL URLWithString:
                    [NSString stringWithFormat:@"http://heat-meteo.sourceforge.net/version.xml"]];

    NSData *data = [url resourceDataUsingCache:NO]; // sometimes freezes here?

    if(!data) {
		NSLog(@"Unable to retrieve version from %@", [url absoluteString]);
		return nil;
	}
    
    NSDictionary *info;
                                                      
    info = (NSDictionary *) CFPropertyListCreateFromXMLData(NULL,(CFDataRef)data, kCFPropertyListImmutable, NULL);
    
    NSString *newVer = [info objectForKey:@"version"];
    NSString *oldVer = VERSION;
	#ifdef DEBUG
	NSLog(@"oldversion is %@, newversion is %@", oldVer, newVer);
	#endif
    [info autorelease];
    
    if(NSOrderedAscending == [oldVer compare:newVer])
    {
        [self openHomePage:nil];
        return [NSString stringWithFormat:@"A new version of Meteo (%@) is available!",newVer];
    }
    else
        return nil; */
}

- (NSString *)checkForNewServerErrors
{
	return nil;
/*    NSURL *url = [NSURL URLWithString:
                    [NSString stringWithFormat:@"http://heat-meteo.sourceforge.net/errors.xml"]];

    NSData *data = [url resourceDataUsingCache:NO];

    if(!data) {
		NSLog(@"Unable to retrieve error report from %@", [url absoluteString]);
        return nil;
	}

    NSDictionary *info;
    
    info = (NSDictionary *) CFPropertyListCreateFromXMLData(NULL,(CFDataRef)data, kCFPropertyListImmutable, NULL);
    [info autorelease];
    
    return [info objectForKey:@"errors"];
	*/
}    

- (IBAction)checkNewVersionsNow:(id)sender
{
    [checkProgress startAnimation:nil];
    NSString *res = [self checkNewVersion];
    [checkProgress stopAnimation:nil];
    
    if(res)
        [checkResult setString:res];
    else
        [checkResult setString:@"No new versions of Meteo available."];
}

- (IBAction)checkNewServerErrorsNow:(id)sender
{
    [checkProgress startAnimation:nil];
    NSString *res = [self checkForNewServerErrors];
    [checkProgress stopAnimation:nil];
    
    if(res)
        [checkResult setString:res];
    else
        [checkResult setString:@"No server errors to report."];
}

- (IBAction)openGroupPage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://sourceforge.net/forum/forum.php?forum_id=268087"]];
}

- (IBAction)openHomePage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://sourceforge.net/projects/heat-meteo/"]];
}

- (IBAction)openEmail:(id)sender
{
    //[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:fahrenba@mac.com"]];
}

- (IBAction)openDonatation:(id)sender
{
//    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.paypal.com/xclick/business=fahrenba%40mac.com&item_name=Buy+Matt+a+car+so+he+doesn%27t+have+to+be+driven+to+and+from+work+by+his+father+fund&no_note=1&tax=0&currency_code=USD"]]
//;
}

- (IBAction)chooseAlertSong:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setTitle:@"Select a music file"];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setResolvesAliases:YES];
    
    if([panel runModalForTypes:[NSArray arrayWithObjects:@"aiff", @"aif", @"mp3", @"wav", @"wave", @"avi", @"swf", @"dv", @"mpeg", @"midi", @"mid", @"mpg", nil]]==NSOKButton)
    {
        NSString *filename = [[panel filenames] objectAtIndex:0];
        
        [alertSong setStringValue:filename];
        [self outletAction:sender];
    }
}

- (void)updateInterfaceFromDefaults
{
    int fdn = [self forecastDaysNumber];
    if(fdn == 0)
        fdn++;
    else if(fdn == 10)
        fdn--;
        
    int mfn = [self menuFontSize];
    if(mfn == 0)
        mfn += 8;

    [displayTodayInSubmenu setState:[self displayTodayInSubmenu]];
    [displayDayImage setState:[self displayDayImage]];
    [viewForecastInSubmenu setState:[self viewForecastInSubmenu]];
    [forecastDaysNumber selectItemAtIndex:fdn-1];
    [forecastDaysOn setState:[self forecastDaysOn]];
    [forecastInline setState:[self forecastInline]];

    [tempColor setColor:[self tempColor]];
    [tempFont selectItemWithTitle:[self tempFont]];
    [hideCF setState:[self hideCF]];
    [displayTemp setState:[self displayTemp]];
    
    [imageOpacity setFloatValue:[self imageOpacity]];
    
    if([self displayInDockAndMenuBar])
        [whereToDisplay selectCellAtRow:2 column:0];
    else if([self displayInDock])
        [whereToDisplay selectCellAtRow:1 column:0];
    else if([self displayInMenubar])
        [whereToDisplay selectCellAtRow:0 column:0];
    
    [displayCityName setState:[self displayCityName]];
    [displayMenuIcon setState:[self displayMenuIcon]];
    [menuFontName selectItemWithTitle:[self menuFontName]];
    [menuColor setColor:[self menuColor]];
    [menuFontSize selectItemAtIndex:mfn - 8];
    
    int mode = [self cycleMode];
    [cycleMode setState:(mode & 1) atRow:0 column:0];
    [cycleMode setState:(mode & 2) atRow:1 column:0];
    [cycleMode setState:(mode & 4) atRow:2 column:0];
    
	[autoUpdateTime setIntValue:[self autoUpdateTime]];
    [cycleUpdateTime setIntValue:[self cycleUpdateTime]];
	[changeUpdateTime setIntValue:[self changeUpdateTime]];
	    
    [checkNewServerErrors setState:[self checkNewServerErrors]];
    [checkNewVersions setState:[self checkNewVersions]];
    
    [useGlobalUnits setState:[self useGlobalUnits]];
    [degreeUnits selectItemWithTitle:[self degreeUnits]];
    [speedUnits selectItemWithTitle:[self speedUnits]];
    [distanceUnits selectItemWithTitle:[self distanceUnits]];
    [pressureUnits selectItemWithTitle:[self pressureUnits]];
    

    
    [embedControls setState:[self embedControls]];
    
    [alertEmail setStringValue:[self alertEmail]];
    [alertSong setStringValue:[self alertSong]];
    
    int theAlertOptions = [self alertOptions];
    [alertOptions setState:(theAlertOptions & 1) atRow:0 column:0];
    [alertOptions setState:(theAlertOptions & 2) atRow:1 column:0];
    [alertOptions setState:(theAlertOptions & 4) atRow:2 column:0];
    [alertOptions setState:(theAlertOptions & 8) atRow:3 column:0];
    
    [killOtherMeteo setState:[self killOtherMeteo]];
}

- (void)updateDefaultsFromInterface
{
    [defaults setObject:NUM([displayTodayInSubmenu state]) forKey:@"displayTodayInSubmenu"];
    [defaults setObject:NUM([displayDayImage state]) forKey:@"displayDayImage"];
    [defaults setObject:NUM([viewForecastInSubmenu state]) forKey:@"viewForecastInSubmenu"];
    [defaults setObject:NUM([forecastDaysNumber indexOfSelectedItem] + 1) forKey:@"forecastDaysNumber"];
    [defaults setObject:NUM([forecastDaysOn state]) forKey:@"forecastDaysOn"];
    [defaults setObject:NUM([forecastInline state]) forKey:@"forecastInline"];
    
    [defaults setObject:ARC([tempColor color]) forKey:@"tempColor"];
    [defaults setObject:[tempFont titleOfSelectedItem] forKey:@"tempFont"];
    [defaults setObject:NUM([hideCF state]) forKey:@"hideCF"];
    [defaults setObject:NUM([displayTemp state]) forKey:@"displayTemp"];
    
    [defaults setObject:NUM([imageOpacity floatValue]) forKey:@"imageOpacity"];
    NSString *plistPath = [NSString stringWithFormat:@"%@/%@",[[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent],@"Info.plist"];
    NSMutableDictionary *infoPlist = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    [infoPlist setObject:[NSString stringWithFormat:@"%d",([whereToDisplay selectedRow]==0)] forKey:@"NSUIElement"];
    [infoPlist writeToFile:plistPath atomically:NO];
    [defaults setObject:NUM([whereToDisplay selectedRow] != 1) forKey:@"displayInMenubar"];
    
    [defaults setObject:NUM([displayCityName state]) forKey:@"displayCityName"];
    [defaults setObject:NUM([displayMenuIcon state]) forKey:@"displayMenuIcon"];
    [defaults setObject:[menuFontName titleOfSelectedItem] forKey:@"menuFontName"];
    [defaults setObject:ARC([menuColor color]) forKey:@"menuColor"];
    [defaults setObject:NUM([menuFontSize indexOfSelectedItem] + 8) forKey:@"menuFontSize"];
    
    [defaults setObject:NUM([[cycleMode cellAtRow:0 column:0] state]*1 +
                            [[cycleMode cellAtRow:1 column:0] state]*2 +
                            [[cycleMode cellAtRow:2 column:0] state]*4) forKey:@"cycleMode"];

	if ([autoUpdateTime intValue] > 0)
		[defaults setObject:NUM([autoUpdateTime intValue]) forKey:@"autoUpdateTime"];
	else
		[autoUpdateTime setIntValue:[self autoUpdateTime]];
		
	if ([cycleUpdateTime intValue] > 0)
		[defaults setObject:NUM([cycleUpdateTime intValue]) forKey:@"cycleUpdateTime"];
	else
		[cycleUpdateTime setIntValue:[self cycleUpdateTime]];
		
	if ([changeUpdateTime intValue] > 0)
		[defaults setObject:NUM([changeUpdateTime intValue]) forKey:@"changeUpdateTime"];
    else
		[changeUpdateTime setIntValue:[self changeUpdateTime]];

    [defaults setObject:NUM([checkNewServerErrors state]) forKey:@"checkNewServerErrors"];
    [defaults setObject:NUM([checkNewVersions state]) forKey:@"checkNewVersions"];
    
    [defaults setObject:NUM([useGlobalUnits state]) forKey:@"useGlobalUnits"];
    [defaults setObject:[degreeUnits titleOfSelectedItem] forKey:@"degreeUnits"];
    [defaults setObject:[speedUnits titleOfSelectedItem] forKey:@"speedUnits"];
    [defaults setObject:[distanceUnits titleOfSelectedItem] forKey:@"distanceUnits"];
    [defaults setObject:[pressureUnits titleOfSelectedItem] forKey:@"pressureUnits"];
    
    [defaults setObject:NUM([embedControls state]) forKey:@"embedControls"];
    
    [defaults setObject:[alertEmail stringValue] forKey:@"alertEmail"];
    [defaults setObject:[alertSong stringValue] forKey:@"alertSong"];
    [defaults setObject:[NSNumber numberWithInt:[[alertOptions cellAtRow:0 column:0] state]*1 +
                                                [[alertOptions cellAtRow:1 column:0] state]*2 +
                                                [[alertOptions cellAtRow:2 column:0] state]*4 +
                                                [[alertOptions cellAtRow:3 column:0] state]*8] forKey:@"alertOptions"];
    
    [defaults setObject:[NSNumber numberWithBool:[killOtherMeteo state]] forKey:@"killOtherMeteo"];
    
    [defaults setObject:NUM_YES forKey:@"written_to"];
    [defaults setObject:VERSION forKey:@"version"];
}

- (void)validateDefaults
{
    if(![[defaults objectForKey:@"written_to"] isKindOfClass:[NSNumber class]]) 
    	[defaults setObject:NUM_YES forKey:@"written_to"];
    if(![[defaults objectForKey:@"version"] isKindOfClass:[NSString class]]) 
        [defaults setObject:VERSION forKey:@"version"];
    
    if(![[defaults objectForKey:@"displayTodayInSubmenu"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM_YES forKey:@"displayTodayInSubmenu"];
    if(![[defaults objectForKey:@"displayDayImage"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM_YES forKey:@"displayDayImage"];
    if(![[defaults objectForKey:@"viewForecastInSubmenu"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM_YES forKey:@"viewForecastInSubmenu"];
    if(![[defaults objectForKey:@"forecastDaysNumber"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM(3) forKey:@"forecastDaysNumber"];
    if(![[defaults objectForKey:@"forecastDaysOn"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM_YES forKey:@"forecastDaysOn"];
    if(![[defaults objectForKey:@"tempColor"] isKindOfClass:[NSData class]]) 
        [defaults setObject:ARC([NSColor blackColor]) forKey:@"tempColor"];
    if(![[defaults objectForKey:@"tempFont"] isKindOfClass:[NSString class]]) 
        [defaults setObject:@"LucidaGrande" forKey:@"tempFont"];
    if(![[defaults objectForKey:@"hideCF"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM_YES forKey:@"hideCF"];
    if(![[defaults objectForKey:@"displayTemp"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM_YES forKey:@"displayTemp"];
    if(![[defaults objectForKey:@"forecastInline"] isKindOfClass:[NSNumber class]])  
        [defaults setObject:NUM_NO forKey:@"forecastInline"];
    
    if(![[defaults objectForKey:@"imageOpacity"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM(1.0) forKey:@"imageOpacity"];
    
    if(![[defaults objectForKey:@"displayCityName"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM_YES forKey:@"displayCityName"];
    if(![[defaults objectForKey:@"displayMenuIcon"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM_YES forKey:@"displayMenuIcon"];
    if(![[defaults objectForKey:@"menuFontName"] isKindOfClass:[NSString class]]) 
        [defaults setObject:@"LucidaGrande" forKey:@"menuFontName"];
    if(![[defaults objectForKey:@"menuColor"] isKindOfClass:[NSData class]]) 
        [defaults setObject:ARC([NSColor blackColor]) forKey:@"menuColor"];
    if(![[defaults objectForKey:@"menuFontSize"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM(13) forKey:@"menuFontSize"];
    
    if(![[defaults objectForKey:@"checkNewServerErrors"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM_YES forKey:@"checkNewServerErrors"];
    if(![[defaults objectForKey:@"checkNewVersions"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM_YES forKey:@"checkNewVersions"];
    
    if(![[defaults objectForKey:@"cycleMode"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM(1) forKey:@"cycleMode"];
    if(![[defaults objectForKey:@"autoUpdateTime"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM(15) forKey:@"autoUpdateTime"];
    if(![[defaults objectForKey:@"cycleUpdateTime"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM(15) forKey:@"cycleUpdateTime"];
    if(![[defaults objectForKey:@"changeUpdateTime"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM(30) forKey:@"changeUpdateTime"];
    
    if(![[defaults objectForKey:@"useGlobalUnits"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM(0) forKey:@"useGlobalUnits"];
    if(![[defaults objectForKey:@"degreeUnits"] isKindOfClass:[NSString class]]) 
        [defaults setObject:@"Fahrenheit" forKey:@"degreeUnits"];
    if(![[defaults objectForKey:@"speedUnits"] isKindOfClass:[NSString class]]) 
        [defaults setObject:@"Miles/Hour" forKey:@"speedUnits"];
    if(![[defaults objectForKey:@"distanceUnits"] isKindOfClass:[NSString class]]) 
        [defaults setObject:@"Miles" forKey:@"distanceUnits"];
    if(![[defaults objectForKey:@"pressureUnits"] isKindOfClass:[NSString class]]) 
        [defaults setObject:@"Inches" forKey:@"pressureUnits"];
        
    if(![[defaults objectForKey:@"embedControls"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM_YES forKey:@"embedControls"];
        
    if(![[defaults objectForKey:@"alertEmail"] isKindOfClass:[NSString class]]) 
        [defaults setObject:@"" forKey:@"alertEmail"];
    if(![[defaults objectForKey:@"alertSong"] isKindOfClass:[NSString class]]) 
        [defaults setObject:@"" forKey:@"alertSong"];
    if(![[defaults objectForKey:@"alertOptions"] isKindOfClass:[NSNumber class]]) 
        [defaults setObject:NUM(0) forKey:@"alertOptions"];
        
    if(![[defaults objectForKey:@"killOtherMeteo"] isKindOfClass:[NSNumber class]])
        [defaults setObject:NUM(0) forKey:@"killOtherMeteo"];
        
    if(![[defaults objectForKey:@"displayInMenubar"] isKindOfClass:[NSNumber class]])
        [defaults setObject:NUM(1) forKey:@"displayInMenubar"];
		
	// check to see that fonts are installed
//	tempFont menuFontName
	NSArray *fonts = allFonts();
	if ([fonts indexOfObject:[defaults objectForKey:@"tempFont"]] == NSNotFound)
		[defaults setObject:[fonts objectAtIndex:0] forKey:@"tempFont"];
	if ([fonts indexOfObject:[defaults objectForKey:@"menuFontName"]] == NSNotFound)
		[defaults setObject:[fonts objectAtIndex:0] forKey:@"menuFontName"];
}

- (void)resetDefaults
{
    [defaults setObject:NUM_YES forKey:@"displayTodayInSubmenu"];
    [defaults setObject:NUM_YES forKey:@"displayDayImage"];
    [defaults setObject:NUM_YES forKey:@"viewForecastInSubmenu"];
    [defaults setObject:NUM(3) forKey:@"forecastDaysNumber"];
    [defaults setObject:NUM_YES forKey:@"forecastDaysOn"];
    [defaults setObject:NUM_NO forKey:@"forecastInline"];
    
    [defaults setObject:ARC([NSColor blackColor]) forKey:@"tempColor"];
    [defaults setObject:@"LucidaGrande" forKey:@"tempFont"];
    [defaults setObject:NUM_YES forKey:@"hideCF"];
    [defaults setObject:NUM_YES forKey:@"displayTemp"];
    
    [defaults setObject:NUM(1.0) forKey:@"imageOpacity"];
    NSString *plistPath = [NSString stringWithFormat:@"%@/%@",[[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent],@"Info.plist"];
    NSMutableDictionary *infoPlist = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    [infoPlist setObject:[NSString stringWithFormat:@"%d",1] forKey:@"NSUIElement"];
    [infoPlist writeToFile:plistPath atomically:NO];
    
    [defaults setObject:NUM_YES forKey:@"displayCityName"];
    [defaults setObject:NUM_YES forKey:@"displayMenuIcon"];
    [defaults setObject:@"LucidaGrande" forKey:@"menuFontName"];
    [defaults setObject:ARC([NSColor blackColor]) forKey:@"menuColor"];
    [defaults setObject:NUM(13) forKey:@"menuFontSize"];
    
    [defaults setObject:NUM(1) forKey:@"cycleMode"];
    [defaults setObject:NUM(15) forKey:@"autoUpdateTime"];
    [defaults setObject:NUM(15) forKey:@"cycleUpdateTime"];
    [defaults setObject:NUM(30) forKey:@"changeUpdateTime"];
    
    [defaults setObject:NUM_YES forKey:@"checkNewServerErrors"];
    [defaults setObject:NUM_YES forKey:@"checkNewVersions"];;
    
    [defaults setObject:NUM(0) forKey:@"useGlobalUnits"];
    [defaults setObject:@"Fahrenheit" forKey:@"degreeUnits"];
    [defaults setObject:@"Miles/Hour" forKey:@"speedUnits"];
    [defaults setObject:@"Miles" forKey:@"distanceUnits"];
    [defaults setObject:@"Inches" forKey:@"pressureUnits"];
    
    [defaults setObject:NUM_YES forKey:@"embedControls"];
    
    [defaults setObject:@"" forKey:@"alertEmail"];
    [defaults setObject:@"" forKey:@"alertSong"];
    [defaults setObject:NUM(0) forKey:@"alertOptions"];
    
    [defaults setObject:NUM(0) forKey:@"killOtherMeteo"];
    [defaults setObject:NUM(1) forKey:@"displayInMenubar"];
    
    [defaults setObject:NUM_YES forKey:@"written_to"];
    [defaults setObject:VERSION forKey:@"version"];
}

- (void)applyNewDefaults
{
    NSString *ver = [defaults objectForKey:@"version"];
    
    if(NSOrderedAscending == [ver compare:(@"01.02.00")])
    {
        [defaults setObject:NUM_NO forKey:@"forecastInline"];
        [defaults setObject:NUM(8) forKey:@"menuFontSize"];
        
        [defaults setObject:NUM(0) forKey:@"useGlobalUnits"];
        [defaults setObject:@"Fahrenheit" forKey:@"degreeUnits"];
        [defaults setObject:@"Miles/Hour" forKey:@"speedUnits"];
        [defaults setObject:@"Miles" forKey:@"distanceUnits"];
        [defaults setObject:@"Inches" forKey:@"pressureUnits"];
    }
    if(NSOrderedAscending == [ver compare:(@"01.02.01")])
    {
        [defaults setObject:NUM(30) forKey:@"changeUpdateTime"];
    }
    if(NSOrderedAscending == [ver compare:(@"01.02.02")])
    {
        if([[defaults objectForKey:@"forecastDaysNumber"] intValue] == 10)
            [defaults setObject:NUM(9) forKey:@"forecastDaysNumber"];
    }
    if(NSOrderedAscending == [ver compare:(@"01.02.03")])
    {
        [defaults setObject:NUM_YES forKey:@"embedControls"];
    }
    if(NSOrderedAscending == [ver compare:(@"01.02.05")])
    {
        [defaults setObject:@"" forKey:@"alertEmail"];
    	[defaults setObject:@"" forKey:@"alertSong"];
    	[defaults setObject:NUM(0) forKey:@"alertOptions"];
    }
    if(NSOrderedAscending == [ver compare:(@"01.02.06")])
    {
        [defaults setObject:NUM(0) forKey:@"killOtherMeteo"];
        [defaults setObject:NUM(1) forKey:@"displayInMenubar"];
        [defaults setObject:NUM(1) forKey:@"cycleMode"];
    }
    
    [defaults setObject:VERSION forKey:@"version"];
}

- (BOOL)written
{
    return [[defaults objectForKey:@"written_to"] boolValue];
}


- (BOOL)displayTodayInSubmenu
{
    return [[defaults objectForKey:@"displayTodayInSubmenu"] boolValue];
}

- (BOOL)displayDayImage
{
    return [[defaults objectForKey:@"displayDayImage"] boolValue];
}

- (BOOL)viewForecastInSubmenu
{
    return [[defaults objectForKey:@"viewForecastInSubmenu"] boolValue];
}

- (int)forecastDaysNumber
{
    return [[defaults objectForKey:@"forecastDaysNumber"] intValue];
}

- (BOOL)forecastDaysOn
{
    return [[defaults objectForKey:@"forecastDaysOn"] boolValue];
}

- (BOOL)forecastInline
{
    return [[defaults objectForKey:@"forecastInline"] boolValue];
}

- (NSColor *)tempColor
{
    return UNARC([defaults objectForKey:@"tempColor"]);
}

- (NSString *)tempFont
{
    return [defaults objectForKey:@"tempFont"];
}

- (BOOL)hideCF
{
    return [[defaults objectForKey:@"hideCF"] boolValue];
}

- (BOOL)displayTemp
{
    return [[defaults objectForKey:@"displayTemp"] boolValue];
}

- (float)imageOpacity
{
    return [[defaults objectForKey:@"imageOpacity"] floatValue];
}

- (BOOL)displayInDock
{
    NSString *plistPath = [NSString stringWithFormat:@"%@/%@",[[[NSBundle mainBundle] resourcePath] stringByDeletingLastPathComponent],@"Info.plist"];
    NSMutableDictionary *infoPlist = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    
    return ![[infoPlist objectForKey:@"NSUIElement"] intValue];
}

- (BOOL)displayInMenubar
{
    return [[defaults objectForKey:@"displayInMenubar"] boolValue];
}

- (BOOL)displayInDockAndMenuBar
{
    return ([self displayInDock] && [self displayInMenubar]);
}

- (BOOL)displayCityName
{
    return [[defaults objectForKey:@"displayCityName"] boolValue];
}

- (BOOL)displayMenuIcon
{
    return [[defaults objectForKey:@"displayMenuIcon"] boolValue];
}

- (NSString *)menuFontName
{
    return [defaults objectForKey:@"menuFontName"];
}

- (NSColor *)menuColor
{
    return UNARC([defaults objectForKey:@"menuColor"]);
}

- (int)menuFontSize
{
    return [[defaults objectForKey:@"menuFontSize"] intValue];
}

- (int)cycleMode
{
    return [[defaults objectForKey:@"cycleMode"] intValue];
}

- (int)autoUpdateTime
{
    return [[defaults objectForKey:@"autoUpdateTime"] intValue];
}

- (int)cycleUpdateTime
{
    return [[defaults objectForKey:@"cycleUpdateTime"] intValue];
}

- (int)changeUpdateTime
{
    return [[defaults objectForKey:@"changeUpdateTime"] intValue];
}

- (BOOL)checkNewServerErrors
{
    return [[defaults objectForKey:@"checkNewServerErrors"] boolValue];
}

- (BOOL)checkNewVersions
{
    return [[defaults objectForKey:@"checkNewServerErrors"] boolValue];
}

- (BOOL)useGlobalUnits
{
    return [[defaults objectForKey:@"useGlobalUnits"] boolValue];
}

- (BOOL)embedControls
{
    return [[defaults objectForKey:@"embedControls"] boolValue];
}

- (NSString *)degreeUnits
{
    return [defaults objectForKey:@"degreeUnits"];
}

- (int)isMetric
{
	return [[self degreeUnits] isEqualToString:@"Celsius"];
}

- (NSString *)speedUnits
{
    return [defaults objectForKey:@"speedUnits"];
}

- (NSString *)distanceUnits
{
    return [defaults objectForKey:@"distanceUnits"];
}

- (NSString *)pressureUnits
{
    return [defaults objectForKey:@"pressureUnits"];
}

- (int)alertOptions
{
    return [[defaults objectForKey:@"alertOptions"] intValue];
}

- (NSString *)alertEmail
{
    return [defaults objectForKey:@"alertEmail"];
}

- (NSString *)alertSong
{
    return [defaults objectForKey:@"alertSong"];
}

- (BOOL)killOtherMeteo
{
    return [[defaults objectForKey:@"killOtherMeteo"] boolValue];
}

NSArray *allFonts()
{
    return [[[NSFontManager sharedFontManager] availableFonts] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)deactivateInterface
{
    [updateProgress startAnimation:nil];

    updatingMenu = YES;
    shouldActivateApply = [applyButton isEnabled];
    shouldActivateReset = [resetButton isEnabled];
    shouldActivateRevert = [revertButton isEnabled];
    
    [applyButton setEnabled:NO];
    [resetButton setEnabled:NO];
    [revertButton setEnabled:NO];
}

- (void)activateInterface
{
    updatingMenu = NO;
    [applyButton setEnabled:shouldActivateApply];
    [resetButton setEnabled:shouldActivateReset];
    [revertButton setEnabled:shouldActivateRevert];

	[updateProgress setStyle: NSProgressIndicatorSpinningStyle];
    [updateProgress stopAnimation:nil];
}


// JRC
- (void)textDidChange:(NSNotification *)notification
{
	if ([[notification object] intValue] > 0)
		[self outletAction:self];
}
@end
