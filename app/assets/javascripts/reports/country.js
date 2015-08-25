var country_chart_data;
var current_year ;

Rumali.buildMultiLineChart = function (){
	
	var multi_series_line = $('#rijksmuseum_-_line_chart');
	loadMultiSeriesLine(multi_series_line[0]);
}

var loadMultiSeriesLine = function(obj){

	var selector = "#"+ $(obj).attr('id'),
		filter_data;

	var filterData = function(data){

		current_year = gon.selected_year;

		if(!country_chart_data){

			country_chart_data = data;
			//Setting up country data
		}

		filter_data = _.filter(country_chart_data, function(obj){ 

			return ((+obj.year  === current_year)||(+obj.year === current_year - 1))  });

		if(data.length <= 0){
			createErrorDiv($(obj).attr('id'));
		}
		else{
			removeErrorDiv($(obj).attr('id'));
		}

		callPykChart(filter_data);	
		
	}

	var callPykChart = function(data){

		console.log(data);

		var loadonedmap_obj = {
				selector: selector,//Getting id for the element as expected by the pykihcharts.
				data:data,
				chart_color: ["#B0E2FF","#60AFFE"],
				data_sort_enable: "no",
				axis_x_time_value_datatype:"month",
				chart_width:700
			};

		var chartobj = new PykCharts.multiD.multiSeriesLine(
					loadonedmap_obj
				);

		chartobj.execute(); 
	}

	if(!country_chart_data){
		getJSON(rumi_api_endpoint + 'datacast/'+ obj.dataset.datacast_identifier,this,filterData);		
	}
	else{
		filterData(country_chart_data);
	}


	

}



