Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};

Rumali.object = {
  //url first half
  datacast_url : rumi_api_endpoint + 'datacast/'
}

Rumali.data_objects = {}

//finding distinct values of the attributes from the array that is being passed.
var findDistinct = function(data,attribute_name){
	var value = [];
	value = _.map(data, function(obj){ return obj[attribute_name] });
	value = _.uniq(value);
	return value;
}
//rendering filter common function
var renderFilter = function(data,metric,id){
	var values,html_string,i,length;
	values = findDistinct(data,metric);
	length = values.length;

	if(length >= 5){
		html_string = smallDropDown(id,values,length);
	}
	else{
		html_string = largeDropDown(id,values,length);
	}
	return html_string;
}

//Set up the data json once so that we don't need to call service again.It is saved in return_data object
var getJSON = function(url,callbackfn){
	var args = arguments;
  if (Rumali.data_objects[url]) {
		if (args[2] && args[3] && args[4] && args[5]) {
			callbackfn(Rumali.data_objects[url],args[2],args[3],args[4],args[5]);
		} else {
			callbackfn(Rumali.data_objects[url]);
		}
  }else {
	  $.getJSON(url) //jquery function to parse url and get data in done method.
	    .done(function(data){
				Rumali.data_objects[url] = data
				if (args[2] && args[3] && args[4] && args[5]) {
					callbackfn(data,args[2],args[3],args[4],args[5]);
				} else {
					callbackfn(data);
				}
	    });
  }
}

//find all the keys in an array.
var findKeyArray = function(obj){
	var key_array = Object.keys(obj);
	return key_array;
}

var getApiFromString = function(api){
  api = api.split(".");
  return PykCharts[api[1]][api[2]];
}

var callGetJson = function(that) {
	var chart_id = that.id,
		datacast_url = Rumali.object.datacast_url + that.dataset.datacast_identifier,
    chart_api = that.dataset.api,
    filter_present = that.dataset.filter_present,
    filter_column_name = that.dataset.filter_column_name || "";
  getJSON(datacast_url,generateChart,chart_id ,chart_api, filter_present, filter_column_name);
}

var generateChart = function (data,chart_id,chart_api,filter_present, filter_column_name) {
	var parent_chart = document.getElementById(chart_id),
		filter_div,
		chart_div;
	if(filter_present == "true") {
		filter_div = document.createElement('div');
		filter_div.id = chart_id + "_"+"chart_filters"
		parent_chart.appendChild(filter_div);
	}
	chart_div = document.createElement('div');
	chart_div.id = chart_id + "_"+"charts"
	parent_chart.appendChild(chart_div);

	if(filter_present === 'true'){

		unique_filter_html = renderFilter(data,filter_column_name,filter_div.id);
		$('#'+filter_div.id).html(unique_filter_html);

		$('#'+filter_div.id).change(function(){
			filter_val = $('#'+filter_div.id+' option:selected').val();
			parsed_data = filterChart(data,filter_column_name,filter_val);
			createChart(parsed_data, chart_div.id, chart_id,chart_api);
		});

		$("select#"+filter_div.id).prop('selectedIndex', 0);
    filter_val = $('#'+filter_div.id+' option:selected').val();
		parsed_data = filterChart(data,filter_column_name,filter_val);
		createChart(parsed_data, chart_div.id, chart_id,chart_api);
	}else{
		parsed_data = data;
		createChart(parsed_data, chart_div.id, chart_id,chart_api);
	}
}

var createChart = function (data,chart_id,chart_key,api) {
	var config = gon.chart_config_objects[chart_key] || {}
	config.data = data
	if (api == "handsontable")
		$("#"+chart_id).handsontable(config)
	else if (api == "one-number-indicator") {
		renderHTMLForCard(data, chart_id,"col-sm-12");
	} else {
		initializer_api = getApiFromString(api);
		config.selector = "#"+chart_id
		config.background_color = ""
		var k = new initializer_api(config)
		k.execute();
	}
};

$(document).ready(function() {
  $("time.timeago").timeago();
});
