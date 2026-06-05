//
//  all.h
//  img4tool
//
//  Created by tihmstar on 15.06.16.
//  Copyright © 2016 tihmstar. All rights reserved.
//

#ifndef all_h
#define all_h

#define error(a ...) printf("[Error] %s: ",__func__),printf(a)
#define warning(a ...) printf("[Warning] %s: ",__func__),printf(a)

#define IMG4TOOL_VERSION_COMMIT_COUNT "Debug"
#define IMG4TOOL_VERSION_COMMIT_SHA "Build: " __DATE__ " " __TIME__
#define HAVE_LIBCOMPRESSION
#define IMG4TOOL_NOOPENSSL

#endif /* all_h */
