Rumali.object = {
  //url first half
  datacast_url : rumi_api_endpoint + 'datacast/'
}
//Set up the data json once so that we don't need to call service again.It is saved in return_data object
var getJSON = function(url,callbackfn){
  $.getJSON(url) //jquery function to parse url and get data in done method.
    .done(function(data){
        callbackfn(data);  
    });
}
//find all the keys in an array.
var findKeyArray = function(obj){
	var key_array = Object.keys(obj);
	return key_array;
}
