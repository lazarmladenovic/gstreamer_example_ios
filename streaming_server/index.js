// content of index.js
const http = require('http')
const port = 3000
const clientIp = require('client-ip')

var exec = require('child_process').exec, childVideo, childAudio;

const requestHandler = (request, response) => {
  console.log(request.url)

var cliIp = clientIp(request)

console.log(cliIp)

var gstPipelineVideo = 'gst-launch-1.0 wrappercamerabinsrc ! video/x-raw,width=640,height=480 ! jpegenc ! rtpjpegpay ! udpsink host='+ cliIp + ' port=5200'
var gstPipelineAudio = 'gst-launch-1.0  autoaudiosrc ! audioconvert ! rtpL24pay ! udpsink host='+ cliIp + ' auto-multicast=true port=5000'

childVideo = exec(gstPipelineVideo,
    function (error, stdout, stderr) {
        console.log('stdout: ' + stdout);
        console.log('stderr: ' + stderr);
        if (error !== null) {
             console.log('exec error: ' + error);
        }
    })

childAudio = exec(gstPipelineAudio,
    function (error, stdout, stderr) {
        console.log('stdout: ' + stdout);
        console.log('stderr: ' + stderr);
        if (error !== null) {
             console.log('exec error: ' + error);
        }
    })  
  //child(); 

  response.end('Hello Node.js Server!' + cliIp)
}

const server = http.createServer(requestHandler)

server.listen(port, (err) => {
	if (err) {
		return console.log('something bad happened', err)
	}
})