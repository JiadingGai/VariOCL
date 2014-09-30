#include "ocl_runtime.h"

void A(int);
void B(int);
void C(int);
void D(int);

void r();
void F();
void G();

__kernel void forifbarrier1(int n) {

    int lid0 = get_local_id(0);
    int lsz0 = get_local_size(0);

    int lid1 = get_local_id(1);
    int lsz1 = get_local_size(1);
   
    int lid2 = get_local_id(2);
    int lsz2 = get_local_size(2);
  
for (int i = 0; i < 10; ++i) {
  barrier(1);
  A(lid0);
}

 
    /* Case 1 
    A(lid0);
    for (int i = 0; i < lsz0; ++i) {
      B(lid0);
      for (int i = 0; i < lid1; ++i) {
        C(lid1);
        barrier(1);
      }
      //barrier(1);
      D(lid0);
    }
    E(lid0);
    */

    /* Case 2
    A(lid0);
    for (int i = 0; i < lsz0; ++i) {
      barrier(1);
      B(lid0);
      for (int i = 0; i < lsz1; ++i) {
        C(lid1);
        barrier(1);
      }
      D(lid0);
    }
    E(lid0);
    */
     
    /* Case
    A(lid0);
    int i = 0;
    while (i < lsz0) {
      B(lid0);
      barrier(1);
      C(lid0);
      barrier(1);
      D(lid0);

      ++i;
    }
    E(lid0);
    */

    /* Case 3
    A(lid0);
    for (int i = 0; i < lsz0; ++i) {
      if (foo()) {
        B(lid0);
        continue;
      }
      if (foo1()) {
        B2(lid0);
        continue;
      }
      if (foo2()) {
        B3(lid0);
        continue;
      }
      for (int i = 0; i < lsz1; ++i) {
        C(lid1);
      }
      barrier(1);
      D(lid0);
    }
    E(lid0);
    */

    /* Case 4 - breaks
    A(lid0);
    int i = 0;
    do {
      if (breeak()) {
        D(lid0);
        break;
      }
      B(lid0);
      barrier(1);
      ++i;
    } while (i < lsz0);
    E(lid0);
    */

    /*
    A(lid0);
    if (n > 0) {
      B(lid0);
      for (int i = 0; i < lsz0; i=i+20)   {
        C(lid0);
        barrier(1);
        D(lid0);
      }
    } 
    else {
      E(lid0);
    }
    F(lid0);
    */

    /*
    foo();
    for (int i = 0; i < n; ++i) {
       if (foo1()) {
         foo_A();
       }
       barrier(0);
       foo_B();
    }
    barrier(0);
    for (int i = 0; i < n; ++i) {
      foo_C();
    }
    foo_D();
    */

    return;
}

