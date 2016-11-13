// Sai Marri
// DTPM cache implementation to store the precomputed hashes
// This block stores the start address, end address, hash value of the basic blocks
// 256 cache locations


module dtpm_cache(
             reset_n,
             fetch_addr,
             hit_start_addr,
             hit_end_addr,
             cache_index,
             hash_value);

parameter                   INST_ADDR_WIDTH  = 32;
parameter                   MEMORY_REG_WIDTH = (2 * INST_ADDR_WIDTH) + 128;


input                       reset_n;

input [INST_ADDR_WIDTH-1:0]   fetch_addr;
output                        hit_start_addr;
output                        hit_end_addr;
output reg [127:0]            hash_value; 
output reg [6:0]              cache_index;


reg [MEMORY_REG_WIDTH-1:0]  cache_mem [0:127];
reg [127:0]	start_addr;
reg [127:0]	end_addr;


// Initilize the Memory with the Basic blocks.
always @ (negedge reset_n)
begin
    cache_mem[0]     =   {32'h0, 32'h0, 128'h0};
    cache_mem[1]     =   {32'h0, 32'h0, 128'h0};
    cache_mem[2]     =   {32'h0, 32'h0, 128'h0};
    cache_mem[3]     =   {32'h0, 32'h0, 128'h0};
    cache_mem[4]     =   {32'h0, 32'h0, 128'h0};
    cache_mem[5]     =   {32'h0, 32'h0, 128'h0};
    cache_mem[6]     =   {32'h0, 32'h0, 128'h0};
    cache_mem[7]     =   {32'h0, 32'h0, 128'h0};
    cache_mem[8]     =   {32'h0, 32'h0, 128'h0};
    cache_mem[9]     =   {32'h0, 32'h0, 128'h0};
    cache_mem[10]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[11]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[12]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[13]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[14]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[15]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[16]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[17]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[18]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[19]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[20]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[21]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[22]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[23]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[24]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[25]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[26]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[27]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[28]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[29]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[30]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[31]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[32]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[33]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[34]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[35]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[36]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[37]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[38]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[39]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[40]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[41]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[42]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[43]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[44]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[45]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[46]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[47]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[48]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[49]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[50]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[51]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[52]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[53]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[54]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[55]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[56]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[57]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[58]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[59]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[60]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[61]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[62]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[63]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[64]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[65]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[66]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[67]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[68]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[69]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[70]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[71]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[72]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[73]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[74]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[75]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[76]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[77]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[78]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[79]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[80]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[81]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[82]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[83]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[84]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[85]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[86]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[87]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[88]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[89]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[90]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[91]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[92]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[93]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[94]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[95]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[96]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[97]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[98]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[99]    =   {32'h0, 32'h0, 128'h0};
    cache_mem[100]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[101]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[102]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[103]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[104]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[105]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[106]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[107]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[108]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[109]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[110]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[111]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[112]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[113]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[114]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[115]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[116]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[117]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[118]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[119]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[120]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[121]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[122]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[123]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[124]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[125]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[126]   =   {32'h0, 32'h0, 128'h0};
    cache_mem[127]   =   {32'h0, 32'h0, 128'h0};
end


assign  hit_start_addr  =   |start_addr;
assign  hit_end_addr    =   |end_addr;

genvar i;
generate
    for (i=0; i<128; i=i+1)
    begin : cache
        always @(fetch_addr)
        begin
            if(fetch_addr == cache_mem[i][191:160])
            begin
                start_addr[i]   =   1'b1;
                end_addr[i]     =   1'b0;
                hash_value      =   128'hz;
                cache_index     =   7'hz;
            end
            else if (fetch_addr == cache_mem[i][159:128])
            begin
                start_addr[i]   =   1'b0;
                end_addr[i]     =   1'b1;
                hash_value      =   cache_mem[i][127:0];
                cache_index     =   i;
            end
            else
            begin
                hash_value      =   128'hz;
                start_addr[i]   =   1'b0;
                end_addr[i]     =   1'b0;
                cache_index     =   7'hz;
            end
        end
    
       //assign start_addr[i]    =   (fetch_addr == cache_mem[i][191:160]) ? 1'b1 : 1'b0;
       //assign end_addr[i]      =   (fetch_addr == cache_mem[i][159:128]) ? 1'b1 : 1'b0;
       //assign hash_value       =   (fetch_addr == cache_mem[i][159:128]) ? cache_mem[i][127:0] : 128'hz;
       //assign cache_index      =   start_addr[i]   ? i : 7'hz;
	   //assign cache_index      =   end_addr[i]     ? i : 7'hz;
    end
endgenerate

endmodule
