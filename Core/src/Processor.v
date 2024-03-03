`timescale 1ns / 1ps

module Processor (
    //Standard Signals
    input        CLK,
    input        RESET,
    //BUS Signals
    inout  [7:0] BUS_DATA,
    output [7:0] BUS_ADDR,
    output       BUS_WE,
    // ROM signals
    output [7:0] ROM_ADDRESS,
    input  [7:0] ROM_DATA,
    // INTERRUPT signals
    input  [1:0] BUS_INTERRUPTS_RAISE,
    output [1:0] BUS_INTERRUPTS_ACK
);
  //The main data bus is treated as tristate, so we need a mechanism to handle this.
  //Tristate signals that interface with the main state machine
  wire [7:0] BusDataIn;
  reg [7:0] CurrBusDataOut, NextBusDataOut;
  reg CurrBusDataOutWE, NextBusDataOutWE;
  //Tristate Mechanism
  assign BusDataIn = BUS_DATA;
  assign BUS_DATA = CurrBusDataOutWE ? CurrBusDataOut : 8'hZZ;
  assign BUS_WE = CurrBusDataOutWE;
  //Address of the bus
  reg [7:0] CurrBusAddr, NextBusAddr;
  assign BUS_ADDR = CurrBusAddr;
  //The processor has two internal registers to hold data between operations, and a third to hold
  //the current program context when using function calls.
  reg [7:0] CurrRegA, NextRegA;
  reg [7:0] CurrRegB, NextRegB;
  reg CurrRegSelect, NextRegSelect;
  reg [7:0] CurrProgContext, NextProgContext;
  //Dedicated Interrupt output lines - one for each interrupt line
  reg [1:0] CurrInterruptAck, NextInterruptAck;
  assign BUS_INTERRUPTS_ACK = CurrInterruptAck;
  //Instantiate program memory here
  //There is a program counter which points to the current operation. The program counter
  //has an offset that is used to reference information that is part of the current operation
  reg [7:0] CurrProgCounter, NextProgCounter;
  reg [1:0] CurrProgCounterOffset, NextProgCounterOffset;
  wire [7:0] ProgMemoryOut;
  wire [7:0] ActualAddress;
  assign ActualAddress = CurrProgCounter + CurrProgCounterOffset;
  // ROM signals
  assign ROM_ADDRESS   = ActualAddress;
  assign ProgMemoryOut = ROM_DATA;
  //Instantiate the ALU
  //The processor has an integrated ALU that can do several different operations
  wire [7:0] AluOut;
  ALU ALU0 (
      //standard signals
      .CLK(CLK),
      .RESET(RESET),
      //I/O
      .IN_A(CurrRegA),
      .IN_B(CurrRegB),
      .ALU_Op_Code(ProgMemoryOut[7:4]),
      .OUT_RESULT(AluOut)
  );
  //The microprocessor is essentially a state machine, with one sequential pipeline
  //of states for each operation.
  //The current list of operations is:
  // 0: Read from memory to A
  // 1: Read from memory to B
  // 2: Write to memory from A
  // 3: Write to memory from B
  // 4: Do maths with the ALU, and save result in reg A
  // 5: Do maths with the ALU, and save result in reg B
  // 6: if A (== or < or > B) GoTo ADDR
  // 7: Goto ADDR
  // 8: Go to IDLE
  // 9: End thread, goto idle state and wait for interrupt.
  // 10: Function call
  // 11: Return from function call
  // 12: Dereference A
  //13: Dereference B
  parameter [7:0]  //Program thread selection
  IDLE = 8'hF0,  //Waits here until an interrupt wakes up the processor.
  GET_THREAD_START_ADDR_0 = 8'hF1,  //Wait.
  GET_THREAD_START_ADDR_1 = 8'hF2,  //Apply the new address to the program counter.
  GET_THREAD_START_ADDR_2 = 8'hF3,  //Wait. Goto ChooseOp.
  //Operation selection
  //Depending on the value of ProgMemOut, goto one of the instruction start states.
  CHOOSE_OPP = 8'h00,
  //Data Flow
  READ_FROM_MEM_TO_A = 8'h10,  //Wait to find what address to read, save reg select.
  READ_FROM_MEM_TO_B = 8'h11,  //Wait to find what address to read, save reg select.
  READ_FROM_MEM_0 = 8'h12,  //Set BUS_ADDR to designated address.
  READ_FROM_MEM_1 = 8'h13,  //wait - Increments program counter by 2. Reset offset.
  READ_FROM_MEM_2 = 8'h14,  //Writes memory output to chosen register, end op.
  WRITE_TO_MEM_FROM_A = 8'h20,  //Reads Op+1 to find what address to Write to.
  WRITE_TO_MEM_FROM_B = 8'h21,  //Reads Op+1 to find what address to Write to.
  WRITE_TO_MEM_0 = 8'h22,  //wait - Increments program counter by 2. Reset offset.
  //Data Manipulation
  DO_MATHS_OPP_SAVE_IN_A = 8'h30,  //The result of maths op. is available, save it to Reg A.
  DO_MATHS_OPP_SAVE_IN_B = 8'h31,  //The result of maths op. is available, save it to Reg B.
  DO_MATHS_OPP_0 = 8'h32,  //wait for new op address to settle. end op.
  //In/Equality
  BRANCH_IF_A_EQUAL_B = 8'h33,  //
  BRANCH_IF_A_LESS_THAN_B = 8'h34,  // 
  BRANCH_IF_A_GREATER_THAN_B = 8'h35,  //
  BRANCH_IF_0 = 8'h36,  //
  BRANCH_IF_1 = 8'h37,  //wait for new op address to settle. end op.
  //GoTo
  GOTO_ADDR = 8'h38,  //
  GOTO_ADDR_0 = 8'h39,  //
  GOTO_ADDR_1 = 8'h40,  //
  GOTO_IDLE = 8'h42,  //
  GOTO_IDLE_0 = 8'h43,  //
  //Function Start
  FUNC_CALL_ADDR = 8'h44,  //
  FUNC_CALL_ADDR_0 = 8'h45,  //
  FUNC_CALL_ADDR_1 = 8'h46,  //
  //Return from Func
  RETURN_FROM_FUNC = 8'h47,  //
  RETURN_FROM_FUNC_0 = 8'h48,  //
  //Dereference
  READ_ADDR_IN_A_SET_TO_A = 8'h49,  //
  READ_ADDR_IN_B_SET_TO_B = 8'h50,  // 
  READ_ADDR_IN_A_SET_TO_0 = 8'h51,  // 
  READ_ADDR_IN_A_SET_TO_1 = 8'h52;  //

  //Sequential part of the State Machine.
  reg [7:0] CurrState, NextState;
  always @(posedge CLK) begin
    if (RESET) begin
      CurrState = 8'h00;
      CurrProgCounter = 8'h00;
      CurrProgCounterOffset = 2'h0;
      CurrBusAddr = 8'hFF;  //Initial instruction after reset.
      CurrBusDataOut = 8'h00;
      CurrBusDataOutWE = 1'b0;
      CurrRegA = 8'h00;
      CurrRegB = 8'h00;
      CurrRegSelect = 1'b0;
      CurrProgContext = 8'h00;
      CurrInterruptAck = 2'b00;
    end else begin
      CurrState = NextState;
      CurrProgCounter = NextProgCounter;
      CurrProgCounterOffset = NextProgCounterOffset;
      CurrBusAddr = NextBusAddr;
      CurrBusDataOut = NextBusDataOut;
      CurrBusDataOutWE = NextBusDataOutWE;
      CurrRegA = NextRegA;
      CurrRegB = NextRegB;
      CurrRegSelect = NextRegSelect;
      CurrProgContext = NextProgContext;
      CurrInterruptAck = NextInterruptAck;
    end
  end
  //Combinatorial section – large!
  always @* begin
    //Generic assignment to reduce the complexity of the rest of the S/M
    NextState = CurrState;
    NextProgCounter = CurrProgCounter;
    NextProgCounterOffset = 2'h0;
    NextBusAddr = 8'hFF;
    NextBusDataOut = CurrBusDataOut;
    NextBusDataOutWE = 1'b0;
    NextRegA = CurrRegA;
    NextRegB = CurrRegB;
    NextRegSelect = CurrRegSelect;
    NextProgContext = CurrProgContext;
    NextInterruptAck = 2'b00;
    //Case statement to describe each state
    case (CurrState)
      ///////////////////////////////////////////////////////////////////////////////////////
      //Thread states.
      IDLE: begin
        if (BUS_INTERRUPTS_RAISE[0]) begin  // Interrupt Request A.
          NextState = GET_THREAD_START_ADDR_0;
          NextProgCounter = 8'hFF;
          NextInterruptAck = 2'b01;
        end else if (BUS_INTERRUPTS_RAISE[1]) begin  //Interrupt Request B.
          NextState = GET_THREAD_START_ADDR_0;
          NextProgCounter = 8'hFE;
          NextInterruptAck = 2'b10;
        end else begin
          NextState = IDLE;
          NextProgCounter = 8'hFF;  //Nothing has happened.
          NextInterruptAck = 2'b00;
        end
      end
      //Wait state - for new prog address to arrive.
      GET_THREAD_START_ADDR_0: begin
        NextState = GET_THREAD_START_ADDR_1;
      end
      //Assign the new program counter value
      GET_THREAD_START_ADDR_1: begin
        NextState = GET_THREAD_START_ADDR_2;
        NextProgCounter = ProgMemoryOut;
      end
      //Wait for the new program counter value to settle
      GET_THREAD_START_ADDR_2: begin
        NextState = CHOOSE_OPP;
      end
      ///////////////////////////////////////////////////////////////////////////////////////
      //CHOOSE_OPP - Another case statement to choose which operation to perform
      CHOOSE_OPP: begin
        case (ProgMemoryOut[3:0])
          4'h0: NextState = READ_FROM_MEM_TO_A;
          4'h1: NextState = READ_FROM_MEM_TO_B;
          4'h2: NextState = WRITE_TO_MEM_FROM_A;
          4'h3: NextState = WRITE_TO_MEM_FROM_B;
          4'h4: NextState = DO_MATHS_OPP_SAVE_IN_A;
          4'h5: NextState = DO_MATHS_OPP_SAVE_IN_B;
          4'h6: NextState = BRANCH_IF_A_EQUAL_B;
          4'h7: NextState = BRANCH_IF_A_LESS_THAN_B;
          4'h8: NextState = BRANCH_IF_A_GREATER_THAN_B;
          4'h9: NextState = GOTO_ADDR;
          4'hA: NextState = GOTO_IDLE;
          4'hB: NextState = FUNC_CALL_ADDR;
          4'hC: NextState = RETURN_FROM_FUNC;
          4'hD: NextState = READ_ADDR_IN_A_SET_TO_A;
          4'hE: NextState = READ_ADDR_IN_B_SET_TO_B;
          default: NextState = CurrState;
        endcase
        NextProgCounterOffset = 2'h1;
      end
      ///////////////////////////////////////////////////////////////////////////////////////
      //READ_FROM_MEM_TO_A : here starts the memory read operational pipeline.
      //Wait state - to give time for the mem address to be read. Reg select is set to 0
      READ_FROM_MEM_TO_A: begin
        NextState = READ_FROM_MEM_0;
        NextRegSelect = 1'b0;  //Select register A
      end
      //READ_FROM_MEM_TO_B : here starts the memory read operational pipeline.
      //Wait state - to give time for the mem address to be read. Reg select is set to 1
      READ_FROM_MEM_TO_B: begin
        NextState = READ_FROM_MEM_0;
        NextRegSelect = 1'b1;  //Select register B
      end
      //The address will be valid during this state, so set the BUS_ADDR to this value.
      READ_FROM_MEM_0: begin
        NextState   = READ_FROM_MEM_1;
        NextBusAddr = ProgMemoryOut;
      end
      //Wait state - to give time for the mem data to be read
      //Increment the program counter here. This must be done 2 clock cycles ahead
      //so that it presents the right data when required.
      READ_FROM_MEM_1: begin
        NextState = READ_FROM_MEM_2;
        NextProgCounter = CurrProgCounter + 2;
      end
      //The data will now have arrived from memory. Write it to the proper register.
      READ_FROM_MEM_2: begin
        NextState = CHOOSE_OPP;
        if (!CurrRegSelect) NextRegA = BusDataIn;
        else NextRegB = BusDataIn;
      end
      ///////////////////////////////////////////////////////////////////////////////////////
      //WRITE_TO_MEM_FROM_A : here starts the memory write operational pipeline.
      //Wait state - to find the address of where we are writing
      //Increment the program counter here. This must be done 2 clock cycles ahead
      //so that it presents the right data when required.
      WRITE_TO_MEM_FROM_A: begin
        NextState = WRITE_TO_MEM_0;
        NextRegSelect = 1'b0;
        NextProgCounter = CurrProgCounter + 2;
      end
      //WRITE_TO_MEM_FROM_B : here starts the memory write operational pipeline.
      //Wait state - to find the address of where we are writing
      //Increment the program counter here. This must be done 2 clock cycles ahead
      // so that it presents the right data when required.
      WRITE_TO_MEM_FROM_B: begin
        NextState = WRITE_TO_MEM_0;
        NextRegSelect = 1'b1;
        NextProgCounter = CurrProgCounter + 2;
      end
      //The address will be valid during this state, so set the BUS_ADDR to this value,
      //and write the value to the memory location.
      WRITE_TO_MEM_0: begin
        NextState   = CHOOSE_OPP;
        NextBusAddr = ProgMemoryOut;
        if (!NextRegSelect) NextBusDataOut = CurrRegA;
        else NextBusDataOut = CurrRegB;
        NextBusDataOutWE = 1'b1;
      end
      ///////////////////////////////////////////////////////////////////////////////////////
      //DO_MATHS_OPP_SAVE_IN_A : here starts the DoMaths operational pipeline.
      //Reg A and Reg B must already be set to the desired values. The MSBs of the
      // Operation type determines the maths operation type. At this stage the result is
      // ready to be collected from the ALU.
      DO_MATHS_OPP_SAVE_IN_A: begin
        NextState = DO_MATHS_OPP_0;
        NextRegA = AluOut;
        NextProgCounter = CurrProgCounter + 1;
      end
      //DO_MATHS_OPP_SAVE_IN_B : here starts the DoMaths operational pipeline
      //when the result will go into reg B.
      DO_MATHS_OPP_SAVE_IN_B: begin
        NextState = DO_MATHS_OPP_0;
        NextRegB = AluOut;
        NextProgCounter = CurrProgCounter + 1;
      end
      //Wait state for new prog address to settle.
      DO_MATHS_OPP_0: NextState = CHOOSE_OPP;

      ///////////////////////////////////////////////////////////////////////////////////////
      //BRANCH_IF_EQUAL: Branch pipeline:
      // - Check ALU output for relevant condition. 
      //    - If passed, proceed to BRANCH_IF_0: Sets Program Counter to 2nd byte ROM output.
      //    - If failed, proceed to BRANCH_IF_1: Sets Program Counter +2, skipping 2nd byte.
      // - Always pass through BRANCH_IF_1, to wait ROM output to settle before reading the
      //   next instruction.

      // Check for branch if equal
      BRANCH_IF_A_EQUAL_B: begin
        if (AluOut) NextState = BRANCH_IF_0;
        else begin
          NextProgCounter = NextProgCounter + 2;
          NextState = BRANCH_IF_1;
        end
      end

      // Check for branch if less than
      BRANCH_IF_A_LESS_THAN_B: begin
        if (AluOut) NextState = BRANCH_IF_0;
        else begin
          NextProgCounter = NextProgCounter + 2;
          NextState = BRANCH_IF_1;
        end
      end

      // Check for branch if greater than
      BRANCH_IF_A_GREATER_THAN_B: begin
        if (AluOut) NextState = BRANCH_IF_0;
        else begin
          NextProgCounter = NextProgCounter + 2;
          NextState = BRANCH_IF_1;
        end
      end

      // Assign second byte to PC if the condition passed.
      BRANCH_IF_0: begin
        NextState = BRANCH_IF_1;
        NextProgCounter = ProgMemoryOut;
      end

      // Wait for new PC to settle.
      BRANCH_IF_1: begin
        NextState = CHOOSE_OPP;
      end

      ///////////////////////////////////////////////////////////////////////////////////////
      //GOTO ADDRESS: Unconditional jump pipeline:
      // - Wait for ROM output to stabilize. 
      // - Assign ROM output to PC.
      // - Wait for ROM output to stabilize.

      // Wait for ROM to settle
      GOTO_ADDR: begin
        NextState = GOTO_ADDR_0;
      end

      // Read next address into prog counter
      GOTO_ADDR_0: begin
        NextProgCounter = ProgMemoryOut;
        NextState = GOTO_ADDR_1;
      end

      // Wait for ROM to settle again.
      GOTO_ADDR_1: begin
        NextState = CHOOSE_OPP;
      end

      ///////////////////////////////////////////////////////////////////////////////////////
      //GOTO IDLE: RESET to IDLE state:
      // - Increment Program counter? Or should it be reset?. 
      // - Wait for ROM to settle, and go to IDLE state.

      // Wait for ROM to settle
      GOTO_IDLE: begin
        NextProgCounter = NextProgCounter + 1;  //? Should the counter be reset here?
        NextState = GOTO_IDLE_0;
      end

      // Wait for ROM to settle again.
      GOTO_IDLE_0: begin
        NextState = IDLE;
      end

      ///////////////////////////////////////////////////////////////////////////////////////
      //FUNC CALL ADDR: JUMP and LINK pipeline:
      // - Save program context and wait for ROM to stabilize. 
      // - Write ROM into PC.
      // - Wait for ROM to stabilize before going to next instruction.

      // Save program context, wait for ROM to stabilize
      FUNC_CALL_ADDR: begin
        NextState = FUNC_CALL_ADDR_0;
        NextProgContext = NextProgCounter + 2;
      end

      //  Write ROM into PC
      FUNC_CALL_ADDR_0: begin
        NextProgCounter = ProgMemOut;
        NextState = FUNC_CALL_ADDR_1;
      end

      // Wait for ROM to stabilize.
      FUNC_CALL_ADDR_1: begin
        NextState = CHOOSE_OPP;
      end

      ///////////////////////////////////////////////////////////////////////////////////////
      //RETURN: Branch to previous contxt pipeline:
      // - Write previous context into PC. 
      // - Wait for ROM to stabilize before going to next instruction.

      // Write previous context into PC
      RETURN_FROM_FUNC: begin
        NextState = RETURN_FROM_FUNC_0;
        NextProgCounter = NextProgContext;
      end

      // Wait for ROM to stabilize
      RETURN_FROM_FUNC_0: begin
        NextState = CHOOSE_OPP;
      end

      ///////////////////////////////////////////////////////////////////////////////////////
      //READ_ADDR_IN_X_SET_TO_X: Dereference Pipeline:
      // - Set RegSelect flag and write the register value on the address bus. 
      // - Wait for bus to stabilize, and set next PC.
      // - Set register value, wait for ROM to stabilize.

      // Set RegSelect flag and write register value on the address bus.
      READ_ADDR_IN_A_SET_TO_A: begin
        NextState = READ_ADDR_IN_A_SET_TO_0;
        NextRegSelect = 1'b0;
        NextBusAddr = NextRegA;
      end

      READ_ADDR_IN_A_SET_TO_B: begin
        NextState = READ_ADDR_IN_A_SET_TO_0;
        NextRegSelect = 1'b1;
        NextBusAddr = NextRegB;
      end

      // Set register value, wait for ROM to stabilize.
      READ_ADDR_IN_A_SET_TO_0: begin
        NextState = READ_ADDR_IN_A_SET_TO_1;
        NextProgCounter = NextProgCounter + 1;
      end

      // Wait for bus to stabilize, and set next PC
      READ_ADDR_IN_A_SET_TO_1: begin
        NextState = CHOOSE_OPP;
        if (!CurrRegSelect) NextRegA = BusDataIn;
        else NextRegB = BusDataIn;
      end

    endcase
  end
endmodule
