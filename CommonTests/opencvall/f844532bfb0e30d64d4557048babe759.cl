
__kernel void set_to_with_mask(
GENTYPE scalar,
__global GENTYPE * dstMat,
int cols,
int rows,
int dstStep_in_pixel,
int dstoffset_in_pixel,
__global const uchar * restrict maskMat,
int maskStep,
int maskoffset)
{
int x=get_global_id(0);
int y=get_global_id(1);
x = x< cols ? x: cols-1;
y = y< rows ? y: rows-1;
int dstidx = mad24(y,dstStep_in_pixel,x+ dstoffset_in_pixel);
int maskidx = mad24(y,maskStep,x+ maskoffset);
uchar mask = maskMat[maskidx];
if (mask)
{
dstMat[dstidx] = scalar;
}
}

