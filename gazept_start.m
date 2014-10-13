function gazept_start(delay)
    global gazept_object
    gazept_object = gazept();
    gazept_object.connect();
    gazept_object.calibrate(delay);
    gazept_object.get_data();
    fprintf('gazept communication started');
end

function gazept_end()
    global gazept_object
    gazept_object.clean();
    fprintf('gazept communication terminated.');
end