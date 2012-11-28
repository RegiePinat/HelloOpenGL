
    attribute vec4 Position; // 1
    attribute vec4 SourceColor; // 2 

    varying vec4 DestinationColor; // 3





    void main(void) 
    {

        DestinationColor = SourceColor; // 4
        gl_Position = Position; // 5
    }



