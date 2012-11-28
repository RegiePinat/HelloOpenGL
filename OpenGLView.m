//
//  OpenGLView.m
//  HelloOpenGL
//
//  Created by Regie G. Pinat on 11/27/12.
//  Copyright (c) 2012 Regie G. Pinat. All rights reserved.
//

#import "OpenGLView.h"


typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};



@implementation OpenGLView


//TOMORROW STUDY THIS



//SHADER BUffer Object Generate (COMPILE SHADERS External Codes function)
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType
{
    // 1 Get Path of file and convert to string that file
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString)
    {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    
    /*Calls glCreateShader to create a OpenGL object to represent the shader. When you call this function you need to pass in a shaderType to indicate whether it’s a fragment or vertex shader. We take ethis as a parameter to this method.*/
    
    GLuint shaderHandle =  glCreateShader(shaderType);
    
    
    //conver NSString to C-String
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    
    /*Calls glShaderSource to give OpenGL the source code for this shader (if param has ** (pass pointer and put &) or * (pass var and put &))*/
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    //calls glCompileShader to compile the shader at runtime!
    glCompileShader(shaderHandle);
    
    
    /*  This can fail – and it will in practice if your GLSL code has errors in it. When it does fail, it’s useful to get some output messages in terms of what went wrong. This code uses glGetShaderiv and glGetShaderInfoLog to output any error messages to the screen (and quit so you can fix the bug!)
     */
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE)
    {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
        
    }
    
    
    return shaderHandle;
}








//Call - (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType
//create a program then get the pointer of the vertices co that it can be manipulated  
- (void)compileShaders {
    
    // 1  Uses the method you just wrote to compile the vertex and fragment shaders.
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    
    
    
    /* 2 Calls glCreateProgram, glAttachShader, and glLinkProgram to link the vertex and fragment shaders into a complete program.*/
    GLuint programHandle = glCreateProgram();
    //Attch the to two shader
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    //link it
    glLinkProgram(programHandle);
    
    
    
    
    
    
    /* 3 Calls glGetProgramiv and glGetProgramInfoLog to check and see if there were any link errors, and display the output and quit if so.(error checking if linking unsuccessful)*/
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    
    
    // 4  to tell OpenGL to actually use this program when given vertex info
    glUseProgram(programHandle);
    
    
    
    /* 5 Finally, calls glGetAttribLocation to get a pointer to the input values for the vertex shader, so we can set them in code. Also calls glEnableVertexAttribArray to enable use of these arrays (they are disabled by default).*/
    //Para malagyan or set ng value(get pointer)
    
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
}




- (void)setupVBOs {
    
    //Create Vertex Buffer Objects
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}
















- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupVBOs];
        [self render];
    
      
    }
    return self;
}


-(void)dealloc
{
    [_context release];
    _context = nil;
    [super dealloc];
}




//THIS METHODS ARE USED TO SET UP A VIEW FOR OPENGL



//Use to set The layer Class for openGL
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


//set Layer to Opaque
- (void)setupLayer{
    _eaglLayer  = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
}


//set up EAGLContext -An EAGLContext manages all of the information iOS needs to draw with OpenGL
- (void)setupContext
{
    //get context
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context =[[EAGLContext alloc] initWithAPI:api] ;
    
    
     if (!_context)
     {
     NSLog(@"Failed to initialize OpenGLES 2.0 context");
         exit(1);
     }
    
    
    
    //setup context

    if (![EAGLContext setCurrentContext:_context])
    {
    NSLog(@"Failed to set current OpenGL context");
    exit(1);
    }
}


//create a render buffer, which is an OpenGL object that stores the rendered image to present to the screen.
//render buffer also referred to as a color buffer
//used to render Color
- (void)setupRenderBuffer
{
    //return a unique interger and we will save it directly to _colorRenderBuffer so we used '&'
    glGenRenderbuffers(1, &_colorRenderBuffer);
    
    //bind GL_RENDERBUFFER to _colorRenderBuffer = or should i mean alias _colorRenderBuffer as GL_RENDERBUFFER
    //whenever I refer to GL_RENDERBUFFER, I really mean _colorRenderBuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);

  /*  Finally, allocate some storage for the render buffer ..  EAGLContext has a method you can use for this called renderbufferStorage*/
    
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}


/*A frame buffer is an OpenGL object that contains a render buffer, and some other buffers you’ll learn about later such as a depth buffer, stencil buffer, and accumulation buffer.*/

//approximately same for the 2 fucntions in renderbuffer
- (void)setupFrameBuffer
{
GLuint framebuffer;
glGenFramebuffers(1, &framebuffer);   
glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);

    
// It lets you attach the render buffer you created earlier to the frame buffer’s GL_COLOR_ATTACHMENT0 slot.
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
}








//clear Screen
//all other after initwithFram and dealloc( are Used Initalize GLview ) beside this are not change anymore
//you will change this to render objects
- (void)render
{
    //Clear Screen with bacground color
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    
    // 1 Calls glViewport to set the portion of the UIView to use for rendering. This sets it to the entire window, but if you wanted a smallar part you could change these values.
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // 2 Calls glVertexAttribPointer to feed the correct values to the two input variables for the vertex shader – the Position and SourceColor attributes.
    /*
     The first parameter specifies the attribute name to set. We got these earlier when we called glGetAttribLocation.
    
     The second parameter specifies how many values are present for each vertex. If you look back up at the Vertex struct, you’ll see that for the position there are three floats (x,y,z) and for the color there are four floats (r,g,b,a).
    
     The third parameter specifies the type of each value – which is float for both Position and Color.
     
     The fourth parameter is always set to false.
    
     The fifth parameter is the size of the stride, which is a fancy way of saying “the size of the data structure containing the per-vertex data”. So we can simply pass in sizeof(Vertex) here to get the compiler to compute it for us.
     
     The final parameter is the offset within the structure to find this data. The position data is at the beginning of the structure so we can pass 0 here, the color data is after the Position data (which was 3 floats, so we pass 3 * sizeof(float)).
    */
    glVertexAttribPointer(_positionSlot,3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex),0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    
    // 3 Calls glDrawElements to make the magic happen! This actually ends up calling your vertex shader for every vertex you pass in, and then the fragment shader on each pixel to display on the screen.
    /*
     The first parameter specifies the manner of drawing the vertices. There are different options you may come across in other tutorials like GL_LINE_STRIP or GL_TRIANGLE_FAN, but GL_TRIANGLES is the most generically useful (especially when combined with VBOs) so it’s what we cover here.
     The second parameter is the count of vertices to render. We use a C trick to compute the number of elements in an array here by dividing the sizeof(Indices) (which gives us the size of the array in bytes) by sizeof(Indices[0]) (which gives us the size of the first element in the arary).
     The third parameter is the data type of each individual index in the Indices array. We’re using an unsigned byte for that so we specify that here.
     From the documentation, it appears that the final parameter should be a pointer to the indices. But since we’re using VBOs it’s a special case – it will use the indices array we already passed to OpenGL-land in the GL_ELEMENT_ARRAY_BUFFER.
     
     */
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
    
    
    
    //Present Render Buffer
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}






/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/






//METHODS FOR VERTEX AND SHADER












@end



