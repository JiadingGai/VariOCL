#define THREADS 256
#define anX 1 
#define anY 1 
#define ksX 3 
#define ksY 3

#include "ms4_fail2_runtime.h"

__kernel void boxFilter_C4_D5(__global const float4 *restrict src, __global float4 *dst, float alpha,
int src_offset, int src_whole_rows, int src_whole_cols, int src_step,
int dst_offset, int dst_rows, int dst_cols, int dst_step
)
{
  int col = get_local_id(0);
  const int gX = get_group_id(0);
  const int gY = get_group_id(1);
  int src_x_off = (src_offset % src_step) >> 4;
  int src_y_off = src_offset / src_step;
  int dst_x_off = (dst_offset % dst_step) >> 4;
  int dst_y_off = dst_offset / dst_step;
  int startX = gX * (THREADS-ksX+1) - anX + src_x_off;
  int startY = (gY << 1) - anY + src_y_off;
  int dst_startX = gX * (THREADS-ksX+1) + dst_x_off;
  int dst_startY = (gY << 1) + dst_y_off;
  float4 data[ksY+1];
  __local float4 temp[2][THREADS];
  
  bool con;
  float4 ss;
  for(int i=0; i < ksY+1; i++)
  {
    con = startX+col >= 0 && startX+col < src_whole_cols && 
          startY+i >= 0 && startY+i < src_whole_rows;
    int cur_col = clamp(startX + col, 0, src_whole_cols);
    ss = (startY+i)<src_whole_rows && (startY+i)>=0&&cur_col>=0 &&
         cur_col<src_whole_cols ? src[(startY+i)*(src_step>>4) + cur_col]:(float4)0;
    data[i] = con ? ss : (float4)(0.0,0.0,0.0,0.0);
  }
  
  float4 sum0 = 0.0, sum1 = 0.0, sum2 = 0.0;
  for(int i=1; i < ksY; i++)
  {
    sum0 += (data[i]);
  }
  
  sum1 = sum0 + (data[0]);
  sum2 = sum0 + (data[ksY]);
  temp[0][col] = sum1;
  temp[1][col] = sum2;
  
  
  barrier(CLK_LOCAL_MEM_FENCE);
  
  
  if(col < (THREADS-(ksX-1)))
  {
    col += anX;
    int posX = dst_startX - dst_x_off + col - anX;
    int posY = (gY << 1);
    float4 tmp_sum[2]= {(float4)(0.0,0.0,0.0,0.0), (float4)(0.0,0.0,0.0,0.0)};
  
    for(int k=0; k<2; k++)
    for(int i=-anX; i<=anX; i++)
    {
      tmp_sum[k] += temp[k][col+i];
    }
  
    for(int i=0; i<2; i++)
    {
      if(posX >= 0 && posX < dst_cols && (posY+i) >= 0 && (posY+i) < dst_rows)
        dst[(dst_startY+i) * (dst_step>>4)+ dst_startX + col - anX] = tmp_sum[i]/alpha;
    }
  }
}

