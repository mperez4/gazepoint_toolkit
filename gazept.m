classdef gazept < handle
    properties(SetAccess=private)
        ip_address
        port_number
        client_socket
    end
    methods
        function obj = connect_gazepoint(obj, ip, portnum)
            if nargin < 2, ip = '127.0.0.1'; end
            if nargin < 3, portnum = 4242; end           
            obj.ip_address=ip;
            obj.port_number = portnum;
            try        
                % setup address and port
                obj.client_socket = tcpip(obj.ip_address, obj.port_number);
                % setup line terminator
                set(obj.client_socket, 'InputBufferSize', 4096); 
                fopen(obj.client_socket);     
                obj.client_socket.Terminator = 'CR/LF';
                % enable gazepoint to send data
                fprintf(obj.client_socket, '<SET ID="ENABLE_SEND_DATA" STATE="1" />');
                % enable a data record variable in the data record string 
                fprintf(obj.client_socket, '<SET ID="ENABLE_SEND_COUNTER" STATE="1" />');
                gazepoint_info = strcat('Connected to:', obj.ip_address, ' on port:', num2str(obj.port_number), '\n');  
                fprintf(gazepoint_info);
            catch err        
                rethrow(err);
                fprintf('Make sure GazepointControl is open on host machine.');
            end
        end
        function obj=calibrate(obj)
            % start calibration
            fprintf(obj.client_socket, '<SET ID="CALIBRATE_SHOW" STATE="1" />');
            fprintf(obj.client_socket, '<SET ID="CALIBRATE_START" STATE="1" />');
            % pause for the duration of the sequence
            pause(15);
            % exit from the calibration screen
            fprintf(obj.client_socket, '<SET ID="CALIBRATE_SHOW" STATE="0" />');
            % get the calibration result summary
%             fprintf(obj.client_socket, '<GET ID="CALIBRATE_RESULT_SUMMARY" />');
%             while (get(obj.client_socket, 'BytesAvailable') > 0) 
%                 calibration_results = fscanf(obj.client_socket)        
%                 pause(0.01) % delay so text can be printed on screen
%             end
        end
        function obj = get_data(obj, type)    
            command = strcat('<SET ID="', type, '" STATE="1" />');
            % send data
            fprintf(obj.client_socket, command);
            % print data
            while (get(obj.client_socket, 'BytesAvailable') > 0) 
            DataReceived = fscanf(obj.client_socket)
            % TODO: parse 'DataReceived' string to extract data of interest
            % delay so text can be printed on screen
            pause(0.01) 
            end
        end
        function obj = client_clean(obj)
            % clean up
            fprintf(obj.client_socket, '<SET ID="ENABLE_SEND_DATA" STATE="0" />');
            fclose(obj.client_socket); 
            delete(obj.client_socket); 
            clear obj.client_socket
        end
    
    end
end