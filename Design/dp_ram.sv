module dp_ram #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 256,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    input wire clk,
    input wire reset,
    // --- PORT A ---
    input wire                    enable_a,
    input wire                    write_enable_a,
    input wire [ADDR_WIDTH-1:0]   address_a,
    input wire [DATA_WIDTH-1:0]   write_data_a,
    output logic                  read_valid_a, 
    output logic [DATA_WIDTH-1:0] read_data_a,

    // --- PORT B ---
    input wire                    enable_b,
    input wire                    write_enable_b, 
    input wire [ADDR_WIDTH-1:0]   address_b,
    input wire [DATA_WIDTH-1:0]   write_data_b,
    output logic                  read_valid_b, 
    output logic [DATA_WIDTH-1:0] read_data_b
);

    
    logic [DATA_WIDTH-1:0] ram [DEPTH-1:0];

    // registers output data "piplined because it will used in GPGPU"
    logic [DATA_WIDTH-1:0] read_data_a_reg;
    logic [DATA_WIDTH-1:0] read_data_b_reg;
    logic read_valid_a_reg;
    logic read_valid_b_reg;

    // ----------------------------------------------------------------------
    // Priority: Port A overrides Port B on address collision.
    // ----------------------------------------------------------------------
    always @(posedge clk) begin
        if (enable_a && write_enable_a) begin
            ram[address_a] <= write_data_a;
        end

        if (enable_b && write_enable_b) begin
            if ( !(enable_a && write_enable_a && (address_a == address_b)) ) begin
                ram[address_b] <= write_data_b;
            end
        end
    end

    // ----------------------------------------------------------------------
    // PORT A
    // ----------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            read_data_a_reg  <= {DATA_WIDTH{1'b0}};
            read_valid_a_reg <= 1'b0;
        end 
        else begin
            read_valid_a_reg <= (enable_a && !write_enable_a);

            if (enable_a) begin
                read_data_a_reg <= ram[address_a];
            end

        end
    end

    // ----------------------------------------------------------------------
    // PORT B
    // ----------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            read_data_b_reg  <= {DATA_WIDTH{1'b0}};
            read_valid_b_reg <= 1'b0;
        end 
        else begin
            // Generate Valid Signal
            read_valid_b_reg <= (enable_b && !write_enable_b);

            if (enable_b) begin
                read_data_b_reg <= ram[address_b];
            end
        end
    end

    // Assign internal registers to output ports
    assign read_data_a  = read_data_a_reg;
    assign read_valid_a = read_valid_a_reg;
    assign read_data_b  = read_data_b_reg;
    assign read_valid_b = read_valid_b_reg;

endmodule
