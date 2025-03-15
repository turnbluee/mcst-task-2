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

    reg [DATA_W-1:0] elem [LIFO_SIZE-1:0];
    reg [DATA_W-1:0] out_reg;
    assign dataout = out_reg;
    
    localparam COUNT_W = $clog2(LIFO_SIZE+1);
    reg [COUNT_W-1:0] count;
    
    wire read_mode, write_mode, read_write_mode;
    assign read_mode = read & count != 0;
    assign write_mode = write & full == 0;
    assign read_write_mode = write & read;
    assign full = count == LIFO_SIZE; 

    always @(posedge clock) begin : regs
        count <= reset ? 0 :
            write & read ? count :
            write & count < LIFO_SIZE ? count + 1 :
            read & count != 0 ? count - 1 :
            read & count == 0 ? 0 : count;

        val <= read & count != 0 ? 1 : 0;
    end

    generate
        for (genvar i = 0; i < LIFO_SIZE; i = i + 1) begin
                if (i == 0) begin
                    always @(posedge clock) begin
                        elem[i] <= read_write_mode | write_mode ? datain :
                            read_mode ? elem[i + 1] : elem[i];
                    end
                end else if (i == LIFO_SIZE - 1) begin
                    always @(posedge clock) begin
                        elem[i] <= read_write_mode ? elem[i] :
                            write_mode ? elem[i - 1] : elem[i];
                    end
                end else begin
                    always @(posedge clock) begin
                        elem[i] <= read_write_mode ? elem[i] :
                            write_mode ? elem[i - 1] :
                            read_mode != 0 ? elem[i + 1] : elem[i];
                    end
                end
            end
    endgenerate

    always @(posedge clock) begin : out
        out_reg <= read ? elem[0] : out_reg;
    end
endmodule
