// https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson5
float4 gaussianBlur(float2 dir, float4 grabPos, float res, sampler2D tex, float radius)
{
    //this will be our RGBA sum
    float4 sum = float4(0, 0, 0, 0);
    
    //the amount to blur, i.e. how far off center to sample from 
    //1.0 -> blur by one pixel
    //2.0 -> blur by two pixels, etc.
    float blur = radius / res; 
    
    //the direction of our blur
    //(1.0, 0.0) -> x-axis blur
    //(0.0, 1.0) -> y-axis blur
    float hstep = dir.x;
    float vstep = dir.y;
    
    //apply blurring, using a 9-tap filter with predefined gaussian weights
    
    sum += tex2Dproj(tex, float4(grabPos.x - 4*blur*hstep, grabPos.y - 4.0*blur*vstep, grabPos.zw)) * 0.0162162162;
    sum += tex2Dproj(tex, float4(grabPos.x - 3.0*blur*hstep, grabPos.y - 3.0*blur*vstep, grabPos.zw)) * 0.0540540541;
    sum += tex2Dproj(tex, float4(grabPos.x - 2.0*blur*hstep, grabPos.y - 2.0*blur*vstep, grabPos.zw)) * 0.1216216216;
    sum += tex2Dproj(tex, float4(grabPos.x - 1.0*blur*hstep, grabPos.y - 1.0*blur*vstep, grabPos.zw)) * 0.1945945946;
    
    sum += tex2Dproj(tex, float4(grabPos.x, grabPos.y, grabPos.zw)) * 0.2270270270;
    
    sum += tex2Dproj(tex, float4(grabPos.x + 1.0*blur*hstep, grabPos.y + 1.0*blur*vstep, grabPos.zw)) * 0.1945945946;
    sum += tex2Dproj(tex, float4(grabPos.x + 2.0*blur*hstep, grabPos.y + 2.0*blur*vstep, grabPos.zw)) * 0.1216216216;
    sum += tex2Dproj(tex, float4(grabPos.x + 3.0*blur*hstep, grabPos.y + 3.0*blur*vstep, grabPos.zw)) * 0.0540540541;
    sum += tex2Dproj(tex, float4(grabPos.x + 4.0*blur*hstep, grabPos.y + 4.0*blur*vstep, grabPos.zw)) * 0.0162162162;

    return float4(sum.rgb, 1.0);
}