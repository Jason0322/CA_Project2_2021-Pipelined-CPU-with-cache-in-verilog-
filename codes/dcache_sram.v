module dcache_sram
(
    clk_i,
    rst_i,
    addr_i,
    tag_i,
    data_i,
    enable_i,
    write_i,
    tag_o,
    data_o,
    hit_o
);

// I/O Interface from/to controller
input              clk_i;
input              rst_i;
input    [3:0]     addr_i;
input    [24:0]    tag_i;
input    [255:0]   data_i;
input              enable_i;
input              write_i;

output   [24:0]    tag_o;
output   [255:0]   data_o;
output             hit_o;


// Memory
reg      [24:0]    tag [0:15][0:1];
reg      [255:0]   data[0:15][0:1];
reg                lru [0:15];
wire hit0;
wire hit1;
integer            i, j;

wire [24:0]tmptag0;
wire [24:0]tmptag1;
assign tmptag0=     (addr_i==4'b0000)?tag[0][0]:
                    (addr_i==4'b0001)?tag[1][0]:
                    (addr_i==4'b0010)?tag[2][0]:
                    (addr_i==4'b0011)?tag[3][0]:
                    (addr_i==4'b0100)?tag[4][0]:
                    (addr_i==4'b0101)?tag[5][0]:
                    (addr_i==4'b0110)?tag[6][0]:
                    (addr_i==4'b0111)?tag[7][0]:
                    (addr_i==4'b1000)?tag[8][0]:
                    (addr_i==4'b1001)?tag[9][0]:
                    (addr_i==4'b1010)?tag[10][0]:
                    (addr_i==4'b1011)?tag[11][0]:
                    (addr_i==4'b1100)?tag[12][0]:
                    (addr_i==4'b1101)?tag[13][0]:
                    (addr_i==4'b1110)?tag[14][0]:
                    (addr_i==4'b1111)?tag[15][0]:
                    25'b0;
assign tmptag1=     (addr_i==4'b0000)?tag[0][1]:
                    (addr_i==4'b0001)?tag[1][1]:
                    (addr_i==4'b0010)?tag[2][1]:
                    (addr_i==4'b0011)?tag[3][1]:
                    (addr_i==4'b0100)?tag[4][1]:
                    (addr_i==4'b0101)?tag[5][1]:
                    (addr_i==4'b0110)?tag[6][1]:
                    (addr_i==4'b0111)?tag[7][1]:
                    (addr_i==4'b1000)?tag[8][1]:
                    (addr_i==4'b1001)?tag[9][1]:
                    (addr_i==4'b1010)?tag[10][1]:
                    (addr_i==4'b1011)?tag[11][1]:
                    (addr_i==4'b1100)?tag[12][1]:
                    (addr_i==4'b1101)?tag[13][1]:
                    (addr_i==4'b1110)?tag[14][1]:
                    (addr_i==4'b1111)?tag[15][1]:
                    25'b0;


// Write Data      
// 1. Write hit
// 2. Read miss: Read from memory
always@(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        for (i=0;i<16;i=i+1) begin
            lru[i] <= 0;
            for (j=0;j<2;j=j+1) begin
                tag[i][j] <= 25'b0;
                data[i][j] <= 256'b0;
            end
        end
    end
    if (enable_i && write_i) begin
        // TODO: Handle your write of 2-way associative cache + LRU here
        if(hit0)begin
            tag[addr_i][0] <= tag_i;
            data[addr_i][0] <= data_i;
            lru[addr_i] <= 1'b1;
        end
        else if(hit1)begin
            tag[addr_i][1] <= tag_i;
            data[addr_i][1] <= data_i;
            lru[addr_i] <= 1'b0;
        end
        else begin
            tag[addr_i][lru[addr_i]] <= tag_i;
            data[addr_i][lru[addr_i]] <= data_i;
            lru[addr_i] <= ~lru[addr_i];
        end
            
    end
end

// Read Data      
// TODO: tag_o=? data_o=? hit_o=?

// wire  tmp2;
// assign tmp2 =  (tag[addr_i][0][24:0] == tag_i[24:0])&(tag[addr_i][0][24:24]==1'b1);


assign hit0 = (tmptag0[22:0] == tag_i[22:0])&(tmptag0[24:24]==1'b1);
assign hit1 = (tmptag1[22:0] == tag_i[22:0])&(tmptag1[24:24]==1'b1);

assign data_o = hit0 ? data[addr_i][0] :
                hit1 ? data[addr_i][1] :
                data[addr_i][lru[addr_i]];
assign tag_o  = hit0 ? tag[addr_i][0] : 
                hit1 ? tag[addr_i][1]:
                tag[addr_i][lru[addr_i]];
assign hit_o = hit0||hit1;

endmodule
