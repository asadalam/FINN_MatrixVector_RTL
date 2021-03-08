function write_ram(mem_ff, order, data_width, fpga_type)
    fid = fopen('../comm_vfiles/ram.vhdl', 'w');
    
    % Checking correctness of Filter order
    % Calculating the address width of each memory
    %Checking if inputs provided are 'OK' or not
    if (mod(order,2) == 0)    
      if (mod(order/mem_ff,2) ~= 0)
          error('Wrong Memory Folding Factor: Memory Folding Factor should result in Even Number of Memories');
          return;
      end
    else
      if(mod((order+1)/mem_ff,2) ~= 0)
          error('Wrong Memory Folding Factor: Memory Folding Factor should result in Even Number of Memories');
          return;
      end
    end
    
    if (mod(order,2) == 0)
        if(mod(order,mem_ff) == 0)
            addr_width = ceil(log2(mem_ff));
        else
            error('Wrong Memory Folding Factor: Filter Order not integer multiple of Memory Folding Factor');
            return;
        end
    else
        if(mod(order+1,mem_ff) == 0)
            addr_width = ceil(log2(mem_ff));
        else
            error('Wrong Memory Folding Factor: Filter Order+1 not integer multiple of Memory Folding Factor');
            return;
        end
    end
    
    %Header Files
    fprintf(fid,'library ieee;\nuse ieee.std_logic_1164.all;\n');
    fprintf(fid,'use ieee.std_logic_unsigned.all;\n');
    
    % Entity
    fprintf(fid,'--Entity Declaration\n');
    fprintf(fid,'entity ram is\ngeneric(\n');
    % Generic
    fprintf(fid,'DATA_WIDTH : INTEGER := %d;\n',data_width);
    fprintf(fid,'ADDR_WIDTH : INTEGER := %d\n);\n', addr_width);
    % Port
    fprintf(fid,'\nport(\n\n');
    fprintf(fid,'\tclka  : IN  std_logic ;\n');
    fprintf(fid,'\tclkb  : IN  std_logic ;\n');
    fprintf(fid,'\twea   : IN  std_logic ;\n');
    fprintf(fid,'\tweb   : IN  std_logic ;\n');
    fprintf(fid,'\taddra : IN  std_logic_vector (ADDR_WIDTH - 1 downto 0) ;\n');
    fprintf(fid,'\taddrb : IN  std_logic_vector (ADDR_WIDTH - 1 downto 0) ;\n');
    fprintf(fid,'\tdia   : IN  std_logic_vector (DATA_WIDTH - 1 downto 0) ;\n');
    fprintf(fid,'\tdib   : IN  std_logic_vector (DATA_WIDTH - 1 downto 0) ;\n');
    fprintf(fid,'\tdoa   : OUT std_logic_vector (DATA_WIDTH - 1 downto 0) ;\n');
    fprintf(fid,'\tdob   : OUT std_logic_vector (DATA_WIDTH - 1 downto 0)\n);\n');
    fprintf(fid,'\nend entity ;\n');
    
    %Architecture
    fprintf(fid,'\narchitecture generated of ram is\n');
    fprintf(fid,'type ram_type is array (2**ADDR_WIDTH - 1 downto 0) of std_logic_vector (DATA_WIDTH - 1 downto 0);\n');
    
    if (strcmp(fpga_type,'xilinx'))
        fprintf(fid,'shared variable RAM: ram_type;\n');
    elseif (strcmp(fpga_type,'altera'))
        fprintf(fid,'signal RAM: ram_type;\n');
    else
        display('Wrong FPGA type input: Correct input \"xilinx\" or \"altera\"\n');
    end
    
    fprintf(fid,'begin\n');    
    if (strcmp(fpga_type,'xilinx'))
        fprintf(fid,'\tprocess(clka)\n');
        fprintf(fid,'\tbegin\n');
        fprintf(fid,'\t\tif rising_edge(clka) then\n');
        fprintf(fid,'\t\t\tdoa <= RAM(conv_integer(addra));\n');
        fprintf(fid,'\t\t\tif wea = ''1'' then\n');
        fprintf(fid,'\t\t\t\tRAM(conv_integer(addra)) := dia;\n');
        fprintf(fid,'\t\t\tend if;\n');
        fprintf(fid,'\t\tend if;\n');
        fprintf(fid,'\tend process;\n');

        fprintf(fid,'\tprocess(clkb)\n');
        fprintf(fid,'\tbegin\n');
        fprintf(fid,'\t\tif rising_edge(clkb) then\n');
        fprintf(fid,'\t\t\tdob <= RAM(conv_integer(addrb));\n');
        fprintf(fid,'\t\t\tif web = ''1'' then\n');
        fprintf(fid,'\t\t\t\tRAM(conv_integer(addrb)) := dib;\n');
        fprintf(fid,'\t\t\tend if;\n');
        fprintf(fid,'\t\tend if;\n');
        fprintf(fid,'\tend process;\n'); 
        
    elseif (strcmp(fpga_type,'altera'))
     
        fprintf(fid,'\tprocess(clka)\n');
        fprintf(fid,'\tbegin\n');
        fprintf(fid,'\t\tif rising_edge(clka) then\n');        
        fprintf(fid,'\t\t\tif wea = ''1'' then\n');
        fprintf(fid,'\t\t\t\tRAM(conv_integer(addra)) <= dia;\n');
%         fprintf(fid,'\t\t\t\tdoa <= dia;\n');
%         fprintf(fid,'\t\t\telse;\n');
        fprintf(fid,'\t\t\t\tdoa <= RAM(conv_integer(addra));\n');
        fprintf(fid,'\t\t\tend if;\n');
        fprintf(fid,'\t\tend if;\n');
        fprintf(fid,'\tend process;\n');

        fprintf(fid,'\tprocess(clkb)\n');
        fprintf(fid,'\tbegin\n');
        fprintf(fid,'\t\tif rising_edge(clkb) then\n');        
        fprintf(fid,'\t\t\tif web = ''1'' then\n');
        fprintf(fid,'\t\t\t\tRAM(conv_integer(addrb)) <= dib;\n');
%         fprintf(fid,'\t\t\t\tdob <= dib;\n');
%         fprintf(fid,'\t\t\telse;\n');
        fprintf(fid,'\t\t\t\tdob <= RAM(conv_integer(addrb));\n');
        fprintf(fid,'\t\t\tend if;\n');
        fprintf(fid,'\t\tend if;\n');
        fprintf(fid,'\tend process;\n');
        
    else
        display('Wrong FPGA type input: Correct input \"xilinx\" or \"altera\"\n');
    end
    
    fprintf(fid,'\n\nend architecture ;\n');
    
    fclose(fid);
