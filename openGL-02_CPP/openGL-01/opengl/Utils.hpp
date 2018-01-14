//
//  Utils.hpp
//  openGL-01
//
//  Created by DFD on 2018/1/14.
//  Copyright © 2018年 DFD. All rights reserved.
//

#ifndef Utils_hpp
#define Utils_hpp

#include <stdio.h>
#include <OpenGLES/ES2/glext.h>

// 编译shader
GLuint CompileShader(GLenum shaderType, const char*code);

// 创建program
GLuint CreateGPUProgram(const char* vsCode, const char* fscode);

// 创建buffer对象
GLuint CreateBufferObject(GLenum objType, int objSize, void *data, GLenum usage);

// 加载项目中的文件
unsigned char* LoadAssetContent(const char* path);

#endif /* Utils_hpp */
