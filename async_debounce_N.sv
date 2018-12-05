module async_debounce_N #( parameter N = 8) (

input logic clock, 
input logic reset,
input logic async_in, 

output logic sync_out

);

logic async_in_ff, async_in_ff2; //Flop 2 clocks of inputs to find out if input levels are changing
logic sync_out_reg, sync_out_next; //Register to store output value
logic clear_counter;
logic [LOG2(N)+1:0] count;

always_ff @(posedge clock or posedge reset)
begin
  if (reset) begin
    async_in_ff <=0; 
    async_in_ff2<=0;
    sync_out_reg<=0;
  end
  else begin 
    async_in_ff  <= async_in;
    async_in_ff2 <= async_in_ff;
    sync_out_reg <= sync_out_next;
  end
end

//clear counter because input has changed or count has reached max value
assign clear_counter= (async_in_ff ^ async_in_ff2) | (count==N); 	

//start counter if input is stable
always_ff @(posedge clock or posedge reset)
begin
  if (reset)
    count<= 0;
  else if (clear)
    count<= 0;
  else       
    count<= count+1'b1;
end 

assign thresh = (count==N-1); //Use N-1 as threshold since one clock has already progressed from 1st flop
assign sync_out_next = thresh ? async_in_ff2 : sync_out_reg; // Take new input value if count is reached, or else keep old output value
assign sync_out = sync_out_reg;

endmodule


 
