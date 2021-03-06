
#define PARTIAL_HISTOGRAM256_COUNT     (256)
#define HISTOGRAM256_BIN_COUNT         (256)
#define HISTOGRAM256_WORK_GROUP_SIZE     (256)
#define HISTOGRAM256_LOCAL_MEM_SIZE      (HISTOGRAM256_BIN_COUNT)
#define NBANKS (16)
#define NBANKS_BIT (4)
__kernel __attribute__((reqd_work_group_size(HISTOGRAM256_BIN_COUNT,1,1)))void calc_sub_hist_D0(
__global const uint4* src,
int src_step, int src_offset,
__global int* globalHist,
int dataCount,  int cols,
int inc_x, int inc_y,
int hist_step)
{
__local int subhist[(HISTOGRAM256_BIN_COUNT << NBANKS_BIT)];
int gid = get_global_id(0);
int lid = get_local_id(0);
int gx  = get_group_id(0);
int gsize = get_global_size(0);
int lsize  = get_local_size(0);
const int shift = 8;
const int mask = HISTOGRAM256_BIN_COUNT-1;
int offset = (lid & (NBANKS-1));
uint4 data, temp1, temp2, temp3, temp4;
src += src_offset;
for(int i=0, idx=lid; i<(NBANKS >> 2); i++, idx += lsize)
{
subhist[idx] = 0;
subhist[idx+=lsize] = 0;
subhist[idx+=lsize] = 0;
subhist[idx+=lsize] = 0;
}
barrier(CLK_LOCAL_MEM_FENCE);
int y = gid/cols;
int x = gid - mul24(y, cols);
for(int idx=gid; idx<dataCount; idx+=gsize)
{
data = src[mad24(y, src_step, x)];
temp1 = ((data & mask) << NBANKS_BIT) + offset;
data >>= shift;
temp2 = ((data & mask) << NBANKS_BIT) + offset;
data >>= shift;
temp3 = ((data & mask) << NBANKS_BIT) + offset;
data >>= shift;
temp4 = ((data & mask) << NBANKS_BIT) + offset;
atomic_inc(subhist + temp1.x);
atomic_inc(subhist + temp1.y);
atomic_inc(subhist + temp1.z);
atomic_inc(subhist + temp1.w);
atomic_inc(subhist + temp2.x);
atomic_inc(subhist + temp2.y);
atomic_inc(subhist + temp2.z);
atomic_inc(subhist + temp2.w);
atomic_inc(subhist + temp3.x);
atomic_inc(subhist + temp3.y);
atomic_inc(subhist + temp3.z);
atomic_inc(subhist + temp3.w);
atomic_inc(subhist + temp4.x);
atomic_inc(subhist + temp4.y);
atomic_inc(subhist + temp4.z);
atomic_inc(subhist + temp4.w);
x += inc_x;
int off = ((x>=cols) ? -1 : 0);
x = mad24(off, cols, x);
y += inc_y - off;
}
barrier(CLK_LOCAL_MEM_FENCE);
int bin1=0, bin2=0, bin3=0, bin4=0;
for(int i=0; i<NBANKS; i+=4)
{
bin1 += subhist[(lid << NBANKS_BIT) + i];
bin2 += subhist[(lid << NBANKS_BIT) + i+1];
bin3 += subhist[(lid << NBANKS_BIT) + i+2];
bin4 += subhist[(lid << NBANKS_BIT) + i+3];
}
globalHist[mad24(gx, hist_step, lid)] = bin1+bin2+bin3+bin4;
}
__kernel void __attribute__((reqd_work_group_size(1,HISTOGRAM256_BIN_COUNT,1)))calc_sub_hist_border_D0(
__global const uchar* src,
int src_step,  int src_offset,
__global int* globalHist,
int left_col,  int cols,
int rows,   int hist_step)
{
int gidx = get_global_id(0);
int gidy = get_global_id(1);
int lidy = get_local_id(1);
int gx = get_group_id(0);
int gy = get_group_id(1);
int gn = get_num_groups(0);
int rowIndex = mad24(gy, gn, gx);
__local int subhist[HISTOGRAM256_LOCAL_MEM_SIZE];
subhist[lidy] = 0;
barrier(CLK_LOCAL_MEM_FENCE);
gidx = ((gidx>=left_col) ? (gidx+cols) : gidx);
if(gidy<rows)
{
int src_index = src_offset + mad24(gidy, src_step, gidx);
int p = (int)src[src_index];
atomic_inc(subhist + p);
}
barrier(CLK_LOCAL_MEM_FENCE);
globalHist[mad24(rowIndex, hist_step, lidy)] += subhist[lidy];
}
__kernel __attribute__((reqd_work_group_size(256,1,1)))void merge_hist(__global int* buf,
__global int* hist,
int src_step)
{
int lx = get_local_id(0);
int gx = get_group_id(0);
int sum = 0;
for(int i = lx; i < PARTIAL_HISTOGRAM256_COUNT; i += HISTOGRAM256_WORK_GROUP_SIZE)
sum += buf[ mad24(i, src_step, gx)];
__local int data[HISTOGRAM256_WORK_GROUP_SIZE];
data[lx] = sum;
for(int stride = HISTOGRAM256_WORK_GROUP_SIZE /2; stride > 0; stride >>= 1)
{
barrier(CLK_LOCAL_MEM_FENCE);
if(lx < stride)
data[lx] += data[lx + stride];
}
if(lx == 0)
hist[gx] = data[0];
}
__kernel __attribute__((reqd_work_group_size(256,1,1)))void calLUT(
__global uchar * dst,
__constant int * hist,
int total)
{
int lid = get_local_id(0);
__local int sumhist[HISTOGRAM256_BIN_COUNT+1];
sumhist[lid]=hist[lid];
barrier(CLK_LOCAL_MEM_FENCE);
if(lid==0)
{
int sum = 0;
int i = 0;
while (!sumhist[i]) ++i;
sumhist[HISTOGRAM256_BIN_COUNT] = sumhist[i];
for(sumhist[i++] = 0; i<HISTOGRAM256_BIN_COUNT; i++)
{
sum+=sumhist[i];
sumhist[i]=sum;
}
}
barrier(CLK_LOCAL_MEM_FENCE);
float scale = 255.f/(total - sumhist[HISTOGRAM256_BIN_COUNT]);
dst[lid]= lid == 0 ? 0 : convert_uchar_sat(convert_float(sumhist[lid])*scale);
}

