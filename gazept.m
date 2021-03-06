classdef gazept < handle
    properties(SetAccess=public)
        ip_address        
        port_number
        client_socket
        gx
        gy
    end
    methods
        function obj = connect(obj, ip, portnum)           
            if nargin < 2, ip = '127.0.0.1'; end
            if nargin < 3, portnum = 4242; end           
            obj.ip_address=ip;
            obj.port_number = portnum;
            try        
                obj.client_socket = tcpip(obj.ip_address, obj.port_number);
                set(obj.client_socket, 'InputBufferSize', 4096); 
                fopen(obj.client_socket);     
                obj.client_socket.Terminator = 'CR/LF';                            
                gazepoint_info = strcat('Connected to:', obj.ip_address, ' on port:', num2str(obj.port_number), '\n');  
                fprintf(gazepoint_info);
            catch err        
                rethrow(err);
                fprintf('Make sure GazepointControl is open on host machine.');
            end
        end
        function obj = calibrate(obj,delay)
            if nargin < 2, delay = 15; end
            fprintf(obj.client_socket, '<SET ID="CALIBRATE_SHOW" STATE="1" />');
            fprintf(obj.client_socket, '<SET ID="CALIBRATE_START" STATE="1" />');
            pause(delay);
            fprintf(obj.client_socket, '<SET ID="CALIBRATE_SHOW" STATE="0" />');
            fprintf(obj.client_socket, '<SET ID="CALIBRATE_START" STATE="0" />');
            fprintf(obj.client_socket, '<GET ID="CALIBRATE_RESULT_SUMMARY" />');
            fprintf(obj.client_socket, '<SET ID="ENABLE_SEND_DATA" STATE="0" />');
            while (get(obj.client_socket, 'BytesAvailable') > 0)                                 
                results = fscanf(obj.client_socket)
                pause(.01);
            end
            pause(1);
            fprintf(obj.client_socket, '<SET ID="ENABLE_SEND_DATA" STATE="1" />');
        end
        function obj = display(obj, state)
            command = strcat('<SET ID="TRACKER_DISPLAY" STATE ="', state, '" />');
            fprintf(client_socket, command);
            while (get(obj.client_socket, 'BytesAvailable') > 0)
                results = fscanf(obj.client_socket);
                pause(.01);
            end
        function obj = get_data(obj, command)
            if nargin < 2, command = 'ENABLE_SEND_POG_BEST'; end
            COMMAND = strcat('<SET ID="', command, '" STATE="1" />');            
            fprintf(obj.client_socket, COMMAND);            
            while (get(obj.client_socket, 'BytesAvailable') > 0) 
                data = fscanf(obj.client_socket);                
                c = '<REC />';             
                if strncmp(data, c, 7)
                    fprintf('waiting...\n');
                else
                    try
                        split = strsplit(data,'"');
                        GX = split(2);
                        GY = split(4);
                        gx = str2num(char(GX));
                        gy = str2num(char(GY));                                                                          
                    catch ex
                        rethrow(ex);
                    end
                end
            pause(0.01) 
            end
        end
        function obj = clean(obj)
            fprintf(obj.client_socket, '<SET ID="ENABLE_SEND_DATA" STATE="0" />');            
            fclose(obj.client_socket); 
            delete(obj.client_socket); 
            clear obj.client_socket
        end   
    end
end
