//
//  LyricXAppDelegate.m
//  LyricX
//
//  Created by Martian on 12-4-3.
//  Copyright 2012 Martian. All rights reserved.
//

#import "LyricXAppDelegate.h"
#import "Constants.h"
@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //Initialize application
    //Start coding at 2012-04-03 10:51 =。=
    //By Martian
    Controller = [[MainController alloc] initWithMenu:AppMenu];
    
    //设置默认配置
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:@Pref_Desktop_Text_Color] == nil) {
        NSData *theData=[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]];
        [userDefaults setObject:theData forKey:@Pref_Desktop_Text_Color];
    }
    
    if ([userDefaults objectForKey:@Pref_Desktop_Background_Color] == nil) {
        NSData *theData=[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0 alpha:0.25]];
        [userDefaults setObject:theData forKey:@Pref_Desktop_Background_Color];
    }
    
    if ([userDefaults floatForKey:@Pref_Lyrics_W] <= 0)
    {
        [userDefaults setInteger:NSScreen.mainScreen.frame.size.width-300 forKey:@Pref_Lyrics_W];
    }
    
    if ([userDefaults objectForKey:@Pref_Enable_Desktop_Lyrics] == nil)
    {
        [userDefaults setBool:YES forKey:@Pref_Enable_Desktop_Lyrics];
        [userDefaults setBool:YES forKey:@Pref_Enable_MenuBar_Lyrics];
    }
	
	if ([userDefaults objectForKey:@Pref_Enable_Auto_Write_Lyrics] == nil)
    {
        [userDefaults setBool:YES forKey:@Pref_Enable_Auto_Write_Lyrics];
    }
}

-(IBAction)OpenAlbumfillerWindow:(id)sender
{
    if (!AlbumfillerWindow)
        AlbumfillerWindow = [[Albumfiller alloc] init];
    else {
        [AlbumfillerWindow.window makeKeyAndOrderFront:self];
        
    }
    
}

-(IBAction)OpenLyricsSearchWindow:(id)sender
{  
    //i think put the init code in app delegate may be a good idea
    SearchWindow = [[LyricsSearchWnd alloc] initWithArtist:Controller.iTunesCurrentTrack.artist initWithTitle:Controller.iTunesCurrentTrack.name];
}

-(IBAction)CopyCurrentLyrics:(id)sender
{
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject: NSStringPboardType] owner:nil];
    [[NSPasteboard generalPasteboard] setString:Controller.CurrentSongLyrics forType: NSStringPboardType];
}


-(IBAction)CopyTotalLRC:(id)sender
{
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject: NSStringPboardType] owner:nil];
    [[NSPasteboard generalPasteboard] setString:Controller.SongLyrics forType: NSStringPboardType];

}

-(IBAction)CopyTotalTextLyrics:(id)sender
{
    NSMutableString *s = [[NSMutableString alloc] init];
    [s setString:@""];
    for (int i = 0; i < [Controller.lyrics count]; i++) {
        [s setString:[s stringByAppendingString:[NSString stringWithFormat:@"%@\n",[[Controller.lyrics objectAtIndex:i] objectForKey:@"Content"]]]];
    }
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject: NSStringPboardType] owner:nil];
    [[NSPasteboard generalPasteboard] setString: s forType: NSStringPboardType];
    [s release];
    
}

-(IBAction)WriteLyricsToiTunes:(id)sender
{
    NSMutableString *s = [[NSMutableString alloc] init];
    [s setString:@""];
    for (int i = 0; i < [Controller.lyrics count]; i++) {
        [s setString:[s stringByAppendingString:[NSString stringWithFormat:@"%@\n",[[Controller.lyrics objectAtIndex:i] objectForKey:@"Content"]]]];
    }

    Controller.iTunesCurrentTrack.lyrics = s;
    [s release];

}

-(IBAction)WriteArtwork:(id)sender
{
    NSString* documentsFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
    NSString* fileName = [NSString stringWithFormat:@"%@ - %@.tiff",Controller.iTunesCurrentTrack.name,Controller.iTunesCurrentTrack.artist];
    NSString* path = [documentsFolder stringByAppendingPathComponent:fileName];

    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];


    NSImage *image = [[NSImage alloc] initWithData:[[[[iTunes currentTrack] artworks] objectAtIndex:0] rawData]];
    
    NSData *imageData = [image TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
    imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
    [imageData writeToFile:path atomically:NO];     
}


-(IBAction)ExportLRC:(id)sender
{
    
    NSString* documentsFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
    NSString* fileName = [NSString stringWithFormat:@"%@ - %@.lrc",Controller.iTunesCurrentTrack.name,Controller.iTunesCurrentTrack.artist];
    
    NSString* path = [documentsFolder stringByAppendingPathComponent:fileName];
    
    [[NSFileManager defaultManager] createFileAtPath:path contents:[Controller.SongLyrics dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

-(IBAction)showPrefsWindow:(id)sender
{
    [[AppPrefsWindowController sharedPrefsWindowController] showWindow:nil];
	(void)sender;
}


- (IBAction)DisabledMenuBarLyrics:(id)sender
{
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@NC_LyricsChanged object:self userInfo:[NSDictionary dictionaryWithObject:@NC_Disabled_MenuBarLyrics forKey:@"Lyrics"]];
    
}

- (IBAction)DisabledDesktopLyrics:(id)sender;
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@NC_LyricsChanged object:self userInfo:[NSDictionary dictionaryWithObject:@NC_Changed_DesktopLyrics forKey:@"Lyrics"]];
}


@end
