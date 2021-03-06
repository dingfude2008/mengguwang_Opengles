//
//  GameViewController.m
//  openGL-01
//
//  Created by DFD on 2017/2/9.
//  Copyright © 2017年 DFD. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>

GLuint vbo, gpuProgram;
GLint posLocation;

char *vertexShader = "attribute vec3 pos;\n"
"void main(){\n"
"gl_Position=vec4(pos,1.0);\n"
"}\n";

char *fragmentShader = "void main(){\n"
"gl_FragColor=vec4(1.0);\n"
"}\n";

// 编译 sharder
GLuint CompileShader(GLenum shaderType, const char*code)
{
    // 创建 shader对象 在GPU
    GLuint shader = glCreateShader(shaderType);
    
    // 把 CPU的上源码指向GPU上的 shade对象
    // shader 对象， 编译的个数， 源码指针的指针， 长度
    // glShaderSource(GLuint shader, GLsizei count, const GLchar *const *string, const GLint *length)
    glShaderSource(shader, 1, &code, NULL);
    
    // 编译
    glCompileShader(shader);
    
    // 编译状态
    GLint compileStatus = GL_FALSE;
    
    // 获取编译的状态
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    
    if (compileStatus == GL_FALSE) {
        
        printf("compile shader error, shader code is: %s\n", code);
        
        // 存放Log 默认一个存储大小
        char szBuffer[1024] = {0};
        
        // 日志的实际长度
        GLsizei logLen = 0;
        
        // 获取日志信息
        glGetShaderInfoLog(shader, 1024, &logLen, szBuffer);
        
        printf("error log: %s\n", szBuffer);
        
        glDeleteShader(shader);
        
        return 0;
    }
    
    return shader;
}


// compile code
// link
GLuint CreateGPUProgram(const char* vsCode, const char* fscode)
{
    GLuint program;
    
    GLuint vsShader = CompileShader(GL_VERTEX_SHADER, vsCode);
    GLuint fsShder  = CompileShader(GL_FRAGMENT_SHADER, fscode);
    
    // 创建程序
    program = glCreateProgram();
    
    // 连接 程序 和 shader
    glAttachShader(program, vsShader);
    glAttachShader(program, fsShder);
    
    // 连接到GPU
    glLinkProgram(program);
    
    // 检测是否连接成功
    GLint programStatus = GL_FALSE;
    
    // 获取是否连接成功
    glGetProgramiv(program, GL_LINK_STATUS, &programStatus);
    
    if (programStatus == GL_FALSE){
        
        printf("link program error!");
        
        char szBuffer[1024] = {0};
        GLsizei logLen = 0;
        
        // 获取日志
        glGetProgramInfoLog(program, 1024, &logLen, szBuffer);
        
        printf("link error: %s\n", szBuffer);
        return 0;
    }
   
    return program;
}


@interface GameViewController () {
}
@property (strong, nonatomic) EAGLContext *context;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.context){
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.context];
    
    [self initScene];
}

/*
 
 CPU   ----->   vsh  ------->  fsh
            处理几何点         处理像素点（很大）
 
 一个点 -> 一个核心  一个  attribite
 
 draw compont 处理几何点   -->  告诉 fsh 开始染色
 
 
 
 */

- (void)initScene{
    float position[] = {
        -0.5f,0.0f, 0.0f,
        0.5f, 0.0f, 0.0f,
        0.0f, 0.5f, 0.0f,
    };
    
    // 初始化一个vbo
    glGenBuffers(1, &vbo);
    
    //设置为当前的vbo   --- 状态机， 后面还有设置回来
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    
    // 把CPU上的position的数据 传输给 GPU， 并指定大小， GL_STATIC_DRAW 建议GPU的存储方式
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 9, position, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // 创建程序
    gpuProgram = CreateGPUProgram(vertexShader, fragmentShader);
    
    // 把 CPU中的变量和GPU的变量进行映射
    posLocation = glGetAttribLocation(gpuProgram, "pos");
}



- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    
}


// 先激活 atrribute
//glEnableVertexAttribArray(vbo);

/*
 告诉attibute从哪里取值
 indx          激活的 attribute
 size          有多少个分量
 type          是什么类型
 normalized    需要不需要归一化， 就是是否需要转为 float   （如果 传入的是 byte , short 类型  就需要设置的 Gltrue）
 stride        两个点之间的间距
 ptr           从何处取值
 
 */
// glVertexAttribPointer(GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid *ptr)

/*
 激活一个 attribute
 glenable
 glVertexAttribPointer
 */

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.1f, 0.4f, 0.6f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // draw compont
    
    // draw call   --> 简称dc
    // select program  选择程序
    // set up args     设置参数
    // invoke          运行
    
    glUseProgram(gpuProgram);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    
    // 启动
    glEnableVertexAttribArray(posLocation);
    
    // 指定
    // 指定变量
    // 多少个点（分量）
    // 分量的类型
    // 是否归一化
    // 相邻两个分量的间隔 （因为数组中可能是混合放的， position, color, position...）
    // 在 vbo中的起始索引 (第一个的索引， 比如 position, color,如果指定color 就是1 )
    glVertexAttribPointer(posLocation, 3, GL_FLOAT, GL_FALSE, sizeof(float) * 3, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // 渲染到GPU，
    // 类型(三角形)
    // 第一个的索引
    // 个数
    // glDrawArrays(GLenum mode, GLint first, GLsizei count)
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    // 回复状态机
    glUseProgram(0);
    
    
    
    
}


@end
