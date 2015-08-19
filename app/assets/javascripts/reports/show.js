
var chart_data = {};
chart_data.onelayer =[];

Rumali.buildCharts = function () {
	//Loading all the charts with .d3-pykcharts as a class.
	chart_data.charts = $('.d3-pykcharts')

	var charts_length = chart_data.charts.length, 
		index = 0;

	chart_data.year_no = gon.selected_year;
	chart_data.quarter_no = gon.selected_quarter;

	loadYearMenuBar();
	loadQuarterMenuBar();

	for(;index<charts_length;index++){
		var api_data = chart_data.charts[index].dataset.api; //Getting api data attribute of the chart
		switch(api_data){ //calling function to render the chart as per the data attribute value.
			case 'PykCharts.oneD.pie':
				loadOnedPie(chart_data.charts[index],chart_data.year_no,chart_data.quarter_no);//load one d pie chart
				break;
			case 'PykCharts.multiD.column':
				loadMultiDCol(chart_data.charts[index],chart_data.year_no,chart_data.quarter_no); //loading multi d column chart 
				break;
			case 'PykCharts.multiD.groupedColumn':
				loadMultiDGroupedCol(chart_data.charts[index],chart_data.year_no,chart_data.quarter_no); //loading multi d grouped column chart 
				break;
			case 'PykCharts.maps.oneLayer':
				loadMapOneLayer(chart_data.charts[index],chart_data.year_no,chart_data.quarter_no);
				break;
			default:
				break;
		}
	} 	
}


//Set up the data for one d chart and then call function for pykchart.
var loadOnedPie = function(obj,year,quarter){
	var selector = "#"+ $(obj).attr('id');

	var filterData = function(data,year,quarter){

		if(!chart_data.onedpie){
			chart_data.onedpie = data;
		}

		callPykChart(data);
	}
	
	var callPykChart = function(data){
		var oned_obj = {
			selector: selector,//Getting id for the element as expected by the pykihcharts.
			data:data,
			//Api for fetching the data.
	      	chart_width: 400,
	      	export_enable: "no",
	      	tooltip_enable: "yes" //enabling tool tip for the gven chart
			};

		var chartobj = new PykCharts.oneD.pie(
				oned_obj
			);

		chartobj.execute(); 
	}

	if(!chart_data.onedpie){
		getJSON(rumi_api_endpoint + 'datacast/'+ obj.dataset.datacast_identifier,this,filterData);		
	}
	else{
		filterData(chart_data.onedpie,year,quarter);
	}	
}

//Set up the data for multi d chart and then call the function for pykchart no filters required
var loadMultiDCol = function(obj,year,quarter){
	var selector = "#"+ $(obj).attr('id');

	var filterData = function(data,year,quarter){

		if(!chart_data.multidcol){
			chart_data.multidcol = data;
		}
		callPykChart(data);
	}

	var callPykChart = function(data){

		var multid_obj = {
			selector: selector,//Getting id for the element as expected by the pykihcharts.
			data:data,
			//Api for fetching the data.
	      	export_enable: "no",//don't enable export
	        axis_x_pointer_position: "bottom", //put x-axis at bottom
	        tooltip_enable: "yes", //enabling tool tip for the gven chart
	        chart_width: 400
			};

		var chartobj = new PykCharts.multiD.column(
				multid_obj
			);

		chartobj.execute(); 
	}	
	
	if(!chart_data.multidcol){
		getJSON(rumi_api_endpoint + 'datacast/'+ obj.dataset.datacast_identifier,this,filterData);		
	}
	else{
		filterData(chart_data.multidcol,year,quarter);
	}
}

//Set up the data for multi d grouped chart and then call the function for pykchart
//Here year filter is applicable
var loadMultiDGroupedCol =  function(obj,year,quarter){

	var selector = "#"+ $(obj).attr('id'),
	filter_data;

	var filterData = function(data,year,quarter){

		if(!chart_data.multidgroupcol){
			chart_data.multidgroupcol = data; //Saving the data once so that we don't need to call service again.
		}
		filter_data = _.filter(chart_data.multidgroupcol, function(obj){ return obj.aggregation_level_value.split("_")[0]  == year; });
		
		filter_data = _.sortBy(filter_data,'aggregation_level_value');		

		callPykChart(filter_data);
	}

	var callPykChart = function(data){

		var multidgrouped_obj = {
			selector: selector,//Getting id for the element as expected by the pykihcharts.
			data:data,
			//Api for fetching the data.
	      	export_enable: "no",
	      	axis_x_pointer_position: "bottom", //put x-axis at bottom
	      	tooltip_enable: "yes" //enabling tool tip for the gven chart
			};

		var chartobj = new PykCharts.multiD.groupedColumn(
				multidgrouped_obj
			);

		chartobj.execute(); 
	}

	if(!chart_data.multidgroupcol){
		getJSON(rumi_api_endpoint + 'datacast/'+ obj.dataset.datacast_identifier,this,filterData);		
	}
	else{
		filterData(chart_data.multidcol,year,quarter);
	}
}

var loadMapOneLayer = function (obj,year,quarter) {

	var selector = "#"+ $(obj).attr('id'),
		quarter_val;

	var filterData = function(data,year,quarter){

		//If future data is being fetched show current record instead.
		while(year >= gon.selected_year && quarter > gon.selected_quarter){
			quarter--;
			if(quarter < 0){
				year--;
				quarter = gon.selected_quarter;
			}
		}

		chart_data.year_no = year;
		chart_data.quarter_no = quarter;

		quarter_val = 'Q'+quarter;

		if(!chart_data.maps){
			chart_data.maps = data
		}


		if(!chart_data.onelayer[year]){
			chart_data.onelayer[year]=[];
		}
		if(!chart_data.onelayer[year][quarter]){
			chart_data.onelayer[year][quarter] = {};

			filter_data = _.filter(chart_data.maps, function(obj){ return ((obj.aggregation_level_value.split("_")[0]  == year) && (obj.aggregation_level_value.split("_")[1]  == quarter_val)) });
			filter_data = _.sortBy(filter_data,'aggregation_level_value');
			filter_data = _.first(filter_data,25);

			chart_data.onelayer[year][quarter] = filter_data;

		}
		//We need to show only top 25 countries.
		callPykChart(chart_data.onelayer[year][quarter]);
	}

	var callPykChart = function(data){

		var loadonedmap_obj = {
				selector: selector,//Getting id for the element as expected by the pykihcharts.
				data:data,
				//Api for fetching the data.
		      	export_enable: "no",
		      	map_code: "world",
		      	chart_height: 400,//height of the chart
		      	tooltip_enable: "yes", //enabling tool tip for the gven chart
		      	palette_color:"Green-4",
		      	total_no_of_colors: 5
			};

		var chartobj = new PykCharts.maps.oneLayer(
					loadonedmap_obj
				);

		debugger;
		chartobj.execute();
		debugger; 
	}
	
	if(!chart_data.maps){
		getJSON(rumi_api_endpoint + 'datacast/'+ obj.dataset.datacast_identifier,this,filterData);		
	}
	else{
		filterData(chart_data.maps,year,quarter);
	}
}


//Set up the data json once so that we don't need to call service again.It is saved in return_data object
var getJSON = function(url,context,callbackfn){
	$.getJSON(url) //jquery function to parse url and get data in done method.
		.done(function(data){
			callbackfn(data,gon.selected_year,gon.selected_quarter);
		});
}

//Load the loadMultiDGroupedCol and loadMapOneLayer for the passed year no
var filterDataYear = function(year_no){
	chart_data.year_no = year_no;
	loadMultiDGroupedCol(chart_data.charts[2],chart_data.year_no,chart_data.quarter_no);
	loadMapOneLayer(chart_data.charts[3],chart_data.year_no,chart_data.quarter_no);
}

//Load year filter
var loadYearMenuBar = function(){
	var initial_year = 2012;//Assumption that data will be coming only 2012 onwards so as to save on performance hit.
	var final_year = gon.selected_year;
	var html_string = '';
	for(var year_no = initial_year;year_no <= final_year;year_no++){//apply space after using style guide
		html_string = html_string + '<span id = id_year_filters_yearno_'+year_no+' onclick="filterDataYear('+
			year_no+')">'+year_no+'</span>';
	}
	document.getElementById('id_year_filters').innerHTML = html_string;
}

var filterQuarterData = function(quarter_no){
	chart_data.quarter_no = quarter_no;
	loadMapOneLayer(chart_data.charts[3],chart_data.year_no,chart_data.quarter_no);	
}

//Load quarter filter
var loadQuarterMenuBar = function(){
	var html_string = '';
	html_string = '<span id = id_quarter_filters_quarterno_1 onclick="filterQuarterData(1)">Q1</span>'
				+'<span id = id_quarter_filters_quarterno_2 onclick="filterQuarterData(2)">Q2</span>'
				+'<span id = id_quarter_filters_quarterno_3 onclick="filterQuarterData(3)">Q3</span>'
				+'<span id = id_quarter_filters_quarterno_4 onclick="filterQuarterData(4)">Q4</span>'; 
	document.getElementById('id_quarter_filters').innerHTML = html_string;
}
