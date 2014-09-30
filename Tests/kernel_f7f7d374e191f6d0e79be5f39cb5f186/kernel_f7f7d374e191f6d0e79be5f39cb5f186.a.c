#include <stdio.h> 
///* Jiading GAI 
typedef unsigned uint;
typedef uint uint8 __attribute__((ext_vector_type(8)));

#define N 256

int main(int argc, char *argv[])
{
  uint sSharedStorage[256*8];
  uint src[256*8];
  uint results[256*8];

  for (int i = 0; i < (256 * 8); ++i) {
    src[i] = i;
  }

  int lsz = 256;
  uint offsets[lsz];
  uint alignmentOffsets[lsz];
  for (int tid = 0; tid < lsz; ++tid) {
    offsets[tid] = tid;
    alignmentOffsets[tid] = 0;
  }

  test_fn(sSharedStorage, src, offsets, alignmentOffsets, results);

  for (int i = 0; i < (256); ++i) {
    printf("(");
    for (int j = 0; j < 8; ++j) {
      printf("%d,", results[i * 8 + j]);
    }
    printf(")\n");
  }

  return 0;
}
