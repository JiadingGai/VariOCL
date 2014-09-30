
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
#define READ_TIMES_ROW ((2*(RADIUS+LSIZE0)-1)/LSIZE0)
#endif
#ifdef BORDER_CONSTANT
#define ELEM(i,l_edge,r_edge,elem1,elem2) (i)<(l_edge) | (i) >= (r_edge) ? (elem1) : (elem2)
#endif
#ifdef BORDER_REPLICATE
#define ADDR_L(i,l_edge,r_edge)  (i) < (l_edge) ? (l_edge) : (i)
#define ADDR_R(i,r_edge,addr)   (i) >= (r_edge) ? (r_edge)-1 : (addr)
#endif
#ifdef BORDER_REFLECT
#define ADDR_L(i,l_edge,r_edge)  (i) < (l_edge) ? -(i)-1 : (i)
#define ADDR_R(i,r_edge,addr) (i) >= (r_edge) ? -(i)-1+((r_edge)<<1) : (addr)
#endif
#ifdef BORDER_REFLECT_101
#define ADDR_L(i,l_edge,r_edge)  (i) < (l_edge) ? -(i) : (i)
#define ADDR_R(i,r_edge,addr) (i) >= (r_edge) ? -(i)-2+((r_edge)<<1) : (addr)
#endif
#ifdef BORDER_WRAP
#define ADDR_L(i,l_edge,r_edge)  (i) < (l_edge) ? (i)+(r_edge) : (i)
#define ADDR_R(i,r_edge,addr)   (i) >= (r_edge) ?   (i)-(r_edge) : (addr)
#endif
__kernel __attribute__((reqd_work_group_size(LSIZE0,LSIZE1,1))) void col_filter
(__global const GENTYPE_SRC * restrict src,
__global GENTYPE_DST * dst,
const int dst_cols,
const int dst_rows,
const int src_whole_cols,
const int src_whole_rows,
const int src_step_in_pixel,
const int dst_step_in_pixel,
const int dst_offset_in_pixel,
__constant float * mat_kernel __attribute__((max_constant_size(4*(2*RADIUSY+1)))))
{
int x = get_global_id(0);
int y = get_global_id(1);
int l_x = get_local_id(0);
int l_y = get_local_id(1);
int start_addr = mad24(y,src_step_in_pixel,x);
int end_addr = mad24(src_whole_rows - 1,src_step_in_pixel,src_whole_cols);
int i;
GENTYPE_SRC sum;
GENTYPE_SRC temp[READ_TIMES_COL];
__local GENTYPE_SRC LDS_DAT[LSIZE1*READ_TIMES_COL][LSIZE0+1];
for(i = 0;i<READ_TIMES_COL;i++)
{
int current_addr = start_addr+i*LSIZE1*src_step_in_pixel;
current_addr = current_addr < end_addr ? current_addr : 0;
temp[i] = src[current_addr];
}
for(i = 0;i<READ_TIMES_COL;i++)
{
LDS_DAT[l_y+i*LSIZE1][l_x] = temp[i];
}
barrier(CLK_LOCAL_MEM_FENCE);
sum = LDS_DAT[l_y+RADIUSY][l_x]*mat_kernel[RADIUSY];
for(i=1;i<=RADIUSY;i++)
{
temp[0]=LDS_DAT[l_y+RADIUSY-i][l_x];
temp[1]=LDS_DAT[l_y+RADIUSY+i][l_x];
sum += temp[0] * mat_kernel[RADIUSY-i]+temp[1] * mat_kernel[RADIUSY+i];
}
if((x<dst_cols) & (y<dst_rows))
{
start_addr = mad24(y,dst_step_in_pixel,x+dst_offset_in_pixel);
dst[start_addr] = convert_to_DST(sum);
}
}

