///* Jiading GAI 
typedef unsigned uint;
typedef uint uint8 __attribute__((ext_vector_type(8)));
typedef float float4 __attribute__((ext_vector_type(4)));

// ./opencl/src/include/kernel/arm/cpu_common.h:95:#define CLK_LOCAL_MEM_FENCE     (1 << 0)
#define CLK_LOCAL_MEM_FENCE     (1 << 0)
#define CLK_GLOBAL_MEM_FENCE 1

//FIXME:which one should it be
//typedef __typeof__(sizeof(int)) size_t;
typedef uint size_t;

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

