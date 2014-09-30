///* Jiading GAI 
typedef unsigned uint;
typedef uint uint8 __attribute__((ext_vector_type(8)));

// ./opencl/src/include/kernel/arm/cpu_common.h:95:#define CLK_LOCAL_MEM_FENCE     (1 << 0)
#define CLK_LOCAL_MEM_FENCE     (1 << 0)

//FIXME:which one should it be
//typedef __typeof__(sizeof(int)) size_t;
typedef uint size_t;
uint8 vload8(size_t offset, __local uint * p);

typedef struct {
  unsigned work_dim;
  size_t __global_size[3];
  size_t __global_id[3];
  size_t __local_size[3];
  size_t __num_groups[3];
  size_t __group_id[3];
  size_t __global_offset[3];
  size_t __group_offset[3];

  size_t __k;
  size_t __j;
  size_t __i;

  //int cu_id;
  //arm_kernel_param param_ctx;
  //int kernel_idx;
} tlb_data;

__constant tlb_data TLB;

//6.12.1 Work-item Functions
uint get_work_dim();
size_t get_global_size(uint dimindx);
size_t get_global_id(uint dimindx);
size_t get_local_size(uint dimindx);
size_t get_local_id(uint dimindx);
size_t get_num_groups(uint dimindx);
size_t get_group_id(uint dimindx);
size_t get_global_offset(uint dimindx);
void barrier(int flags);
// */

