//10 0000 00 0C94 3400 0C94 3E00 0C94 3E00 0C94 3E00 82


if CLIENT then
GArduino = {}


function GArduino.decode_hexfile( path )
    local data={}

    local str = file.Read(path, "DATA")
    str = string.Replace( str, "\n", "")
    local lines = string.Explode(":", str)


    for line_nr, line in pairs(lines) do
        if line_nr == 1 then continue end
        //print("=========["..(line_nr-1).."]=========")
        local byte_count = tonumber(string.sub(line,1,2),16)
        //print("- Bytecount      " .. byte_count)
        local address = tonumber(string.sub(line,3,6),16)
        //print("- Address        " .. address)
        local record_type = tonumber(string.sub(line,7,8),16)
        //print("- Recordtype     " .. record_type)   
        
        local words={}
        local word_count=0
        for char=9, #line-4, 4 do
            local word = tonumber(string.sub(line,char,char+3),16)   
            //print("- WORD           "..word) 
            words[word_count]=word
            word_count=word_count+1
        end

        local checksum = tonumber(string.sub(line,#line-2,#line-1),16)
        //print("- Checksum       " .. checksum)   

        local entry = {}
        entry.byte_count=byte_count
        entry.address=address
        entry.record_type=record_type
        entry.words=words
        entry.checksum = checksum

        data[line_nr-1]=entry
    end

    return data
end

function GArduino.hex_to_memory( hex, mem )
    for i, v in ipairs(hex) do
        
        //Record types
        if v.record_type == 1 then break end
        if v.record_type > 1 then print("[GArduino] Undefined record type") continue end //Ignore all others for now

        local start_address = v.address/2
        local words = v.words
        for addr=start_address, start_address+#words, 1 do
            mem[addr]=words[addr-start_address]    
        end     
    end

    return mem
end



local hex = GArduino.decode_hexfile( "main.hex" )
local mem={}
mem = GArduino.hex_to_memory( hex, mem )
PrintTable(mem)


end