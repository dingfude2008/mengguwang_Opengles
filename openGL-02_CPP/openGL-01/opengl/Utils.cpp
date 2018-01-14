//
//  Utils.cpp
//  openGL-01
//
//  Created by DFD on 2018/1/14.
//  Copyright © 2018年 DFD. All rights reserved.
//

#include "Utils.hpp"

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

// 创建buffer对象
GLuint CreateBufferObject(GLenum objType, int objSize, void *data, GLenum usage){
    
    GLuint bufferObject;
    
    // 初始化一个vbo
    glGenBuffers(1, &bufferObject);
    
    
    //设置为当前的vbo   --- 状态机， 后面还有设置回来
    glBindBuffer(GL_ARRAY_BUFFER, bufferObject);
    
    // 把CPU上的position的数据 传输给 GPU， 并指定大小， GL_STATIC_DRAW 建议GPU的存储方式
    glBufferData(GL_ARRAY_BUFFER, objSize, data, usage);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
//    //设置为当前的vbo   --- 状态机， 后面还有设置回来
//    glBindBuffer(objType, bufferObject);
//    
//    // 把CPU上的position的数据 传输给 GPU， 并指定大小， GL_STATIC_DRAW 建议GPU的存储方式
//    glBufferData(objType, objSize, data, usage);
//    
//    glBindBuffer(objType, 0);
    
    return bufferObject;
}







