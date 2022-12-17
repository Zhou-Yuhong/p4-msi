/* -*- P4_16 -*- */

#include <core.p4>
#include <tna.p4>

/*************************************************************************
 ************* C O N S T A N T S    A N D   T Y P E S  *******************
*************************************************************************/
#define MAX_CACHE_DIR_ENTRY 1024
typedef bit<48> mac_addr_t;
typedef bit<32> ipv4_addr_t;
const bit<16> ETHERTYPE_TPID = 0x8100;
const bit<16> ETHERTYPE_IPV4 = 0x0800;
const bit<16> ETHERTYPE_REQUEST = 0x1234;
typedef bit<12> vlan_id_t;
const bit<9> DISAGG_RECIRC = 68; //默认的回环端口, 要问下我们的交换机是多少

//request类型
const bit<4> REQUEST_TYPE_READ = 0x0;
const bit<4> REQUEST_TYPE_WRITE = 0x1;
const bit<4> REQUEST_TYPE_GET_OTHER_STATE = 0x2;
const bit<4> REQUEST_TYPE_SET_STATE = 0x3;
// const bit<4> REQUEST_TYPE_SECOND_READ = 0x2;
// const bit<4> REQUEST_TYPE_SECOND_WRITE = 0x3;
const bit<4> REMOTE_READ_MISS = 0x4;
const bit<4> REMOTE_WRITE_MISS = 0x5;
//state类型
const bit<4> STATE_MODIFY = 0x1;
//开始时都是SHARED的state
const bit<4> STATE_SHARED = 0x0;
const bit<4> STATE_INVALID = 0x3;
const bit<4> STATE_SAME = 0x2; //不需要改动state
//miss类型
const bit<4> MISS_TYPE_NOT_MISS = 0x0;
const bit<4> MISS_TYPE_READ_MISS = 0x1;
const bit<4> MISS_TYPE_WRITE_MISS = 0x2;
//node_id， 模拟4个node,分别为第一位为1，第二位为1，第三位为1，第四位为1
const bit<4> NODE_ID0 = 0x1;
const bit<4> NODE_ID1 = 0x2;
const bit<4> NODE_ID2 = 0x4;
const bit<4> NODE_ID3 = 0x8;
/*************************************************************************
 ***********************  H E A D E R S  *********************************
 *************************************************************************/
/*  Define all the headers the program will recognize             */
/*  The actual sets of headers processed by each gress can differ */

/* Standard ethernet header */
header ethernet_h {
    mac_addr_t dst_addr;
    mac_addr_t src_addr;
    bit<16> ether_type;
}
header vlan_tag_h {
    bit<3> pcp;
    bit<1> cfi;
    vlan_id_t vid;
    bit<16> ether_type;
}
header request_h{
    bit<4> node_id;
    bit<32> index;
    //表示第一次过的读|第一次过的写|第二次过的读|第二次过的写
    bit<4>  requestType;     
    bit<4>  miss_type;
    bit<4>  padding;
}
header state_entry_h0{
    bit<4> requestType;   
    bit<4> cur_state;
    bit<4> next_state;
    bit<4> padding;
}
header state_entry_h1{
    bit<4> requestType;
    bit<4> cur_state;
    bit<4> next_state;
    bit<4> padding;
}
header state_entry_h2{
    bit<4> requestType;
    bit<4> cur_state;
    bit<4> next_state;
    bit<4> padding;
}
header state_entry_h3{
    bit<4> requestType;
    bit<4> cur_state;
    bit<4> next_state;
    bit<4> padding;
}

header ipv4_h {
    bit<4> version;
    bit<4> ihl;
    bit<8> diffserv;
    bit<16> total_len;
    bit<16> identification;
    bit<3> flags;
    bit<13> frag_offset;
    bit<8> ttl;
    bit<8> protocol;
    bit<16> hdr_checksum;
    ipv4_addr_t src_addr;
    ipv4_addr_t dst_addr;
}
/*************************************************************************
 **************  I N G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/
/***********************  H E A D E R S  ************************/
struct cached_t{
    bit<8> state;
}
struct my_ingress_headers_t{
    ethernet_h ethernet;
    // ipv4_h ipv4;
    request_h request;
    //用于后续操作的
    state_entry_h0 entry0;
    state_entry_h1 entry1;
    state_entry_h2 entry2;
    state_entry_h3 entry3;
}
struct my_ingress_metadata_t {
    
}
    /***********************  P A R S E R  **************************/

parser IngressParser(packet_in      pkt,
    /* User */
    out my_ingress_headers_t          hdr,
    out my_ingress_metadata_t         meta,
    /* Intrinsic */
    out ingress_intrinsic_metadata_t  ig_intr_md)
{
    state start{
        pkt.extract(ig_intr_md);
        pkt.advance(PORT_METADATA_SIZE);
        transition parse_ethernet;
    }
    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type){
            ETHERTYPE_REQUEST : parse_request;
            default        : accept; 
        }
    }
    // state parse_ipv4 {
    //     pkt.extract(hdr.ipv4);
    //     transition parse_request;
    // }
    state parse_request {
        pkt.extract(hdr.request);
        transition parse_state_entry0;
    }
    state parse_state_entry0 {
        pkt.extract(hdr.entry0);
        transition parse_state_entry1;
    }
    state parse_state_entry1 {
        pkt.extract(hdr.entry1);
        transition parse_state_entry2;
    }
    state parse_state_entry2{
        pkt.extract(hdr.entry2);
        transition parse_state_entry3;
    }
    state parse_state_entry3{
        pkt.extract(hdr.entry3);
        transition accept;
    }
}
       /***************** M A T C H - A C T I O N  *********************/
control Ingress(
    /* User */
    inout my_ingress_headers_t                       hdr,
    inout my_ingress_metadata_t                      meta,
    /* Intrinsic */
    in    ingress_intrinsic_metadata_t               ig_intr_md,
    in    ingress_intrinsic_metadata_from_parser_t   ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t        ig_tm_md)
{
    action nop(){}
        //声明该寄存器中的数据为cached_t类型， 输入为32bit(index),该寄存器由MAX_CACHE_DIR_ENTRY个寄存器单元组成，命名为cache_dir_state_reg
    Register<cached_t, bit<32>>(MAX_CACHE_DIR_ENTRY) cache_dir_state_reg0;
    //cached_t 是寄存器单元存储的值， bit<32>是输入 bit<4>是返回值
    RegisterAction<cached_t, bit<32>, bit<4>>(cache_dir_state_reg0) cache_state0_get_action = {
        //value对应index下寄存器单元存储的值 state为返回值
        void apply(inout cached_t value, out bit<4> state){
            state = value.state[3:0];
        }
    };
    Register<cached_t, bit<32>>(MAX_CACHE_DIR_ENTRY) cache_dir_state_reg1;
    RegisterAction<cached_t, bit<32>, bit<4>>(cache_dir_state_reg1) cache_state1_get_action = {
        void apply(inout cached_t value, out bit<4> state){
            state = value.state[3:0];
        }
    };
    Register<cached_t, bit<32>>(MAX_CACHE_DIR_ENTRY) cache_dir_state_reg2;
    RegisterAction<cached_t, bit<32>, bit<4>>(cache_dir_state_reg2) cache_state2_get_action = {
        void apply(inout cached_t value, out bit<4> state){
            state = value.state[3:0];
        }
    };
    Register<cached_t, bit<32>>(MAX_CACHE_DIR_ENTRY) cache_dir_state_reg3;
    RegisterAction<cached_t, bit<32>, bit<4>>(cache_dir_state_reg3) cache_state3_get_action = {
        void apply(inout cached_t value, out bit<4> state){
            state = value.state[3:0];
        }
    };
    action get_current_cache_state()
    {
        hdr.entry0.cur_state = cache_state0_get_action.execute(hdr.request.index);
        hdr.entry1.cur_state = cache_state1_get_action.execute(hdr.request.index);
        hdr.entry2.cur_state = cache_state2_get_action.execute(hdr.request.index);
        hdr.entry3.cur_state = cache_state3_get_action.execute(hdr.request.index);
    }
    RegisterAction<cached_t, bit<32>, bit<4>>(cache_dir_state_reg0) cache_state0_set_action = {
        void apply(inout cached_t value){
            if(hdr.entry0.next_state != STATE_SAME){
                value.state = (bit<8>)hdr.entry0.next_state;
            }
        }
    };
    RegisterAction<cached_t, bit<32>, bit<4>>(cache_dir_state_reg1) cache_state1_set_action = {
        void apply(inout cached_t value){
            if(hdr.entry1.next_state != STATE_SAME){
                value.state = (bit<8>)hdr.entry1.next_state;
            }
        }
    };
    RegisterAction<cached_t, bit<32>, bit<4>>(cache_dir_state_reg2) cache_state2_set_action = {
        void apply(inout cached_t value){
            if(hdr.entry2.next_state != STATE_SAME){
                value.state = (bit<8>)hdr.entry2.next_state;
            }
        }
    };
    RegisterAction<cached_t, bit<32>, bit<4>>(cache_dir_state_reg3) cache_state3_set_action = {
        void apply(inout cached_t value){
            if(hdr.entry3.next_state != STATE_SAME){
            value.state = (bit<8>)hdr.entry3.next_state;              
            }
        }
    };    
    action set_cache_state(){
        cache_state0_set_action.execute(hdr.request.index);
        cache_state1_set_action.execute(hdr.request.index);
        cache_state2_set_action.execute(hdr.request.index);
        cache_state3_set_action.execute(hdr.request.index);
    }
    action no_state_op(){}
    action get_next_state0(bit<4>next_state, bit<4>miss_type){
        hdr.entry0.next_state = next_state;
        if(miss_type == MISS_TYPE_READ_MISS){
            hdr.entry1.requestType = REMOTE_READ_MISS;
            hdr.entry2.requestType = REMOTE_READ_MISS;
            hdr.entry3.requestType = REMOTE_READ_MISS;
        }
        if(miss_type == MISS_TYPE_WRITE_MISS){
            hdr.entry1.requestType = REMOTE_WRITE_MISS;
            hdr.entry2.requestType = REMOTE_WRITE_MISS;
            hdr.entry3.requestType = REMOTE_WRITE_MISS;
        }
        if(miss_type == MISS_TYPE_NOT_MISS){
            hdr.entry1.next_state = STATE_SAME;
            hdr.entry2.next_state = STATE_SAME;
            hdr.entry3.next_state = STATE_SAME;
        }
    }
    action get_next_state1(bit<4>next_state, bit<4>miss_type){
        hdr.entry1.next_state = next_state;
        if(miss_type == MISS_TYPE_READ_MISS){
            hdr.entry0.requestType = REMOTE_READ_MISS;
            hdr.entry2.requestType = REMOTE_READ_MISS;
            hdr.entry3.requestType = REMOTE_READ_MISS;
        }
        if(miss_type == MISS_TYPE_WRITE_MISS){
            hdr.entry0.requestType = REMOTE_WRITE_MISS;
            hdr.entry2.requestType = REMOTE_WRITE_MISS;
            hdr.entry3.requestType = REMOTE_WRITE_MISS;
        }
        if(miss_type == MISS_TYPE_NOT_MISS){
            hdr.entry0.next_state = STATE_SAME;
            hdr.entry2.next_state = STATE_SAME;
            hdr.entry3.next_state = STATE_SAME;
        }        
    }
    action get_next_state2(bit<4>next_state, bit<4>miss_type){
        hdr.entry2.next_state = next_state;
        if(miss_type == MISS_TYPE_READ_MISS){
            hdr.entry0.requestType = REMOTE_READ_MISS;
            hdr.entry1.requestType = REMOTE_READ_MISS;
            hdr.entry3.requestType = REMOTE_READ_MISS;
        }
        if(miss_type == MISS_TYPE_WRITE_MISS){
            hdr.entry0.requestType = REMOTE_WRITE_MISS;
            hdr.entry1.requestType = REMOTE_WRITE_MISS;
            hdr.entry3.requestType = REMOTE_WRITE_MISS;
        }
        if(miss_type == MISS_TYPE_NOT_MISS){
            hdr.entry0.next_state = STATE_SAME;
            hdr.entry1.next_state = STATE_SAME;
            hdr.entry3.next_state = STATE_SAME;
        }        
    }
    action get_next_state3(bit<4>next_state, bit<4>miss_type){
        hdr.entry3.next_state = next_state;
        if(miss_type == MISS_TYPE_READ_MISS){
            hdr.entry0.requestType = REMOTE_READ_MISS;
            hdr.entry1.requestType = REMOTE_READ_MISS;
            hdr.entry2.requestType = REMOTE_READ_MISS;
        }
        if(miss_type == MISS_TYPE_WRITE_MISS){
            hdr.entry0.requestType = REMOTE_WRITE_MISS;
            hdr.entry1.requestType = REMOTE_WRITE_MISS;
            hdr.entry2.requestType = REMOTE_WRITE_MISS;
        }
        if(miss_type == MISS_TYPE_NOT_MISS){
            hdr.entry0.next_state = STATE_SAME;
            hdr.entry1.next_state = STATE_SAME;
            hdr.entry2.next_state = STATE_SAME;
        }        
    }
    //状态转换表
    table cacheStateTranslate0{
        actions = {
            get_next_state0;
            no_state_op;
        }
        key = {
            hdr.entry0.cur_state: exact;
            hdr.entry0.requestType: exact;
        }
        size = 12;
        default_action = no_state_op();
    } 
    table cacheStateTranslate1{
        actions = {
            get_next_state1;
            no_state_op;
        }
        key = {
            hdr.entry1.cur_state: exact;
            hdr.entry1.requestType: exact;
        }
        size = 12;
        default_action = no_state_op();
    }
    table cacheStateTranslate2{
        actions = {
            get_next_state2;
            no_state_op;
        }
        key = {
            hdr.entry2.cur_state: exact;
            hdr.entry2.requestType: exact;
        }
        size = 12;
        default_action = no_state_op();
    }
    table cacheStateTranslate3{
        actions = {
            get_next_state3;
            no_state_op;
        }
        key = {
            hdr.entry3.cur_state:   exact;
            hdr.entry3.requestType: exact;
        }
        size = 12;
        default_action = no_state_op();
    }
    //数据重新过一遍ingress，设置state
    action cache_recirc_set_state(){
        ig_tm_md.bypass_egress = 1w1;
        ig_tm_md.ucast_egress_port = DISAGG_RECIRC;
        hdr.request.requestType = REQUEST_TYPE_SET_STATE;
    }
    action cache_recirc_get_other_state(){
        ig_tm_md.bypass_egress = 1w1;
        ig_tm_md.ucast_egress_port = DISAGG_RECIRC;
        hdr.request.requestType = REQUEST_TYPE_GET_OTHER_STATE;
    }
    apply{
        if(hdr.request.requestType == REQUEST_TYPE_SET_STATE){
            set_cache_state();
        }else if(hdr.request.requestType == REQUEST_TYPE_GET_OTHER_STATE){
            if(hdr.request.node_id == NODE_ID0){
                cacheStateTranslate1.apply();
                cacheStateTranslate2.apply();
                cacheStateTranslate3.apply();
            }else if(hdr.request.node_id == NODE_ID1){
                cacheStateTranslate0.apply();
                cacheStateTranslate2.apply();
                cacheStateTranslate3.apply();
            }else if(hdr.request.node_id == NODE_ID2){
                cacheStateTranslate0.apply();
                cacheStateTranslate1.apply();
                cacheStateTranslate3.apply();
            }else if(hdr.request.node_id == NODE_ID3){
                cacheStateTranslate0.apply();
                cacheStateTranslate1.apply();
                cacheStateTranslate2.apply();
            }
            cache_recirc_set_state();
        }else if(hdr.request.requestType == REQUEST_TYPE_READ || hdr.request.requestType == REQUEST_TYPE_WRITE){
            get_current_cache_state();
            if(hdr.request.node_id == NODE_ID0){
                hdr.entry0.requestType = hdr.request.requestType;
                cacheStateTranslate0.apply();
            }else if(hdr.request.node_id == NODE_ID1){
                hdr.entry1.requestType = hdr.request.requestType;
                cacheStateTranslate1.apply();
            }else if(hdr.request.node_id == NODE_ID2){
                hdr.entry2.requestType = hdr.request.requestType;
                cacheStateTranslate2.apply();
            }else if(hdr.request.node_id == NODE_ID3){
                hdr.entry3.requestType = hdr.request.requestType;
                cacheStateTranslate3.apply();
            }
            if(hdr.request.miss_type != MISS_TYPE_NOT_MISS){
                cache_recirc_get_other_state();
            }else{
                cache_recirc_set_state();
            }
        }
    }
}    
    /*********************  D E P A R S E R  ************************/
control IngressDeparser(packet_out pkt,
    /* User */
    inout my_ingress_headers_t                       hdr,
    in    my_ingress_metadata_t                      meta,
    /* Intrinsic */
    in    ingress_intrinsic_metadata_for_deparser_t  ig_dprsr_md)
{
    apply {
        pkt.emit(hdr);
    }
}
/*************************************************************************
 ****************  E G R E S S   P R O C E S S I N G   *******************
 *************************************************************************/

    /***********************  H E A D E R S  ************************/
struct my_egress_headers_t {
}

    /********  G L O B A L   E G R E S S   M E T A D A T A  *********/

struct my_egress_metadata_t {
}

    /***********************  P A R S E R  **************************/

parser EgressParser(packet_in        pkt,
    /* User */
    out my_egress_headers_t          hdr,
    out my_egress_metadata_t         meta,
    /* Intrinsic */
    out egress_intrinsic_metadata_t  eg_intr_md)
{
    /* This is a mandatory state, required by Tofino Architecture */
    state start {
        pkt.extract(eg_intr_md);
        transition accept;
    }
}    
    /***************** M A T C H - A C T I O N  *********************/

control Egress(
    /* User */
    inout my_egress_headers_t                          hdr,
    inout my_egress_metadata_t                         meta,
    /* Intrinsic */    
    in    egress_intrinsic_metadata_t                  eg_intr_md,
    in    egress_intrinsic_metadata_from_parser_t      eg_prsr_md,
    inout egress_intrinsic_metadata_for_deparser_t     eg_dprsr_md,
    inout egress_intrinsic_metadata_for_output_port_t  eg_oport_md)
{
    apply {
    }
}
    /*********************  D E P A R S E R  ************************/

control EgressDeparser(packet_out pkt,
    /* User */
    inout my_egress_headers_t                       hdr,
    in    my_egress_metadata_t                      meta,
    /* Intrinsic */
    in    egress_intrinsic_metadata_for_deparser_t  eg_dprsr_md)
{
    apply {
        pkt.emit(hdr);
    }
}
/************ F I N A L   P A C K A G E ******************************/
Pipeline(
    IngressParser(),
    Ingress(),
    IngressDeparser(),
    EgressParser(),
    Egress(),
    EgressDeparser()
) pipe;

Switch(pipe) main;