// Sai Marri
// DTPM (Dynamic Trust Platform Module)
// Calculate Hash functions for the Instruction basic blocks


module dtpm_top(
        clock,
        reset_n,
        fetch_addr,
        fetch_addr_valid,
        fetch_data,
        fetch_data_valid,
        fetch_data_sel,        
        stall_pc);
		  

parameter INST_ADDR_WIDTH = 32;
parameter INST_DATA_WIDTH = 32;

parameter       IDLE                =   3'b000;
parameter       WAIT_START_ADDR     =   3'b001;
parameter       GET_DATA            =   3'b010;
parameter       WAIT_END_ADDR       =   3'b011;
parameter       STALL_PC            =   3'b100;
parameter       WAIT_HASH           =   3'b101;

parameter       GCM_IDLE            =   3'b000;
parameter       LOAD_KEY            =   3'b001;
parameter       LOAD_IV             =   3'b010;
parameter       LOAD_AUTH_DATA      =   3'b011;
parameter       WAIT_WORD_READY     =   3'b100; 
parameter       LOAD_DATA           =   3'b101;
parameter       WAIT_HASH_OP        =   3'b110;


input                           clock;
input                           reset_n;
input [INST_ADDR_WIDTH-1:0]     fetch_addr;
input [INST_DATA_WIDTH-1:0]     fetch_data;
input                           fetch_addr_valid;
input                           fetch_data_valid;
input [3:0]                     fetch_data_sel;
output reg                      stall_pc;


reg         [2:0]               dtpm_state;
reg         [2:0]               gcm_state;


// DTPM cache variables
wire                            hit_end_addr;
wire                            hit_start_addr;
wire        [6:0]               cache_index;
wire        [127:0]             hash_value;

// AES GCM variables
wire                            reset_gcm;
reg                             reset_local;
reg         [127:0]             dii_data;
reg									  dii_data_vld;
reg                             dii_data_type;
wire                            gcm_busy;
reg                             dii_last_word;
reg         [3:0]               dii_data_size;
wire        [127:0]             hash_output;
wire                            hash_valid;
reg                             cii_ctl_vld;
reg                             cii_IV_vld;
reg         [127:0]             cii_K;

// LOCAL registers storing AES init variables
reg         [127:0]             gcm_key;
reg         [95:0]              gcm_IV;
reg         [127:0]             gcm_auth_data; 

// Local variables 
reg                             last_word;
reg [4:0]                       data_size;
reg [4:0]                       data_size_reg;
reg [127:0]                     data_stack;
reg [127:0]                     data_stack_reg;
reg                             word_ready;
reg [127:0]                     hash_mem;
reg [127:0]                     hash_op;
reg                             hash_ready;


// State Diagram interfacing the PC
always @(posedge clock or negedge reset_n)
begin
    if (reset_n == 1'b0)
    begin
        stall_pc            <=  1'b0;
        dtpm_state          <=  IDLE;
        data_size           <=  5'h0;
        data_stack          <=  128'h0;
        data_stack_reg      <=  128'h0;
        data_size_reg       <=  128'h0;
        last_word           <=  1'b0;
        word_ready          <=  1'b0;
        hash_mem            <=  128'h0;
    end
    else
    begin
        word_ready          <=  1'b0;
        case(dtpm_state)
        IDLE:
        begin
            dtpm_state  <=  WAIT_START_ADDR;
            data_size   <=  5'h0;
            data_stack  <=  128'h0;
            last_word   <=  1'b0;
        end
        WAIT_START_ADDR:
        begin
            if(fetch_addr_valid && hit_start_addr)
            begin
                dtpm_state  <=  GET_DATA;
                data_stack  <=  128'h0;
                data_size   <=  5'h0;
                hash_mem    <=  128'h0;
                last_word   <=  1'b0;
            end
        end
        GET_DATA:
        begin
            if(fetch_data_valid)
            begin
                if(fetch_data_sel == 4'h1)
                begin
                    data_stack[7:0]     <=  fetch_data[7:0];
                    data_stack          <=  data_stack << 8;
                    data_size           <=  data_size + 1;
                end
                else if(fetch_data_sel == 4'h3)
                begin
                    data_stack[15:0]    <=  fetch_data[15:0];
                    data_stack          <=  data_stack << 16;
                    data_size           <=  data_size + 2;
                end
                else if(fetch_data_sel == 4'h7)
                begin
                    data_stack[23:0]    <=  fetch_data[23:0];
                    data_stack          <=  data_stack << 24;
                    data_size           <=  data_size + 3;
                end
                else if(fetch_data_sel == 4'hF)
                begin
                    data_stack[31:0]    <=  fetch_data[31:0];
                    data_stack          <=  data_stack << 32;
                    data_size           <=  data_size + 4;
                end
                if(last_word    ==  1'b1)
                    dtpm_state  <=  STALL_PC;
                else
                    dtpm_state  <=  GET_DATA;
            end
        end
        WAIT_END_ADDR:
        begin
            if(fetch_addr_valid && hit_end_addr)
            begin
                last_word           <=  1'b1;
                dtpm_state          <=  GET_DATA; 
                hash_mem            <=  hash_value;
            end
            else if(fetch_addr_valid)
            begin
                last_word           <=  1'b0;
                dtpm_state          <=  GET_DATA; 
            end
            if(data_size == 5'h10)
            begin
                data_stack_reg  <=  data_stack;
                data_size_reg   <=  data_size;
                data_stack      <=  128'h0;
                data_size       <=  5'h0;
                word_ready      <=  1'b1;
            end
        end
        STALL_PC:
        begin
            data_stack_reg  <=  data_stack;
            data_size_reg   <=  data_size;
            data_stack      <=  128'h0;
            data_size       <=  5'h0;
            word_ready      <=  1'b1;
            stall_pc        <=  1'b1;
            dtpm_state      <=  WAIT_HASH;
        end
        WAIT_HASH:
        begin
            if(hash_ready == 1'b1)
            begin
                if(hash_op == hash_mem)
                begin
                    dtpm_state  <=   IDLE;
                    stall_pc    <=   1'b0;
                end
            end
        end
        endcase
    end
end

assign reset_gcm    =   reset_n & reset_local;


// State Diagram interfacing the hashing gen
always @(posedge clock or negedge reset_n)
begin
    if (reset_n == 1'b0)
    begin
        reset_local     <=  1'b1;
        dii_data        <=  128'h0;
        dii_data_vld    <=  1'b0;
        dii_data_type   <=  1'b0;
        dii_last_word   <=  1'b0;
        cii_ctl_vld     <=  1'b0;
        cii_IV_vld      <=  1'b0;
        cii_K           <=  128'h0;
        gcm_state       <=  GCM_IDLE;
        gcm_key         <=  128'h5AA5BBAACC;        // Load the key here
        gcm_IV          <=  96'hAAF8025;            // Load IV here
        gcm_auth_data   <=  96'hB2389CD;            // Load AUTH DATA
        hash_op         <=  128'h0;
        hash_ready      <=  1'b0;
    end
    else
    begin
        cii_ctl_vld     <=  1'b0;
        cii_IV_vld      <=  1'b0;
        cii_K           <=  128'h0;
        dii_data        <=  128'h0;
        dii_data_vld    <=  1'b0;
        dii_data_type   <=  1'b0;
        dii_last_word   <=  1'b0;
        hash_ready      <=  1'b0;

        case(gcm_state)
        GCM_IDLE:
        begin
            gcm_state   <=  LOAD_KEY;
        end
        LOAD_KEY:
        begin
            cii_ctl_vld <=  1'b1;
            cii_K       <=  gcm_key;
            gcm_state   <=  LOAD_IV;
        end
        LOAD_IV:
        begin
            cii_IV_vld  <=  1'b1;
            dii_data    <=  {32'h0,gcm_IV};
            gcm_state   <=  LOAD_AUTH_DATA; 
        end
        LOAD_AUTH_DATA:
        begin
            if(gcm_busy == 1'b0)
            begin
                dii_data_vld    <=  1'b1;
                dii_data_type   <=  1'b1;
                dii_data        <=  gcm_auth_data;
                gcm_state       <=  WAIT_WORD_READY; 
            end
        end
        WAIT_WORD_READY:
        begin
            if(word_ready   == 1'b1)
            begin
                gcm_state   <=   LOAD_DATA;
            end
        end
        LOAD_DATA:
        begin
            if(gcm_busy == 1'b0)
            begin
                dii_data_vld    <=  1'b1;
                dii_data_type   <=  1'b0;
                dii_data        <=  data_stack_reg;
                dii_data_size   <=  (data_size_reg - 1);
                dii_last_word   <=  last_word;
                if(last_word == 1'b1)
                    gcm_state   <=  WAIT_HASH_OP;
                else
                    gcm_state   <=  WAIT_WORD_READY;
            end
        end
        WAIT_HASH_OP:
        begin
            if(hash_valid   == 1'b1)
            begin
                hash_op     <=  hash_output;
                gcm_state   <=  LOAD_DATA; 
                hash_ready  <=  1'b1;
            end
        end
        endcase
    end
end

dtpm_cache  cache_mem(
                    .reset_n(reset_n),
                    .fetch_addr(fetch_addr),
                    .hit_start_addr(hit_start_addr),
                    .hit_end_addr(hit_end_addr),
                    .cache_index(cache_index),
                    .hash_value(hash_value));




gcm_aes_v0  hash(
            .clk(clock),
            .rst(!reset_gcm),
            .dii_data(dii_data),
            .dii_data_type(dii_data_type),
            .dii_data_not_ready(gcm_busy),
            .dii_last_word(dii_last_word),
            .dii_data_size(dii_data_size),
            .cii_ctl_vld(cii_ctl_vld),
            .cii_IV_vld(cii_IV_vld),
            .cii_K(cii_K),
            .Out_data(hash_output),
            .Out_vld(),
            .Out_data_size(),
            .Out_last_word(),
            .Tag_vld(hash_valid));

endmodule

