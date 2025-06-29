shader_type canvas_item;

// 可调参数
uniform float amplitude = 3.0; 
uniform float speed = 1.5;
uniform float frequency = 8.0;

// 使用内置噪声函数（不需要外部纹理）
float noise(vec2 pos) {
    return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
    // 创建基于位置和时间的噪声
    vec2 pos = VERTEX * 0.01 + vec2(TIME * speed, TIME * speed * 0.7);
    
    // 生成二维噪声
    vec2 noise_value;
    noise_value.x = noise(pos * frequency);
    noise_value.y = noise(pos * frequency + vec2(100.0, 100.0));
    
    // 应用偏移
    vec2 offset = (noise_value - 0.5) * 2.0 * amplitude;
    VERTEX += offset;
}