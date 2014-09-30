
__kernel void copy_to_with_mask(
__global const GENTYPE* restrict srcMat,
__global GENTYPE* dstMat,
__global const uchar* restrict maskMat,
int cols,
int rows,
int srcStep_in_pixel,
int srcoffset_in_pixel,
int dstStep_in_pixel,
int dstoffset_in_pixel,
int maskStep,
int maskoffset)
{
int x=get_global_id(0);
int y=get_global_id(1);
x = x< cols ? x: cols-1;
y = y< rows ? y: rows-1;
int srcidx = mad24(y,srcStep_in_pixel,x+ srcoffset_in_pixel);
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel);
int maskidx = mad24(y,maskStep,x+ maskoffset);
uchar mask = maskMat[maskidx];
if (mask)
{
dstMat[dstidx] = srcMat[srcidx];
}
}

