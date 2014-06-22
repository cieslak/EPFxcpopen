//
//  main.m
//  xcpopen
//
//  Created by Chris Cieslak on 6/22/14.
//  Copyright (c) 2014 Electropuf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

void openProject(NSString *path, NSString *xcodePath) {
    if ([[path pathExtension] isEqualToString:@"xcodeproj"] || [[path pathExtension] isEqualToString:@"xcworkspace"]) {
        if (xcodePath) {
            [[NSWorkspace sharedWorkspace] openFile:path withApplication:xcodePath];
        } else {
            [[NSWorkspace sharedWorkspace] openFile:path];
        }
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSArray *args = [[NSProcessInfo processInfo] arguments];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *directoryToSearch = [fileManager currentDirectoryPath];
        
        NSString *xcodePath = nil;
        BOOL deep = NO;
        for (NSInteger i = 0; i < argc; i++) {
            NSString *arg = args[i];
            if ([arg isEqualToString:@"--help"] || [arg isEqualToString:@"-h"]) {
                printf("Usage: xcpopen [options]\n\n");
                printf("Options:\n\n");
                printf("--help -h           Print this help message.\n");
                printf("--directory -d path Open projects in this directory.\n");
                printf("--enumerate -e      Deeply enumerate through directory and open all projects.\n");
                printf("--xcode -x path     Open projects using Xcode path supplied.\n\n");
                exit(0);
            }
            if ([arg isEqualToString:@"--enumerate"] || [arg isEqualToString:@"-e"]) {
                deep = YES;
            }
            if ([arg isEqualToString:@"--xcode"] || [arg isEqualToString:@"-x"]) {
                if (i == argc - 1) {
                    printf("Error: no Xcode path supplied\n");
                    exit(1);
                }
                xcodePath = args[i + 1];
                if (![[xcodePath pathExtension] isEqualToString:@"app"]) {
                    xcodePath = [xcodePath stringByAppendingPathExtension:@"app"];
                }
                if (![fileManager fileExistsAtPath:xcodePath]) {
                    printf("Error: Xcode path supplied does not exist.\n");
                    exit(1);
                }
            }
            if ([arg isEqualToString:@"--directory"] || [arg isEqualToString:@"-d"]) {
                if (i == argc - 1) {
                    printf("Error: no directory path supplied\n");
                    exit(1);
                }
                directoryToSearch = args[i + 1];
                BOOL *isDirectory = NO;
                if (![fileManager fileExistsAtPath:directoryToSearch isDirectory:isDirectory]) {
                    printf("Error: Directory path does not exist\n");
                    exit(1);
                }
            }
        }
        
        if (deep) {
            NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:directoryToSearch];
            if (!enumerator) {
                printf("Error getting contents of directory.\n");
                exit(1);
            }
            NSString *path = nil;
            while ([enumerator nextObject]) {
                openProject(path, xcodePath);
            }
        } else {
            NSError *error = nil;
            NSArray *paths = [fileManager contentsOfDirectoryAtPath:directoryToSearch error:&error];
            if (!paths) {
                printf("Error getting contents of directory: %s\n", [[error localizedDescription] UTF8String]);
                exit(1);
            }
            for (NSString *path in paths) {
                openProject(path, xcodePath);
            }
        }
        
        return 0;
    }
}
