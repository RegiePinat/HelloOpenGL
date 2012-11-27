//
//  HelloOpenGLAppDelegate.h
//  HelloOpenGL
//
//  Created by Regie G. Pinat on 11/27/12.
//  Copyright (c) 2012 Regie G. Pinat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@interface HelloOpenGLAppDelegate : UIResponder <UIApplicationDelegate>
{
    OpenGLView* _glView;
    

}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet OpenGLView *glView;
@end
