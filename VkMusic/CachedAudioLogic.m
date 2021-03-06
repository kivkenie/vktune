//
//  CachedAudioLogic.m
//  VkMusic
//
//  Created by keepcoder on 29.03.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "CachedAudioLogic.h"
#import "AppDelegate.h"
#import "AudioLogic.h"
#import "RecommendsAudio.h"
#import "NSMutableArray+Shuffler.h"
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
@implementation CachedAudioLogic
@synthesize controller;
-(id)init {
    self = [super init];
    if(self) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CachedAudio" inManagedObjectContext:[[self appDelegate] managedObjectContext]];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];
            request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"aid" ascending:NO]];
           
            controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[[self appDelegate] managedObjectContext] sectionNameKeyPath:nil cacheName:@"CachedAudio"];
            controller.delegate = self;
            if([controller performFetch:nil]) {
                
                self.fullList = controller.fetchedObjects.mutableCopy;
                [self updateAudioMap];
              //  [self updateAll];
                [self updateList:[[AudioLogic instance] list]];
               
            }
    }
    return self;
}

-(void)updateAll {
    for (CachedAudio *audio in self.fullList) {
        audio.state = AUDIO_SAVED;
    }
}

-(BOOL)isExists:(Audio *)audio {
    NSString* file = [DOCUMENTS_FOLDER stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d_%d.mp3", DOCUMENTS_FOLDER, [audio.owner_id integerValue], [audio.aid integerValue]]];
    return [[NSFileManager defaultManager] fileExistsAtPath:file];
}


-(void)controllerDidChangeContent:(NSFetchedResultsController *)_controller {
    self.fullList = [_controller.fetchedObjects mutableCopy];
   // [self updateAll];
    [self updateAudioMap];
    [self updateContent:YES];
    [[AlbumsLogic instance] updateAudioMap];
}


-(NSArray *)list {
    NSArray *full = self.searchList != nil ? self.searchList: self.fullList;
    return full;
}


-(void)deleteAudio:(Audio *)audio callback:(voidCallback)callback {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [NSString stringWithFormat:@"%@/%d_%d.mp3", DOCUMENTS_FOLDER, [audio.owner_id integerValue], [audio.aid integerValue]];
        [fileManager removeItemAtPath:path error:NULL];
        CachedAudio *cached = (CachedAudio *) [self findAudio:[audio.aid integerValue] ownerId:[audio.owner_id integerValue]];
        [[AudioLogic instance] findAudio:[audio.aid integerValue] ownerId:[audio.owner_id integerValue]].state = AUDIO_DEFAULT;
        [[RecommendsAudio instance] findAudio:[audio.aid integerValue] ownerId:[audio.owner_id integerValue]].state = AUDIO_DEFAULT;
        callback();
        [self deleteFromSearch:audio];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:[[self appDelegate] managedObjectContext]];
        [[controller managedObjectContext] deleteObject:cached];
        [[controller managedObjectContext] save:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:[[self appDelegate] managedObjectContext]];
        
    });
}

-(BOOL) search:(NSString *)input {
    return [super search:input fullList:self.fullList];
}

-(void)contextDidSave:(NSNotification*)saveNotification {
    NSManagedObjectContext *context = [controller managedObjectContext];
    [context mergeChangesFromContextDidSaveNotification:saveNotification];
}

-(void)updateList:(NSArray *)list {
    for (Audio *audio in list) {
        if([self findAudio:[audio.aid integerValue] ownerId:[audio.owner_id integerValue]]) {
            audio.state = AUDIO_SAVED;
        }
    }
}


-(void)setAlbum:(Audio *)audio albumId:(NSInteger)albumId {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[[self appDelegate] managedObjectContext]];
    CachedAudio *cached = (CachedAudio *) [self findAudio:[audio.aid integerValue] ownerId:[audio.owner_id integerValue]];
    [cached willChangeValueForKey:@"album_id"];
    cached.album_id = [NSNumber numberWithInt:albumId];
    [cached didChangeValueForKey:@"album_id"];
    [[controller managedObjectContext] save:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:[[self appDelegate] managedObjectContext]];
}

-(void)updateAlbum:(NSInteger)album {
    [super updateAlbum:album];
    [self updateContent:YES];
}



-(void)createCachedFromAudio:(Audio *)audio {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[[self appDelegate] managedObjectContext]];
    CachedAudio *cached = [NSEntityDescription insertNewObjectForEntityForName:@"CachedAudio" inManagedObjectContext:[[self appDelegate] managedObjectContext]];
    cached.aid = audio.aid;
    cached.artist = audio.artist;
    cached.title = audio.title;
    cached.duration = audio.duration;
    cached.owner_id = audio.owner_id;
    cached.album_id = [NSNumber numberWithInt:-1];
    cached.state = AUDIO_SAVED;
    [[AudioLogic instance] findAudio:[cached.aid integerValue] ownerId:[cached.owner_id integerValue]].state = cached.state;
    [[FriendsLogic instance] findAudio:[cached.aid integerValue] ownerId:[cached.owner_id integerValue]].state = cached.state;
    [[RecommendsAudio instance] findAudio:[audio.aid integerValue] ownerId:[audio.owner_id integerValue]].state = cached.state;
    [[[self appDelegate] managedObjectContext] save:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:[[self appDelegate] managedObjectContext]];
}


-(AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+(CachedAudioLogic *) instance {
    static CachedAudioLogic *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CachedAudioLogic alloc] init];
        instance.global = NO;
    });
    return instance;
}

@end
