
#define F float
#define F2 float2
#define F4 float4
__kernel void convert_to_S4_C1_D0(
__global const int* restrict srcMat,
__global uchar* dstMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
F alpha,
F beta)
{
int x=get_global_id(0)<<2;
int y=get_global_id(1);
int off_src = (dstoffset_in_pixel & 3);
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel - off_src);
int dst_addr_start = mad24(y,dstStep_in_pixel,dstoffset_in_pixel);
int dst_addr_end = mad24(y,dstStep_in_pixel,cols+dstoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel & (int)0xfffffffc);
if(x+3<cols && y<rows && off_src==0)
{
float4 temp_src = convert_float4(vload4(0,srcMat+srcidx));
*(__global uchar4*)(dstMat+dstidx) = convert_uchar4_sat(temp_src*(F4)alpha+(F4)beta);
}
else
{
if(x+3<cols && y<rows)
{
float4 temp_src = convert_float4(vload4(0,srcMat+srcidx));
uchar4 temp_dst = convert_uchar4_sat(temp_src*(F4)alpha+(F4)beta);
dstMat[dstidx] = temp_dst.x;
dstMat[dstidx+1] = temp_dst.y;
dstMat[dstidx+2] = temp_dst.z;
dstMat[dstidx+3] = temp_dst.w;
}
else if(x+2<cols && y<rows)
{
float4 temp_src = convert_float4(vload4(0,srcMat+srcidx));
uchar4 temp_dst = convert_uchar4_sat(temp_src*(F4)alpha+(F4)beta);
dstMat[dstidx] = temp_dst.x;
dstMat[dstidx+1] = temp_dst.y;
dstMat[dstidx+2] = temp_dst.z;
}
else if(x+1<cols && y<rows)
{
float2 temp_src = convert_float2(vload2(0,srcMat+srcidx));
uchar2 temp_dst = convert_uchar2_sat(temp_src*(F2)alpha+(F2)beta);
dstMat[dstidx] = temp_dst.x;
dstMat[dstidx+1] = temp_dst.y;
}
else if(x<cols && y<rows)
{
dstMat[dstidx] = convert_uchar_sat(convert_float(srcMat[srcidx])*alpha+beta);;
}
}
}
__kernel void convert_to_S4_C4_D0(
__global const int4* restrict srcMat,
__global uchar4* dstMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
F alpha,
F beta)
{
int x=get_global_id(0);
int y=get_global_id(1);
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel);
if ( (x < cols) & (y < rows) )
{
float4 temp_src = convert_float4(srcMat[srcidx]);
dstMat[dstidx] = convert_uchar4_sat(temp_src*alpha+beta);
}
}
__kernel void convert_to_S5_C1_D0(
__global const float* restrict srcMat,
__global uchar* dstMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
F alpha,
F beta)
{
int x=get_global_id(0)<<2;
int y=get_global_id(1);
int off_src = (dstoffset_in_pixel & 3);
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel - off_src);
int dst_addr_start = mad24(y,dstStep_in_pixel,dstoffset_in_pixel);
int dst_addr_end = mad24(y,dstStep_in_pixel,cols+dstoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel & (int)0xfffffffc);
if(x+3<cols && y<rows && off_src==0)
{
float4 temp_src = vload4(0,srcMat+srcidx);
*(__global uchar4*)(dstMat+dstidx) = convert_uchar4_sat(temp_src*(F4)alpha+(F4)beta);
}
else
{
if(x+3<cols && y<rows)
{
float4 temp_src = vload4(0,srcMat+srcidx);
uchar4 temp_dst = convert_uchar4_sat(temp_src*(F4)alpha+(F4)beta);
dstMat[dstidx] = temp_dst.x;
dstMat[dstidx+1] = temp_dst.y;
dstMat[dstidx+2] = temp_dst.z;
dstMat[dstidx+3] = temp_dst.w;
}
else if(x+2<cols && y<rows)
{
float4 temp_src = vload4(0,srcMat+srcidx);
uchar4 temp_dst = convert_uchar4_sat(temp_src*(F4)alpha+(F4)beta);
dstMat[dstidx] = temp_dst.x;
dstMat[dstidx+1] = temp_dst.y;
dstMat[dstidx+2] = temp_dst.z;
}
else if(x+1<cols && y<rows)
{
float2 temp_src = vload2(0,srcMat+srcidx);
uchar2 temp_dst = convert_uchar2_sat(temp_src*(F2)alpha+(F2)beta);
dstMat[dstidx] = temp_dst.x;
dstMat[dstidx+1] = temp_dst.y;
}
else if(x<cols && y<rows)
{
dstMat[dstidx] = convert_uchar_sat(srcMat[srcidx]*alpha+beta);;
}
}
}
__kernel void convert_to_S5_C4_D0(
__global const float4* restrict srcMat,
__global uchar4* dstMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
F alpha,
F beta)
{
int x=get_global_id(0);
int y=get_global_id(1);
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel);
if ( (x < cols) & (y < rows) )
{
float4 temp_src = srcMat[srcidx];
dstMat[dstidx] = convert_uchar4_sat(temp_src*alpha+beta);
}
}
__kernel void convert_to_S0_C1_D4(
__global const uchar* restrict srcMat,
__global int* dstMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
F alpha,
F beta)
{
int x=get_global_id(0);
int y=get_global_id(1);
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel);
if ( (x < cols) & (y < rows) )
{
float temp_src = convert_float(srcMat[srcidx]);
dstMat[dstidx] = convert_int_sat(temp_src*alpha+beta);
}
}
__kernel void convert_to_S5_C1_D4(
__global const float* restrict srcMat,
__global int* dstMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
F alpha,
F beta)
{
int x=get_global_id(0);
int y=get_global_id(1);
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel);
if ( (x < cols) & (y < rows) )
{
float temp_src = srcMat[srcidx];
dstMat[dstidx] = convert_int_sat(temp_src*alpha+beta);
}
}
__kernel void convert_to_S0_C4_D4(
__global const uchar4* restrict srcMat,
__global int4* dstMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
F alpha,
F beta)
{
int x=get_global_id(0);
int y=get_global_id(1);
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel);
if ( (x < cols) & (y < rows) )
{
float4 temp_src = convert_float4(srcMat[srcidx]);
dstMat[dstidx] = convert_int4_sat(temp_src*alpha+beta);
}
}
__kernel void convert_to_S5_C4_D4(
__global const float4* restrict srcMat,
__global int4* dstMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
F alpha,
F beta)
{
int x=get_global_id(0);
int y=get_global_id(1);
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel);
if ( (x < cols) & (y < rows) )
{
float4 temp_src = srcMat[srcidx];
dstMat[dstidx] = convert_int4_sat(temp_src*alpha+beta);
}
}
__kernel void convert_to_S0_C1_D5(
__global const uchar* restrict srcMat,
__global float* dstMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
F alpha,
F beta)
{
int x=get_global_id(0);
int y=get_global_id(1);
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel);
if ( (x < cols) & (y < rows) )
{
float temp_src = convert_float(srcMat[srcidx]);
dstMat[dstidx] = temp_src*alpha+beta;
}
}
__kernel void convert_to_S4_C1_D5(
__global const int* restrict srcMat,
__global float* dstMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
F alpha,
F beta)
{
int x=get_global_id(0);
int y=get_global_id(1);
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel);
if ( (x < cols) & (y < rows) )
{
float temp_src = convert_float(srcMat[srcidx]);
dstMat[dstidx] = temp_src*alpha+beta;
}
}
__kernel void convert_to_S0_C4_D5(
__global const uchar4* restrict srcMat,
__global float4* dstMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
F alpha,
F beta)
{
int x=get_global_id(0);
int y=get_global_id(1);
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel);
if ( (x < cols) & (y < rows) )
{
float4 temp_src = convert_float4(srcMat[srcidx]);
dstMat[dstidx] = temp_src*alpha+beta;
}
}
__kernel void convert_to_S4_C4_D5(
__global const int4* restrict srcMat,
__global float4* dstMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
F alpha,
F beta)
{
int x=get_global_id(0);
int y=get_global_id(1);
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel);
if ( (x < cols) & (y < rows) )
{
float4 temp_src = convert_float4(srcMat[srcidx]);
dstMat[dstidx] = temp_src*alpha+beta;
}
}

