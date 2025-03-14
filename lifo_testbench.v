module testbench;
    parameter DATA_W = 5;
    parameter LIFO_SIZE = 2;
    reg read;
    reg write;
    reg reset;
    reg clock;
    reg [DATA_W-1:0] datain;
    wire [DATA_W-1:0] dataout;
    wire val;
    wire full;

    lifo #(.DATA_W(DATA_W), .LIFO_SIZE(LIFO_SIZE)) example_lifo(
        .write(write), .read(read), .clock(clock), .reset(reset),
        .datain(datain), .val(val), .full(full), .dataout(dataout)
    );

    always #1 clock = ~clock;

    initial begin
        clock <= 0;
        reset <= 1;
        write <= 0;
        read <= 0;

        #1;

        reset <= 0;
        write <= 1;
        datain <= 5'b10011;

        #2;

        datain <= 5'b11001;
     
        #2;

        write <= 0;
        read <= 1;

        #2;

        read <= 0;

        #2;

        read <= 1;
        write <= 1;
        datain <= 5'b10000;

        #8;

        $finish;
    end

    `include "dump_settings.v"

endmodule
