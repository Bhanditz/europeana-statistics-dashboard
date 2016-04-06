Rumali.object = {
	//dictionary for positive, negative and no-change values
	value_change : {
		positive: 1,
		negative: 2,
		no_change:0
	},

	//url first half
	datacast_url : rumi_api_endpoint + 'datacast/'

}
Rumali.utility = (function () {


	var getJSONForCard = function(url,id,callbackfn){
		$.getJSON(url) //jquery function to parse url and get data in done method.
			.done(function(data){
				callbackfn(data,id);
			});
	}



	var renderHTMLforTableTitle = function(title){
		var string = '<span class="col-sm-12">';
		string += title;
		string += '</span>';
		return string;
	}

	//Set up the data json once so that we don't need to call service again.It is saved in return_data object
	var getJSON = function(url,context,callbackfn){
		$.getJSON(url) //jquery function to parse url and get data in done method.
			.done(function(data){
					callbackfn(data,(parseInt(gon.selected_year,10)).toString());
			});
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
			return '';
		}
		else{
			return '';
		}
		//Convert it to switch case
	}


	var calculateChangeFromPreviousValue = function(value,diff_value){

		var tooltip = (+diff_value/((+value)-(+diff_value)) * 100).toFixed(2)
		tooltip += '% change from the previous month.';
		//rendering html for the tooltip.


		return tooltip;
	}

	var tooltipLayout = function(value){
		var tooltip = value;
		tooltip += '% change from the previous month.';
		//rendering html for the tooltip.


		return tooltip;
	}

	//getting json for the table(box)
	var getJSONforTable = function(url,id,callbackfn){
		$.getJSON(url) //jquery function to parse url and get data in done method.
			.done(function(data){
					callbackfn(data,id);
		});
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

	//finding distinct values of the attributes from the array that is being passed.
	var findDistinct = function(data,attribute_name){
		var value = [];
		value = _.map(data, function(obj){ return obj[attribute_name] });
		value = _.uniq(value);
		return value;
	}

	//filtering the data as per the attribute that is being passed.
	var filterData = function(data,attribute_name,attribute_value){
		var value = [];
		value = _.filter(data, function(obj){
			return obj[attribute_name] === attribute_value;
		});
		return value;
	}

	//Setting htmlheader
	var setHTMLheaderForChart = function(content,id){
		var htmlcontent = '';
		htmlcontent += '<h2 class = chart_header>'+content+'</h2>';
		$(id).html(htmlcontent);
	}

	//Render dropdown less than or equal to 5
	var smallDropDown = function(id,values,length){
		var html_string = '<select id='+id+' class="filter">';
 		for(i=0;i<length;i++){
 			html_string += '<option value="'+values[i]+'">'+values[i];
   		}
   		html_string += '</select>';
   		return html_string;
	}

	//Render dropdown greater than 5
	var largeDropDown = function(id,values,length){
		var html_string = '<select id='+id+' class="filter">';
 		for(i=0;i<length;i++){
 			html_string += '<option value="'+values[i]+'">'+values[i];
   		}
   		html_string += '</select>';
   		return html_string;
	}

	return{
		getJSONForCard:getJSONForCard,
		renderHTMLforTableTitle:renderHTMLforTableTitle,
		getJSON:getJSON,
		applyConditionalFormatting:applyConditionalFormatting,
		applyConditionalCssPositiveOrNegative:applyConditionalCssPositiveOrNegative,
		calculateChangeFromPreviousValue:calculateChangeFromPreviousValue,
		getJSONforTable:getJSONforTable,
		tooltipLayout:tooltipLayout,
		renderFilter:renderFilter,
		findDistinct:findDistinct,
		filterData:filterData,
		setHTMLheaderForChart:setHTMLheaderForChart,
		smallDropDown:smallDropDown,
		largeDropDown:largeDropDown
	}
}());