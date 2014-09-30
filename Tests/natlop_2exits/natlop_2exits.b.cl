#include "../ocl_runtime.h"

__constant int xDim = 1;
__constant int yDim = 2;
__constant int zDim = 4;
__constant int xid = 0;
__constant int yid = 0;
__constant int zid = 0;


__kernel void natlop_2exits() {

  int k;
  for (int i = 0; i < 10; i++) {
    k = get_local_id(0);
    if (k > xDim) {
      A(k);
    } else {
      B();
      return;
    }
  }

  barrier(1);

  
  if (k == 0) {
    C(k);
  }

}
