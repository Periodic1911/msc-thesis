module top (
    // input hardware clock (25 MHz)
    input clk, 
    // UART lines
    output TX
    );

    logic rst;
    logic [1:0] rst_cnt;

    nand(rst, rst_cnt[0],rst_cnt[1]);

    always_ff @(posedge clk) begin
      if(rst_cnt != 2'b1)
        rst_cnt <= rst_cnt + 1;
      else
        rst_cnt <= rst_cnt;
    end


    logic [18:0] delay;
    logic [14:0] addr;
    logic [31:0] data;

    always_ff @(posedge(clk)) begin
      delay <= delay + 1;
      if (delay == 19'b0) begin
        addr <= addr + 1;
        uart_send <= 1;
      end else begin
        uart_send <= 0;
      end
    end

    prog_mem rom (.clk(clk), .rst(rst), .FlushD(0), .StallD(0), .A(addr[14:2]), .RD(data));

    logic [7:0] uart_txbyte;
    logic uart_send;
    logic uart_txed;

    assign uart_send = 1;
    always_comb begin
      case (addr[2:0])
        2'b00: uart_txbyte <= data[7:0];
        2'b01: uart_txbyte <= data[15:7];
        2'b10: uart_txbyte <= data[23:15];
        2'b11: uart_txbyte <= data[31:23];
        default: uart_txbyte <= data[7:0];
      endcase
    end
    //assign uart_txbyte = data[7:0];

    /* UART transmitter module designed for
       8 bits, no parity, 1 stop bit. 
    */
    uart_tx_8n1 #(.BAUDRATE(9600)) transmitter (
        // 9600 baud rate clock
        .clk (clk),
        // byte to be transmitted
        .txbyte (uart_txbyte),
        // trigger a UART transmit on baud clock
        .senddata (uart_send),
        // input: tx is finished
        .txdone (uart_txed),
        // output UART tx pin
        .tx (TX)
    );

endmodule
