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