Rumali.object = {
	//url first half
	datacast_url : rumi_api_endpoint + 'datacast/'
}

Rumali.utility = (function () {
	//Set up the data json once so that we don't need to call service again.It is saved in return_data object
	var getJSON = function(url, context, callbackfn){
		$.getJSON(url) //jquery function to parse url and get data in done method.
			.done(function(data){
					callbackfn(data,(parseInt(gon.selected_year,10)).toString());
			});
	}

	return{
		getJSON:getJSON,
	}
}());