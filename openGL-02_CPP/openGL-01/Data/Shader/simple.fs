

// 指定float精度
precision mediump float;

// 声明一个变量，方便CPU调用
uniform vec4 U_Color;

void main()
{
    gl_FragColor = U_Color;
}
