const PORT = 49000;
const HOST = '127.0.0.1';
// const HOST = '192.168.0.24';		// 192.168.0.24
const FREQ = 100;			        // Sample rate required. Presumably no guarantee it'll actually be achieved

const fs = require('fs');

let samples = 0;

const   fnamePrefix = 'udpDump';
let     fnameIndex = 0;
let     outFile = fnamePrefix.concat('_',fnameIndex,'.csv');

while (fs.existsSync(outFile)) { fnameIndex++; outFile = fnamePrefix.concat('_',fnameIndex,'.csv');}

const dgram = require('dgram');
const client = dgram.createSocket('udp4');

const drefNames = 	['Time_sec',
			'P_deg',
			'Q_deg',
			'R_deg',
			'Pdot_deg_per_sec',
			'Qdot_deg_per_sec',
			'Rdot_deg_per_sec',
			'Vertical_speed_SI',
			'Altitude_MSL_SI',
			'Height_AGL_SI',
			'alpha_deg',
			'IAS0_knots',
			'IAS1_knots',
			'TAS_SI',
			'Left_aileron_deg',
			'Right_aileron_deg',
			'Elevator_deg',
			'Rudder_deg',
			'Roll_deg',
			'Pitch_deg',
			'Yaw_deg',];

let nameString = drefNames[0];	// Concatenate into CSV header
for (let i = 1; i < drefNames.length; i++) {
    nameString = nameString.concat(',',drefNames[i]);
}

console.log(nameString);

fs.writeFile(outFile, nameString.concat('\n'), { flag: 'w' }, err => {} );

const createMessage = (dref, idx, freq) => {

    // A dataref request should be 413 bytes long
    // {
    //      label: null terminated 4 chars (5 bytes), e.g. "RREF\0"
    //      frequency: int (4 bytes)
    //      index: int (4 bytes)
    //      name. char (400 bytes)
    // }

    const message = Buffer.alloc(413);

    // Label that tells X Plane that we are asking for datarefs
    message.write('RREF\0');

    // Frequency that we want X Plane to send the data (timer per sedond)
    message.writeInt8(freq, 5);

    // Index: X Plane will respond with this index to let you know what message it is responding to
    message.writeInt8(idx, 9);

    // This is the dataref you are asking for
    message.write(dref, 13);

    return message;
};

const messages = [
    // 'sim/name/of/dataref', index, frequency'
    // https://developer.x-plane.com/datarefs/
    
    // Flight time
    createMessage('sim/time/total_flight_time_sec', 1, FREQ),
    // Pitch angle and rate, deg/s
    createMessage('sim/flightmodel/position/P', 1, FREQ),
    createMessage('sim/flightmodel/position/Q', 1, FREQ),
    createMessage('sim/flightmodel/position/R', 1, FREQ),
    createMessage('sim/flightmodel/position/P_dot', 1, FREQ),
    createMessage('sim/flightmodel/position/Q_dot', 1, FREQ),
    createMessage('sim/flightmodel/position/R_dot', 1, FREQ),
    // Vertical speed, m/s
    createMessage('sim/flightmodel/position/vh_ind', 1, FREQ),
    // Elevation above MSL, m
    createMessage('sim/flightmodel/position/elevation', 1, FREQ),
    // Elevation above groud, m
    createMessage('sim/flightmodel/position/y_agl', 1, FREQ),
    // Angle of attack, degrees
    createMessage('sim/flightmodel/position/alpha', 1, FREQ),
    
    // Indicated airspeed, kias
    createMessage('sim/flightmodel/position/indicated_airspeed', 1, FREQ),
    createMessage('sim/flightmodel/position/indicated_airspeed2', 1, FREQ),
    // True airspeed, m/s
    createMessage('sim/flightmodel/position/true_airspeed', 1, FREQ),
    
    // Ailerons deflection, deg
    createMessage('sim/flightmodel/controls/mwing10_ail1def', 1, FREQ),
    createMessage('sim/flightmodel/controls/mwing06_ail1def', 1, FREQ),
    // Elevator deflection, deg
    createMessage('sim/flightmodel/controls/hstab1_elv1def', 1, FREQ),
    // Rudder deflection, deg
    createMessage('sim/flightmodel/controls/vstab1_rud1def', 1, FREQ),
    
    // Roll; pitch; yaw, deg
    createMessage('sim/flightmodel/position/true_phi', 1, FREQ),
    createMessage('sim/flightmodel/position/true_theta', 1, FREQ),
    createMessage('sim/flightmodel/position/true_psi', 1, FREQ),
    
    /*// Position, orientation
    createMessage('sim/flightmodel/position/latitude', 1, FREQ),
    createMessage('sim/flightmodel/position/longitude', 1, FREQ),
    createMessage('sim/flightmodel/position/mag_psi', 1, FREQ),*/
    // Add as many as you like (within X Plane's recommended limitation)
];

client.on('listening', () => {
    const address = client.address();
    console.log(`UDP client listening on ${address.address}:${address.port}`);
});

client.on('message', (message, remote) => {

    // Message structure received from X Plane:
    // {
    //      label: 4 bytes,
    //      1 byte (for internal use by X Plane)
    //      index: 4 bytes
    //      value: float - 8 bytes x n
    // }


    // Read the first 4 bytes. This is the label that x-plane responds with to indicate
    // what type of data you are receiving. In our case, this should be "RREF". If it is
    // not, ignore the message.
    // The next byte (offset 4) is used by x plane, and not of interest
    // The index (at offset 5) is the index that you specified in the message. To specify
    // which request X Plane is responding to
    // The values starts at offset 9. 8 bytes per value. Values will appear in the same order
    // as the requested values
    const label = message.toString('utf8', 0, 4);
    if (label !== 'RREF') {
        console.log('Unknown package. Ignoring');
    } else {
    	// let idxoffset = 5;
        let msgoffset = 9;
        let messages = [];
        
        let valnum = 0;
        
        let msgstring = '';

        // RREFs values are floats. They occupy 8 bytes. One message can contain several values,
        // depending on how many you asked for. Read every value by iterating over message and
        // increasing the offset by 8.
        while (msgoffset < message.length) {
            //const index = message.readFloatLE(idxoffset);
            const value = message.readFloatLE(msgoffset);
            messages.push(value);
            
            if (valnum == 0) { msgstring = msgstring.concat(value); }
            else { msgstring = msgstring.concat(',',value); }

            //console.log('Value' + valnum + '(' + index + ')' + ': ' + value);
            //console.log(drefNames[valnum] + ': ' + value);

            msgoffset += 8;
            valnum++;
        }
        fs.writeFile(outFile, msgstring.concat('\n'), { flag: 'a' }, err => {} );
        samples++;
        console.log('Sample: ' + samples);

        // Do something with the values (e.g. emit them over socket.io to a client, or whatever)
    }
});

for (let i = 0; i < messages.length; i++) {
    client.send(messages[i], 0, messages[i].length, PORT, HOST, (err, bytes) => {
        if (err) {
            console.log('Error', err)
        } else {
            console.log(`UDP message sent to ${HOST}:${PORT}`);
        }
    });
}
