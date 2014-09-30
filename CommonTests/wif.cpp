#include <wif.h>

unsigned get_work_dim() {
  TLB_GET_KEY;
  return TLB_GET(work_dim);
}
unsigned get_global_size(unsigned N) {
  TLB_GET_KEY;
  return TLB_GET(__global_size[N]);
}
unsigned get_global_id(unsigned N)    {
  TLB_GET_KEY;
  return TLB_GET(__global_id[N]) + (N == 0 ? TLB_GET(__i) : (N == 1 ? TLB_GET(__j) : TLB_GET(__k)));
}
unsigned get_local_size(unsigned N) {
  TLB_GET_KEY;
  return TLB_GET(__local_size[N]);
}
unsigned get_local_id(unsigned N) {
  TLB_GET_KEY;
  return (N == 0 ? TLB_GET(__i) : (N == 1 ? TLB_GET(__j) : TLB_GET(__k)));
}
unsigned get_num_groups(unsigned N) {
  TLB_GET_KEY;
  return TLB_GET(__num_groups[N]);
}
unsigned get_group_id(unsigned N) {
  TLB_GET_KEY;
  return TLB_GET(__group_id[N]);
}
unsigned get_global_offset(unsigned N) {
  TLB_GET_KEY;
  return TLB_GET(__global_offset[N]);
}
unsigned get_group_offset(unsigned N) {
  TLB_GET_KEY;
  return TLB_GET(__group_offset[N]);
}