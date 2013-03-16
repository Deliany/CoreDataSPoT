//
//  Photo+Flickr.m
//  CoreDataSPoT
//
//  Created by Deliany Delirium on 16.03.13.
//  Copyright (c) 2013 Clear Sky. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"
#import "Tag+Create.h"
#import "NetworkActivityIndicatorManager.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    // Build a fetch request to see if we can find this Flickr photo in the database.
    // The "unique" attribute in Photo is Flickr's "id" which is guaranteed by Flickr to be unique.
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", [photoDictionary[FLICKR_PHOTO_ID] description]];
    
    // Execute the fetch
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Check what happened in the fetch
    
    if (!matches || ([matches count] > 1)) {  // nil means fetch failed; more than one impossible (unique!)
        // handle error
    } else if (![matches count]) { // none found, so let's create a Photo for that Flickr photo
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.identifier = [photoDictionary[FLICKR_PHOTO_ID] description];
        photo.title = [photoDictionary[FLICKR_PHOTO_TITLE] description];
        photo.shortInfo = [[photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
        photo.urlLarge = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.urlOriginal = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatOriginal] absoluteString];
        photo.urlThumbnail = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        
        NSURL *thumbnailUrl = [FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare];
        
        [NetworkActivityIndicatorManager networkActivityIndicatorShouldShow];
        NSData *thumbnailImage = [[NSData alloc] initWithContentsOfURL:thumbnailUrl];
        [NetworkActivityIndicatorManager networkActivityIndicatorShouldHide];
        
        photo.imageThumbnail = thumbnailImage;
         
        
        NSMutableArray *tags = [[FlickrFetcher tagsForPhoto:photoDictionary] mutableCopy];
        NSArray *excludedTags = @[@"cs193pspot",@"portrait",@"landscape"];
        [tags removeObjectsInArray:excludedTags];
        for (int i = 0; i < [tags count]; ++i) {
            tags[i] = [Tag tagWithName:tags[i] inManagedObjectContext:context];
        }
        photo.tags = [NSSet setWithArray:tags];
        NSString *photographerName = [photoDictionary[FLICKR_PHOTO_OWNER] description];
        Photographer *photographer = [Photographer photographerWithName:photographerName inManagedObjectContext:context];
        photo.owner = photographer;
    } else { // found the Photo, just return it from the list of matches (which there will only be one of)
        photo = [matches lastObject];
    }
    
    return photo;
}

@end
