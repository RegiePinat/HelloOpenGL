//
//  OpenGLView.h
//  HelloOpenGL
//
//  Created by Regie G. Pinat on 11/27/12.
//  Copyright (c) 2012 Regie G. Pinat. All rights reserved.
//

#import <UIKit/UIKit.h>

//three important library in using OpenGLES
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>







@interface OpenGLView : UIView
{
    //Necessary Vars used to initialize openGL
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;  
    
    
    //variable for shader manupulation -- vertices[]
    GLuint _positionSlot;
    GLuint _colorSlot;
    

}

//initial view
- (void)setupLayer;
- (void)setupContext;
- (void)setupRenderBuffer;
- (void)setupFrameBuffer;
//Render object
- (void)render;

//Compile Shaders
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType;
- (void)compileShaders;

//Setup Buffer object for vertices and other geometric objects
- (void)setupVBOs;
@end


