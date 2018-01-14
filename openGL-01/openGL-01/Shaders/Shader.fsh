//
//  Shader.fsh
//  openGL-01
//
//  Created by DFD on 2017/2/9.
//  Copyright © 2017年 DFD. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
