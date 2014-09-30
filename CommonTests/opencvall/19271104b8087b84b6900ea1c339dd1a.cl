
__kernel void bilateral_C1_D0(__global uchar *dst,
__global const uchar *src,
const int dst_rows,
const int dst_cols,
const int maxk,
const int radius,
const int dst_step,
const int dst_offset,
const int src_step,
const int src_rows,
const int src_cols,
__constant float *color_weight,
__constant float *space_weight,
__constant int *space_ofs)
{
int gidx = get_global_id(0);
int gidy = get_global_id(1);
if((gidy<dst_rows) && (gidx<dst_cols))
{
int src_addr = mad24(gidy+radius,src_step,gidx+radius);
int dst_addr = mad24(gidy,dst_step,gidx+dst_offset);
float sum = 0.f, wsum = 0.f;
int val0 = (int)src[src_addr];
for(int k = 0; k < maxk; k++ )
{
int val = (int)src[src_addr + space_ofs[k]];
float w = space_weight[k]*color_weight[abs(val - val0)];
sum += (float)(val)*w;
wsum += w;
}
dst[dst_addr] = convert_uchar_rtz(sum/wsum+0.5f);
}
}
__kernel void bilateral2_C1_D0(__global uchar *dst,
__global const uchar *src,
const int dst_rows,
const int dst_cols,
const int maxk,
const int radius,
const int dst_step,
const int dst_offset,
const int src_step,
const int src_rows,
const int src_cols,
__constant float *color_weight,
__constant float *space_weight,
__constant int *space_ofs)
{
int gidx = get_global_id(0)<<2;
int gidy = get_global_id(1);
if((gidy<dst_rows) && (gidx<dst_cols))
{
int src_addr = mad24(gidy+radius,src_step,gidx+radius);
int dst_addr = mad24(gidy,dst_step,gidx+dst_offset);
float4 sum = (float4)(0.f), wsum = (float4)(0.f);
int4 val0 = convert_int4(vload4(0,src+src_addr));
for(int k = 0; k < maxk; k++ )
{
int4 val = convert_int4(vload4(0,src+src_addr + space_ofs[k]));
float4 w = (float4)(space_weight[k])*(float4)(color_weight[abs(val.x - val0.x)],color_weight[abs(val.y - val0.y)],color_weight[abs(val.z - val0.z)],color_weight[abs(val.w - val0.w)]);
sum += convert_float4(val)*w;
wsum += w;
}
*(__global uchar4*)(dst+dst_addr) = convert_uchar4_rtz(sum/wsum+0.5f);
}
}
__kernel void bilateral_C4_D0(__global uchar4 *dst,
__global const uchar4 *src,
const int dst_rows,
const int dst_cols,
const int maxk,
const int radius,
const int dst_step,
const int dst_offset,
const int src_step,
const int src_rows,
const int src_cols,
__constant float *color_weight,
__constant float *space_weight,
__constant int *space_ofs)
{
int gidx = get_global_id(0);
int gidy = get_global_id(1);
if((gidy<dst_rows) && (gidx<dst_cols))
{
int src_addr = mad24(gidy+radius,src_step,gidx+radius);
int dst_addr = mad24(gidy,dst_step,gidx+dst_offset);
float4 sum = (float4)0.f;
float wsum = 0.f;
int4 val0 = convert_int4(src[src_addr]);
for(int k = 0; k < maxk; k++ )
{
int4 val = convert_int4(src[src_addr + space_ofs[k]]);
float w = space_weight[k]*color_weight[abs(val.x - val0.x)+abs(val.y - val0.y)+abs(val.z - val0.z)];
sum += convert_float4(val)*(float4)w;
wsum += w;
}
wsum=1.f/wsum;
dst[dst_addr] = convert_uchar4_rtz(sum*(float4)wsum+(float4)0.5f);
}
}

