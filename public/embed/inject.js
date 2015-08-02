console.log("Inject zenoradio widget version 2");
var data = {
  'did'       : myTrim(document.getElementById('radio_script').dataset.did),
  'display_name'    : myTrim(document.getElementById('radio_script').dataset.display_name),
  'display_number'  : myTrim(document.getElementById('radio_script').dataset.display_number),
  'autoplay'      : myTrim(document.getElementById('radio_script').dataset.autoplay),
  'background_image'  : myTrim(document.getElementById('radio_script').dataset.background_image),
  'volume'    : document.getElementById('radio_script').dataset.volume || "75",
  'stream_name_color'   : myTrim(document.getElementById('radio_script').dataset.stream_name_color),
  'stream_name_outline'   : myTrim(document.getElementById('radio_script').dataset.stream_name_outline),
}
var dataEncoded = EncodeQueryData(data);
var url     = "http://widget.zenoradio.com/version/2/?"+dataEncoded;
var width   = document.getElementById('radio_script').dataset.width || "250";
var height    = document.getElementById('radio_script').dataset.height || "200";
html_to_inject = "";
html_to_inject += "<iframe ";
html_to_inject += " src='"+url+"' ";
html_to_inject += " width='"+width+"' ";
html_to_inject += " height='"+height+"' ";
html_to_inject += " frameborder='0' ";
html_to_inject += " scrolling='no' ";
html_to_inject += " style=' ";
html_to_inject += " webkit-border-radius:0px; -moz-border-radius:0px; border-radius:0px; ";
html_to_inject += "  width:"+width+"px; ";
html_to_inject += "  height:"+height+"px; ";
html_to_inject += "  overflow: hidden; ";
html_to_inject += "  margin:0px; ";
html_to_inject += "  padding: 0px; ";
html_to_inject += "  border: 0px '";
html_to_inject += "></iframe> ";
console.log("Inject iframe url="+url);
document.write(html_to_inject)
function EncodeQueryData(data){
   var ret = [];
   for (var d in data) ret.push(encodeURIComponent(d) + "=" + encodeURIComponent(data[d]));
   return ret.join("&");
}
function myTrim(x){
   if (x) return x.replace(/^\s+|\s+$/gm,'');
}