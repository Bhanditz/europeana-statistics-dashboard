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
//Render dropdown less than or equal to 5
var smallDropDown = function(id,values,length){
	var html_string = '<select id='+id+' class="form-control" style="width:12.5%!important">';
		for(i=0;i<length;i++){
			html_string += '<option value="'+values[i]+'">'+values[i];
		}
		html_string += '</select>';
		return html_string;
}

//Render dropdown greater than 5
var largeDropDown = function(id,values,length){
	var html_string = '<select id='+id+' class="form-control" style="width:12.5%!important">';
		for(i=0;i<length;i++){
			html_string += '<option value="'+values[i]+'">'+values[i];
		}
		html_string += '</select>';
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


var renderHTMLForCard = function(data,id){

	//id,title,key,value,content
	var id = id,
		title = data[0].title ? data[0].title : '',
		key = data[0].key ? data[0].key : '<br/>',
		value = data[0].value ? data[0].value : '',
		content = data[0].content ? data[0].content : '';
		diff_in_value = data[0].diff_in_value ? data[0].diff_in_value : '' ,
		diff_string = '';

	if(typeof +value === "number"){
		value = +value;
		value = applyConditionalFormatting(value);
	}
	if(typeof +diff_in_value === 'number'){
		if(+diff_in_value > 0){
			diff_string = '(<span class="'+applyConditionalCssPositiveOrNegative(1)+'">'+diff_in_value;
			diff_string +=  '&#9652;</span>)';
		}
		if(+diff_in_value < 0){
			diff_string = '(<span class="'+applyConditionalCssPositiveOrNegative(2)+'">'+((+diff_in_value)*-1);
			diff_string +=  '&#9660;</span>)';
		}
		if(+diff_in_value === 0){
			diff_string = '(<span class="'+applyConditionalCssPositiveOrNegative(3)+'">'+diff_in_value;
			diff_string += '-</span>)';
		}
	}


	var div = $('<div />').appendTo('body');
	div.attr('id', id);
	var htmlcontent = '<span class = "col-sm-4 card_layout">';
	htmlcontent += '<span class= "col-sm-12 card_layout_header_span"><h4 class="card_layout_header"><b>'+title+'</b></h4></span>';
	htmlcontent += '<span class= "col-sm-12 card_layout_key">'+key+'</b></span>';
	htmlcontent += '<span class= "col-sm-12 card_layout_value">'+value+'</b>';
	if(diff_in_value !== ''){
		htmlcontent +=  diff_string;
	}
	htmlcontent += '<span class= "col-sm-12 card_layout_content">'+content;
	htmlcontent += '</span>';

	$('#'+id).html(htmlcontent);
}

var applyConditionalFormatting = function(value){
		var result = value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		return result;
}
var applyConditionalCssPositiveOrNegative = function(value){
		if(value === 1){
			return 'positive_value_css';
		}
		else if(value === 2){
			return 'negative_value_css';
		}
		else if(value === 3){
			return 'no_class';
		}
		else{
			return 'no_class';
		}
		//Convert it to switch case
}
var filterChart = function(data,column_name,column_value){
	var index,filtered_data = [],count=-1;
	for(index = 0;index < data.length;index++){
			if(column_value === data[index][column_name]){
				filtered_data[++count] = {};
				for(var k in data[index]){
					if(k !== column_name){
						filtered_data[count][k]=data[index][k];
						//Copying all the items from original array to new array.
						//value to be pushed in the new array
				}
			} 	//Filter data is the data that is to be displayed on the ui.
		}
	}
	return filtered_data;
}

var getApiFromString = function(api){
  api = api.split(".");
  return PykCharts[api[1]][api[2]];
}

var genereteChartInMarkdown =  function () {
	$(".d3-pykcharts").each(function (){
    var chart_id = this.id,
			datacast_url = Rumali.object.datacast_url + this.dataset.datacast_identifier,
      chart_api = this.dataset.api,
      filter_present = this.dataset.filter_present,
      filter_column_name = this.dataset.filter_column_name || "";
    getJSON(datacast_url,generateChart,chart_id ,chart_api, filter_present, filter_column_name);
  });
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
	else if (api == "one-number-api") {
		alert("hi")
	} else {
		initializer_api = getApiFromString(api);
		config.selector = "#"+chart_id
		var k = new initializer_api(config)
		k.execute();
	}
};