
#ifdef BORDER_CONSTANT
#define ELEM(i,l_edge,r_edge,elem1,elem2) (i)<(l_edge) | (i) >= (r_edge) ? (elem1) : (elem2)
#endif
#ifdef BORDER_REPLICATE
#define ADDR_L(i,l_edge,r_edge,addr)  (i) < (l_edge) ? (l_edge) : (addr)
#define ADDR_R(i,r_edge,addr)   (i) >= (r_edge) ? (r_edge)-1 : (addr)
#endif
#ifdef BORDER_REFLECT
#define ADDR_L(i,l_edge,r_edge,addr)  (i) < (l_edge) ? -(i)-1 : (addr)
#define ADDR_R(i,r_edge,addr) (i) >= (r_edge) ? -(i)-1+((r_edge)<<1) : (addr)
#endif
#ifdef BORDER_REFLECT_101
#define ADDR_L(i,l_edge,r_edge,addr)  (i) < (l_edge) ? -(i) : (addr)
#define ADDR_R(i,r_edge,addr) (i) >= (r_edge) ? -(i)-2+((r_edge)<<1) : (addr)
#endif
#ifdef BORDER_WRAP
#define ADDR_L(i,l_edge,r_edge,addr)  (i) < (l_edge) ? (i)+(r_edge) : (addr)
#define ADDR_R(i,r_edge,addr)   (i) >= (r_edge) ?   (i)-(r_edge) : (addr)
#endif
__kernel void copymakeborder
(__global const GENTYPE *src,
__global GENTYPE *dst,
const int dst_cols,
const int dst_rows,
const int src_cols,
const int src_rows,
const int src_step_in_pixel,
const int src_offset_in_pixel,
const int dst_step_in_pixel,
const int dst_offset_in_pixel,
const int top,
const int left,
const GENTYPE val
)
{
int x = get_global_id(0);
int y = get_global_id(1);
int src_x = x-left;
int src_y = y-top;
int src_addr = mad24(src_y,src_step_in_pixel,src_x+src_offset_in_pixel);
int dst_addr = mad24(y,dst_step_in_pixel,x+dst_offset_in_pixel);
int con = (src_x >= 0) && (src_x < src_cols) && (src_y >= 0) && (src_y < src_rows);
if(con)
{
dst[dst_addr] = src[src_addr];
}
else
{
#ifdef BORDER_CONSTANT
if((x<dst_cols) && (y<dst_rows))
{
dst[dst_addr] = val;
}
#else
int s_x,s_y;
s_x= ADDR_L(src_x,0,src_cols,src_x);
s_x= ADDR_R(src_x,src_cols,s_x);
s_y= ADDR_L(src_y,0,src_rows,src_y);
s_y= ADDR_R(src_y,src_rows,s_y);
src_addr=mad24(s_y,src_step_in_pixel,s_x+src_offset_in_pixel);
if((x<dst_cols) && (y<dst_rows))
{
dst[dst_addr] = src[src_addr];
}
#endif
}
}
__kernel void copymakeborder_C1_D0
(__global const uchar *src,
__global uchar *dst,
const int dst_cols,
const int dst_rows,
const int src_cols,
const int src_rows,
const int src_step_in_pixel,
const int src_offset_in_pixel,
const int dst_step_in_pixel,
const int dst_offset_in_pixel,
const int top,
const int left,
const uchar val
)
{
int x = get_global_id(0)<<2;
int y = get_global_id(1);
int src_x = x-left;
int src_y = y-top;
int src_addr = mad24(src_y,src_step_in_pixel,src_x+src_offset_in_pixel);
int dst_addr = mad24(y,dst_step_in_pixel,x+dst_offset_in_pixel);
int con = (src_x >= 0) && (src_x+3 < src_cols) && (src_y >= 0) && (src_y < src_rows);
if(con)
{
uchar4 tmp = vload4(0,src+src_addr);
*(__global uchar4*)(dst+dst_addr) = tmp;
}
else
{
#ifdef BORDER_CONSTANT
if((((src_x<0) && (src_x+3>=0))||(src_x < src_cols) && (src_x+3 >= src_cols)) && (src_y >= 0) && (src_y < src_rows))
{
int4 addr;
uchar4 tmp;
addr.x = ((src_x < 0) || (src_x>= src_cols)) ? 0 : src_addr;
addr.y = ((src_x+1 < 0) || (src_x+1>= src_cols)) ? 0 : (src_addr+1);
addr.z = ((src_x+2 < 0) || (src_x+2>= src_cols)) ? 0 : (src_addr+2);
addr.w = ((src_x+3 < 0) || (src_x+3>= src_cols)) ? 0 : (src_addr+3);
tmp.x = src[addr.x];
tmp.y = src[addr.y];
tmp.z = src[addr.z];
tmp.w = src[addr.w];
tmp.x = (src_x >=0)&&(src_x  < src_cols) ? tmp.x : val;
tmp.y = (src_x+1 >=0)&&(src_x +1 < src_cols) ? tmp.y : val;
tmp.z = (src_x+2 >=0)&&(src_x +2 < src_cols) ? tmp.z : val;
tmp.w = (src_x+3 >=0)&&(src_x +3 < src_cols) ? tmp.w : val;
*(__global uchar4*)(dst+dst_addr) = tmp;
}
else if((x<dst_cols) && (y<dst_rows))
{
*(__global uchar4*)(dst+dst_addr) = (uchar4)val;
}
#else
int4 s_x;
int s_y;
s_x.x= ADDR_L(src_x,0,src_cols,src_x);
s_x.y= ADDR_L(src_x+1,0,src_cols,src_x+1);
s_x.z= ADDR_L(src_x+2,0,src_cols,src_x+2);
s_x.w= ADDR_L(src_x+3,0,src_cols,src_x+3);
s_x.x= ADDR_R(src_x,src_cols,s_x.x);
s_x.y= ADDR_R(src_x+1,src_cols,s_x.y);
s_x.z= ADDR_R(src_x+2,src_cols,s_x.z);
s_x.w= ADDR_R(src_x+3,src_cols,s_x.w);
s_y= ADDR_L(src_y,0,src_rows,src_y);
s_y= ADDR_R(src_y,src_rows,s_y);
int4 src_addr4=mad24((int4)s_y,(int4)src_step_in_pixel,s_x+(int4)src_offset_in_pixel);
if((x<dst_cols) && (y<dst_rows))
{
uchar4 tmp;
tmp.x = src[src_addr4.x];
tmp.y = src[src_addr4.y];
tmp.z = src[src_addr4.z];
tmp.w = src[src_addr4.w];
*(__global uchar4*)(dst+dst_addr) = tmp;
}
#endif
}
}

