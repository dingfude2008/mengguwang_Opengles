//
//  GameViewController.m
//  openGL-01
//
//  Created by DFD on 2017/2/9.
//  Copyright © 2017年 DFD. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#import "Utils.hpp"

GLuint vbo, gpuProgram;
GLint posLocation, colorPosition;
float color[] = { 0.4, 0.1, 0.2, 1.0 };

char* LoadAssetContent(const char* path){
    char* assetContent = nullptr;
    NSString *nsPath = [[[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:path] ofType:nil] retain];
    NSData *data = [[NSData dataWithContentsOfFile:nsPath] retain];
    assetContent = new char[[data length] +1];
    memcpy(assetContent, [data bytes], [data length]);
    [nsPath release];
    [data release];
    return assetContent;
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
    
    vbo = CreateBufferObject(GL_ARRAY_BUFFER, sizeof(float) * 9, position, GL_STATIC_DRAW);

    char *vsCode = LoadAssetContent("/Data/Shader/simple.vs");
    char *fsCode = LoadAssetContent("/Data/Shader/simple.fs");
    
    // 创建程序
    gpuProgram = CreateGPUProgram(vsCode, fsCode);
    
    // 把 CPU中的变量和GPU的变量进行映射
    posLocation = glGetAttribLocation(gpuProgram, "pos");
    
    // 从 程序中映射到变量
    colorPosition = glGetUniformLocation(gpuProgram, "U_Color");
}



- (void)dealloc
{
    [super dealloc];
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
    
    // 给这个变量赋值，方便传输到vs
    glUniform4fv(colorPosition, 1, color);
    
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
