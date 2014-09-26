% connects to the computer connected to the gazepoint tracker. 
function gazepoint_connect(ip_address, c_port)
    ip_address = '127.0.0.1';
    c_port = 4242;
    % setup address and port
    client_socket = tcpip(ip_address, c_port);
    % setup line terminator
    set(client_socket, 'InputBufferSize', 4096); 
    fopen(client_socket);     
    client_socket.Terminator = 'CR/LF';
    % enable gazepoint to send data
    fprintf(client_socket, '<SET ID="ENABLE_SEND_DATA" STATE="1" />');
    % enable a data record variable in the data record string 
    fprintf(client_socket, '<SET ID="ENABLE_SEND_COUNTER" STATE="1" />');
    
% show or hide the gazepoint control screen. Pass it a 1 or 0.
function gazepoint_display(bool)
    command = strcat('<SET ID="TRACKER_DISPLAY" STATE ="', bool, '" />');
    fprintf(client_socket, command);
    
% runs the gazepoint calibration and returns the results
function gazepoint_calibrate()    
    % start calibration
    fprintf(client_socket, '<SET ID="CALIBRATE_SHOW" STATE="1" />');
    fprintf(client_socket, '<SET ID="CALIBRATE_START" STATE="1" />');
    % pause for the duration of the sequence
    pause(0.5);
    % exit from the calibration screen
    fprintf(client_socket, '<SET ID="CALIBRATE_SHOW" STATE="0" />');
    % get the calibration result summary
    fprintf(client_socket, '<GET ID="CALIBRATE_RESULT_SUMMARY" />');
    while (get(client_socket, 'BytesAvailable') > 0) 
        calibration_results = fscanf(client_socket)        
        pause(0.01) % delay so text can be printed on screen
    end
    

function get_data(type)    
    command = strcat('<SET ID="', type, '" STATE="1" />');
    % send data
    fprintf(client_socket, command);
    % print data
    while (get(client_socket, 'BytesAvailable') > 0) 
        DataReceived = fscanf(client_socket)
        % TODO: parse 'DataReceived' string to extract data of interest
        % delay so text can be printed on screen
        pause(0.01) 
    end
    
% disconnect and delete socket
function client_clean()
    % clean up
    fprintf(client_socket, '<SET ID="ENABLE_SEND_DATA" STATE="0" />');
    fclose(client_socket); 
    delete(client_socket); 
    clear client_socket