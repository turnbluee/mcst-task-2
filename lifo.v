module lifo #(
    parameter DATA_W = 10,
    parameter LIFO_SIZE = 6 
)(
    input wire write,
    input wire read,
    input wire clock,
    input wire reset,
    input wire [DATA_W-1:0] datain,
    output wire [DATA_W-1:0] dataout,
    output reg val,
    output wire full
);

    localparam COUNT_W = $clog2(LIFO_SIZE+1);
    reg [COUNT_W-1:0] count;

    reg [DATA_W-1:0] elem [LIFO_SIZE-1:0];
    reg [DATA_W-1:0] out_elem;
    assign dataout = out_elem;
    assign full = count == LIFO_SIZE;


    always @(posedge clock) begin : regs
        count <= reset ? 0 :
            write & read ? count :
            write & count < LIFO_SIZE ? count + 1 :
            read & count != 0 ? count - 1 :
            read & count == 0 ? 0 : count;

        val <= read & count != 0 ? 1 : 0;
    end

    always @(posedge clock) begin : read_write
        out_elem <= read & count != 0 ? elem[count - 1] : out_elem; 

        elem[(read ? count - 1 : count)] <= write & full == 0 ? datain : elem[(read ? count - 1 : count)];
    end
endmodule
