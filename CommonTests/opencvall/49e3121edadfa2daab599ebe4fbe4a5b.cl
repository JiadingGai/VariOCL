
#define READ_TIMES_ROW ((2*(RADIUSX+LSIZE0)-1)/LSIZE0)
#define READ_TIMES_COL ((2*(RADIUSY+LSIZE1)-1)/LSIZE1)
#define RADIUS 1
#if CN ==1
#define ALIGN (((RADIUS)+3)>>2<<2)
#elif CN==2
#define ALIGN (((RADIUS)+1)>>1<<1)
#elif CN==3
#define ALIGN (((RADIUS)+3)>>2<<2)
#elif CN==4
#define ALIGN (RADIUS)
#endif
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
__kernel __attribute__((reqd_work_group_size(LSIZE0,LSIZE1,1))) void row_filter_C1_D0
(__global const uchar * restrict src,
__global float * dst,
const int dst_cols,
const int dst_rows,
const int src_whole_cols,
const int src_whole_rows,
const int src_step_in_pixel,
const int src_offset_x,
const int src_offset_y,
const int dst_step_in_pixel,
const int radiusy,
__constant float * mat_kernel __attribute__((max_constant_size(4*(2*RADIUSX+1)))))
{
int x = get_global_id(0)<<2;
int y = get_global_id(1);
int l_x = get_local_id(0);
int l_y = get_local_id(1);
int start_x = x+src_offset_x-RADIUSX & 0xfffffffc;
int offset = src_offset_x-RADIUSX & 3;
int start_y = y+src_offset_y-radiusy;
int start_addr = mad24(start_y,src_step_in_pixel,start_x);
int i;
float4 sum;
uchar4 temp[READ_TIMES_ROW];
__local uchar4 LDS_DAT[LSIZE1][READ_TIMES_ROW*LSIZE0+1];
#ifdef BORDER_CONSTANT
int end_addr = mad24(src_whole_rows - 1,src_step_in_pixel,src_whole_cols);
for(i = 0; i<READ_TIMES_ROW; i++)
{
int current_addr = start_addr+i*LSIZE0*4;
current_addr = ((current_addr < end_addr) && (current_addr > 0)) ? current_addr : 0;
temp[i] = *(__global uchar4*)&src[current_addr];
}
for(i = 0; i<READ_TIMES_ROW; i++)
{
temp[i].x= ELEM(start_x+i*LSIZE0*4,0,src_whole_cols,0,temp[i].x);
temp[i].y= ELEM(start_x+i*LSIZE0*4+1,0,src_whole_cols,0,temp[i].y);
temp[i].z= ELEM(start_x+i*LSIZE0*4+2,0,src_whole_cols,0,temp[i].z);
temp[i].w= ELEM(start_x+i*LSIZE0*4+3,0,src_whole_cols,0,temp[i].w);
temp[i]= ELEM(start_y,0,src_whole_rows,(uchar4)0,temp[i]);
}
#else
int not_all_in_range = (start_x<0) | (start_x + READ_TIMES_ROW*LSIZE0*4+4>src_whole_cols)| (start_y<0) | (start_y >= src_whole_rows);
int4 index[READ_TIMES_ROW];
int4 addr;
int s_y;
if(not_all_in_range)
{
for(i = 0; i<READ_TIMES_ROW; i++)
{
index[i].x= ADDR_L(start_x+i*LSIZE0*4,0,src_whole_cols,start_x+i*LSIZE0*4);
index[i].x= ADDR_R(start_x+i*LSIZE0*4,src_whole_cols,index[i].x);
index[i].y= ADDR_L(start_x+i*LSIZE0*4+1,0,src_whole_cols,start_x+i*LSIZE0*4+1);
index[i].y= ADDR_R(start_x+i*LSIZE0*4+1,src_whole_cols,index[i].y);
index[i].z= ADDR_L(start_x+i*LSIZE0*4+2,0,src_whole_cols,start_x+i*LSIZE0*4+2);
index[i].z= ADDR_R(start_x+i*LSIZE0*4+2,src_whole_cols,index[i].z);
index[i].w= ADDR_L(start_x+i*LSIZE0*4+3,0,src_whole_cols,start_x+i*LSIZE0*4+3);
index[i].w= ADDR_R(start_x+i*LSIZE0*4+3,src_whole_cols,index[i].w);
}
s_y= ADDR_L(start_y,0,src_whole_rows,start_y);
s_y= ADDR_R(start_y,src_whole_rows,s_y);
for(i = 0; i<READ_TIMES_ROW; i++)
{
addr = mad24((int4)s_y,(int4)src_step_in_pixel,index[i]);
temp[i].x = src[addr.x];
temp[i].y = src[addr.y];
temp[i].z = src[addr.z];
temp[i].w = src[addr.w];
}
}
else
{
for(i = 0; i<READ_TIMES_ROW; i++)
{
temp[i] = *(__global uchar4*)&src[start_addr+i*LSIZE0*4];
}
}
#endif
for(i = 0; i<READ_TIMES_ROW; i++)
{
LDS_DAT[l_y][l_x+i*LSIZE0]=temp[i];
}
barrier(CLK_LOCAL_MEM_FENCE);
sum =convert_float4(vload4(0,(__local uchar*)&LDS_DAT[l_y][l_x]+RADIUSX+offset))*mat_kernel[RADIUSX];
for(i=1; i<=RADIUSX; i++)
{
temp[0]=vload4(0,(__local uchar*)&LDS_DAT[l_y][l_x]+RADIUSX+offset-i);
temp[1]=vload4(0,(__local uchar*)&LDS_DAT[l_y][l_x]+RADIUSX+offset+i);
sum += convert_float4(temp[0])*mat_kernel[RADIUSX-i]+convert_float4(temp[1])*mat_kernel[RADIUSX+i];
}
start_addr = mad24(y,dst_step_in_pixel,x);
if((x+3<dst_cols) & (y<dst_rows))
{
*(__global float4*)&dst[start_addr] = sum;
}
else if((x+2<dst_cols) & (y<dst_rows))
{
dst[start_addr] = sum.x;
dst[start_addr+1] = sum.y;
dst[start_addr+2] = sum.z;
}
else if((x+1<dst_cols) & (y<dst_rows))
{
dst[start_addr] = sum.x;
dst[start_addr+1] = sum.y;
}
else if((x<dst_cols) & (y<dst_rows))
{
dst[start_addr] = sum.x;
}
}
__kernel __attribute__((reqd_work_group_size(LSIZE0,LSIZE1,1))) void row_filter_C4_D0
(__global const uchar4 * restrict src,
__global float4 * dst,
const int dst_cols,
const int dst_rows,
const int src_whole_cols,
const int src_whole_rows,
const int src_step_in_pixel,
const int src_offset_x,
const int src_offset_y,
const int dst_step_in_pixel,
const int radiusy,
__constant float * mat_kernel __attribute__((max_constant_size(4*(2*RADIUSX+1)))))
{
int x = get_global_id(0);
int y = get_global_id(1);
int l_x = get_local_id(0);
int l_y = get_local_id(1);
int start_x = x+src_offset_x-RADIUSX;
int start_y = y+src_offset_y-radiusy;
int start_addr = mad24(start_y,src_step_in_pixel,start_x);
int i;
float4 sum;
uchar4 temp[READ_TIMES_ROW];
__local uchar4 LDS_DAT[LSIZE1][READ_TIMES_ROW*LSIZE0+1];
#ifdef BORDER_CONSTANT
int end_addr = mad24(src_whole_rows - 1,src_step_in_pixel,src_whole_cols);
for(i = 0; i<READ_TIMES_ROW; i++)
{
int current_addr = start_addr+i*LSIZE0;
current_addr = ((current_addr < end_addr) && (current_addr > 0)) ? current_addr : 0;
temp[i] = src[current_addr];
}
for(i = 0; i<READ_TIMES_ROW; i++)
{
temp[i]= ELEM(start_x+i*LSIZE0,0,src_whole_cols,(uchar4)0,temp[i]);
temp[i]= ELEM(start_y,0,src_whole_rows,(uchar4)0,temp[i]);
}
#else
int index[READ_TIMES_ROW];
int s_x,s_y;
for(i = 0; i<READ_TIMES_ROW; i++)
{
s_x= ADDR_L(start_x+i*LSIZE0,0,src_whole_cols,start_x+i*LSIZE0);
s_x= ADDR_R(start_x+i*LSIZE0,src_whole_cols,s_x);
s_y= ADDR_L(start_y,0,src_whole_rows,start_y);
s_y= ADDR_R(start_y,src_whole_rows,s_y);
index[i]=mad24(s_y,src_step_in_pixel,s_x);
}
for(i = 0; i<READ_TIMES_ROW; i++)
{
temp[i] = src[index[i]];
}
#endif
for(i = 0; i<READ_TIMES_ROW; i++)
{
LDS_DAT[l_y][l_x+i*LSIZE0]=temp[i];
}
barrier(CLK_LOCAL_MEM_FENCE);
sum =convert_float4(LDS_DAT[l_y][l_x+RADIUSX])*mat_kernel[RADIUSX];
for(i=1; i<=RADIUSX; i++)
{
temp[0]=LDS_DAT[l_y][l_x+RADIUSX-i];
temp[1]=LDS_DAT[l_y][l_x+RADIUSX+i];
sum += convert_float4(temp[0])*mat_kernel[RADIUSX-i]+convert_float4(temp[1])*mat_kernel[RADIUSX+i];
}
if((x<dst_cols) & (y<dst_rows))
{
start_addr = mad24(y,dst_step_in_pixel,x);
dst[start_addr] = sum;
}
}
__kernel __attribute__((reqd_work_group_size(LSIZE0,LSIZE1,1))) void row_filter_C1_D5
(__global const float * restrict src,
__global float * dst,
const int dst_cols,
const int dst_rows,
const int src_whole_cols,
const int src_whole_rows,
const int src_step_in_pixel,
const int src_offset_x,
const int src_offset_y,
const int dst_step_in_pixel,
const int radiusy,
__constant float * mat_kernel __attribute__((max_constant_size(4*(2*RADIUSX+1)))))
{
int x = get_global_id(0);
int y = get_global_id(1);
int l_x = get_local_id(0);
int l_y = get_local_id(1);
int start_x = x+src_offset_x-RADIUSX;
int start_y = y+src_offset_y-radiusy;
int start_addr = mad24(start_y,src_step_in_pixel,start_x);
int i;
float sum;
float temp[READ_TIMES_ROW];
__local float LDS_DAT[LSIZE1][READ_TIMES_ROW*LSIZE0+1];
#ifdef BORDER_CONSTANT
int end_addr = mad24(src_whole_rows - 1,src_step_in_pixel,src_whole_cols);
for(i = 0; i<READ_TIMES_ROW; i++)
{
int current_addr = start_addr+i*LSIZE0;
current_addr = ((current_addr < end_addr) && (current_addr > 0)) ? current_addr : 0;
temp[i] = src[current_addr];
}
for(i = 0; i<READ_TIMES_ROW; i++)
{
temp[i]= ELEM(start_x+i*LSIZE0,0,src_whole_cols,(float)0,temp[i]);
temp[i]= ELEM(start_y,0,src_whole_rows,(float)0,temp[i]);
}
#else
int index[READ_TIMES_ROW];
int s_x,s_y;
for(i = 0; i<READ_TIMES_ROW; i++)
{
s_x= ADDR_L(start_x+i*LSIZE0,0,src_whole_cols,start_x+i*LSIZE0);
s_x= ADDR_R(start_x+i*LSIZE0,src_whole_cols,s_x);
s_y= ADDR_L(start_y,0,src_whole_rows,start_y);
s_y= ADDR_R(start_y,src_whole_rows,s_y);
index[i]=mad24(s_y,src_step_in_pixel,s_x);
}
for(i = 0; i<READ_TIMES_ROW; i++)
{
temp[i] = src[index[i]];
}
#endif
for(i = 0; i<READ_TIMES_ROW; i++)
{
LDS_DAT[l_y][l_x+i*LSIZE0]=temp[i];
}
barrier(CLK_LOCAL_MEM_FENCE);
sum =LDS_DAT[l_y][l_x+RADIUSX]*mat_kernel[RADIUSX];
for(i=1; i<=RADIUSX; i++)
{
temp[0]=LDS_DAT[l_y][l_x+RADIUSX-i];
temp[1]=LDS_DAT[l_y][l_x+RADIUSX+i];
sum += temp[0]*mat_kernel[RADIUSX-i]+temp[1]*mat_kernel[RADIUSX+i];
}
if((x<dst_cols) & (y<dst_rows))
{
start_addr = mad24(y,dst_step_in_pixel,x);
dst[start_addr] = sum;
}
}
__kernel __attribute__((reqd_work_group_size(LSIZE0,LSIZE1,1))) void row_filter_C4_D5
(__global const float4 * restrict src,
__global float4 * dst,
const int dst_cols,
const int dst_rows,
const int src_whole_cols,
const int src_whole_rows,
const int src_step_in_pixel,
const int src_offset_x,
const int src_offset_y,
const int dst_step_in_pixel,
const int radiusy,
__constant float * mat_kernel __attribute__((max_constant_size(4*(2*RADIUSX+1)))))
{
int x = get_global_id(0);
int y = get_global_id(1);
int l_x = get_local_id(0);
int l_y = get_local_id(1);
int start_x = x+src_offset_x-RADIUSX;
int start_y = y+src_offset_y-radiusy;
int start_addr = mad24(start_y,src_step_in_pixel,start_x);
int i;
float4 sum;
float4 temp[READ_TIMES_ROW];
__local float4 LDS_DAT[LSIZE1][READ_TIMES_ROW*LSIZE0+1];
#ifdef BORDER_CONSTANT
int end_addr = mad24(src_whole_rows - 1,src_step_in_pixel,src_whole_cols);
for(i = 0; i<READ_TIMES_ROW; i++)
{
int current_addr = start_addr+i*LSIZE0;
current_addr = ((current_addr < end_addr) && (current_addr > 0)) ? current_addr : 0;
temp[i] = src[current_addr];
}
for(i = 0; i<READ_TIMES_ROW; i++)
{
temp[i]= ELEM(start_x+i*LSIZE0,0,src_whole_cols,(float4)0,temp[i]);
temp[i]= ELEM(start_y,0,src_whole_rows,(float4)0,temp[i]);
}
#else
int index[READ_TIMES_ROW];
int s_x,s_y;
for(i = 0; i<READ_TIMES_ROW; i++)
{
s_x= ADDR_L(start_x+i*LSIZE0,0,src_whole_cols,start_x+i*LSIZE0);
s_x= ADDR_R(start_x+i*LSIZE0,src_whole_cols,s_x);
s_y= ADDR_L(start_y,0,src_whole_rows,start_y);
s_y= ADDR_R(start_y,src_whole_rows,s_y);
index[i]=mad24(s_y,src_step_in_pixel,s_x);
}
for(i = 0; i<READ_TIMES_ROW; i++)
{
temp[i] = src[index[i]];
}
#endif
for(i = 0; i<READ_TIMES_ROW; i++)
{
LDS_DAT[l_y][l_x+i*LSIZE0]=temp[i];
}
barrier(CLK_LOCAL_MEM_FENCE);
sum =LDS_DAT[l_y][l_x+RADIUSX]*mat_kernel[RADIUSX];
for(i=1; i<=RADIUSX; i++)
{
temp[0]=LDS_DAT[l_y][l_x+RADIUSX-i];
temp[1]=LDS_DAT[l_y][l_x+RADIUSX+i];
sum += temp[0]*mat_kernel[RADIUSX-i]+temp[1]*mat_kernel[RADIUSX+i];
}
if((x<dst_cols) & (y<dst_rows))
{
start_addr = mad24(y,dst_step_in_pixel,x);
dst[start_addr] = sum;
}
}

