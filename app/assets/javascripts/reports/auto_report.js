//Load automated charts.
Rumali.autoCharts = (function(){
	//Global objects to be used within  aggregators report.
	var chart_data = {},
	// Top digital object variable
	 top_digital_objects,
	//Loading all the table boxes
		table_data = {},
	//Utility class have functions which have common functions
		utility = Rumali.utility,
		global_obj = Rumali.object,
		country_chart_data = "";
		chart_data.onelayer =[];
	var loadReportChart = function(){
		//These are the classes applied by ruby, we need to apply content to these classes.
		chart_data.charts = $('.d3-pykcharts');//pykcharts
		table_data.tables = $('.box_table');//tables within boxes.
		var charts_length = chart_data.charts.length,
			index = 0,
			digital_api,
			id,
			table_length = table_data.tables.length;
		chart_data.year_no = gon.current_year;
		chart_data.month = gon.current_month;

		//loop to consider pykih charts loop
		for(;index<charts_length;index++){
			var api_data = chart_data.charts[index].dataset.api; //Getting api data attribute of the chart
			switch(api_data){ //calling function to render the chart as per the data attribute value.
				case 'PykCharts.oneD.pie'://pie chart
					loadOnedPie(chart_data.charts[index]);//load one d pie chart
					break;
				case 'PykCharts.oneD.donut':
				case 'PykCharts.oneD.electionDonut':
					loadOnedDonut(chart_data.charts[index]);//load one d pie chart
					break;

				case 'PykCharts.multiD.column'://multi-dimensional column chart.
					loadMultiDCol(chart_data.charts[index]); //loading multi d column chart
					break;
				case 'PykCharts.multiD.multiSeriesLine':
					loadMultiSeriesLine(chart_data.charts[index]);
					break;
				case 'PykCharts.maps.oneLayer'://topojson chart.
					loadMapOneLayer(chart_data.charts[index]);
					break;
				default:
					break;
			}
		}
		index = 0;
		for(;index<table_length;index++){//rendering a table.
			id = table_data.tables[index].id;
			//id which specifies on which html tag table needs to be rendered.
			utility.getJSONforTable(global_obj.datacast_url+table_data.tables[index].dataset.datacast_identifier,id,renderHTMLForTable);
		}
		Handlebars.registerHelper('trimString', function(passedString) {
			if(!passedString){
				return "";
			}
			return passedString.length > 10 ? passedString : passedString.substring(0,10) + "...";
		});
		$('select#filter-year-select option[value="'+gon.selected_year+'"]').prop("selected",true);
		utility.getJSON(rumi_api_endpoint + 'datacast/'+ gon.top_digital_objects_identifier,"",loadTop10digitalObject);
	};
	//Set up the data for one d chart and then call function for pykchart.
	var loadOnedPie = function(obj){

		var selector = "#"+ $(obj).attr('id');

		var filterData = function(data,filter_details){

			if(!chart_data.onedpie){
				chart_data.onedpie = data;
			}

			if(data.length <= 0){
				createErrorDiv($(obj).attr('id'));
			}
			else{
				removeErrorDiv($(obj).attr('id'));
			}

			callPykChart(data);

		}

		var callPykChart = function(data){
			var oned_obj = {
				selector: selector,//Getting id for the element as expected by the pykihcharts.
				data:data,
				tooltip_enable: "yes", //enabling tool tip for the gven chart
      	shade_color: "#4BC0F0",
      	"pointer_size": 28,
      	"label_size": 28,
			};
			var chartobj = new PykCharts.oneD.pie(
					oned_obj
				);

			chartobj.execute();
		}
		if(!chart_data.onedpie){
			utility.getJSON(global_obj.datacast_url+ obj.dataset.datacast_identifier,this,filterData);
		}
		else{
			filterData(chart_data.onedpie);
		}
	};

	var loadOnedDonut = function(obj){

		var selector = "#"+ $(obj).attr('id');

		var filterData = function(data,filter_details){

			if(!chart_data.onedpie){
				chart_data.onedpie = data;
			}

			if(data.length <= 0){
				createErrorDiv($(obj).attr('id'));

			}
			else{
				removeErrorDiv($(obj).attr('id'));
			}

			callPykChart(data);

		}

		var callPykChart = function(data){
			var oned_obj = {
				selector: selector,//Getting id for the element as expected by the pykihcharts.
				data:data,
				//Api for fetching the data.
	      	tooltip_enable: "yes",//enabling tool tip for the gven chart
					shade_color: "#4BC0F0",
					"pointer_size": 25,
    			"label_size": 25,
    			"donut_show_total_at_center_size": 30,
				};

			var chartobj = new PykCharts.oneD.donut(
					oned_obj
				);

			chartobj.execute();
		}
		if(!chart_data.onedpie){
			utility.getJSON(global_obj.datacast_url+ obj.dataset.datacast_identifier,this,filterData);
		}
		else{
			filterData(chart_data.onedpie);
		}
	};
	//Set up the data for multi d chart and then call the function for pykchart no filters required
	var loadMultiDCol = function(obj){
		var selector = "#"+ $(obj).attr('id');

		var filterData = function(data,filter_details){

			if(!chart_data.multidcol){
				chart_data.multidcol = data;
			}

			if(data.length <= 0){
				createErrorDiv($(obj).attr('id'));
			}
			else{
				removeErrorDiv($(obj).attr('id'));
			}

			callPykChart(data);
		}

		var callPykChart = function(data){

			var multid_obj = {
				selector: selector,//Getting id for the element as expected by the pykihcharts.
				data:data,
				//Api for fetching the data.
		    tooltip_enable: "yes", //enabling tool tip for the gven chart
		    axis_x_tick_format: "string",
		    chart_color: ["#009413"]
		   };

			var chartobj = new PykCharts.multiD.column(
					multid_obj
				);

			chartobj.execute();
		}

		if(!chart_data.multidcol){
			//If data is not available then call the database to fetch the data.
			utility.getJSON(global_obj.datacast_url+ obj.dataset.datacast_identifier,this,filterData);
		}
		else{
			filterData(chart_data.multidcol);
		}
	};
	//Set up the data for multi d grouped chart and then call the function for pykchart

	var loadMultiSeriesLine = function(obj){

		var selector = "#"+ $(obj).attr('id');

		var callPykChart = function(data,filter_details){
			var loadonedmap_obj = {
					selector: selector,//Getting id for the element as expected by the pykihcharts.
					data:data,
					color_mode: "color",
					chart_color: ["#1A8AC7","#095F90","#4BC0F0"],
					data_sort_enable: "no",
					axis_x_time_value_datatype:"month",
					chart_width: 1200
				};
			var chartobj = new PykCharts.multiD.multiSeriesLine(
						loadonedmap_obj
					);

			chartobj.execute();

			document.getElementById($(obj).attr('id')).style.width = "100%";
			var resize = chartobj.k.resize(chartobj.svgContainer);
        chartobj.k.__proto__._ready(resize);
        window.addEventListener('resize', function(event){
            return chartobj.k.resize(chartobj.svgContainer);
        });


		}

		if(!country_chart_data){
			utility.getJSON(rumi_api_endpoint + 'datacast/'+ obj.dataset.datacast_identifier,this,callPykChart);
		}
		else{
			callPykChart(country_chart_data);
		}
	};

	var loadMapOneLayer = function (obj) {

		var selector = "#"+ $(obj).attr('id');

		var callPykChart = function(data,filter_details){

			var loadonedmap_obj = {
					selector: selector,//Getting id for the element as expected by the pykihcharts.
					data:data,
					//Api for fetching the data.
	      	export_enable: "no",
	      	map_code: "world",
	      	chart_height: '700',//height of the chart
	      	chart_width:'1000',
	      	tooltip_enable: "yes", //enabling tool tip for the gven chart
	      	default_color:["#E4E4E4"],
			    color_mode: "saturation",
					saturation_color: "#4BC0F0"
				};

			var chartobj = new PykCharts.maps.oneLayer(loadonedmap_obj);
			chartobj.execute();
		}

		if(!chart_data.maps){
			utility.getJSON(global_obj.datacast_url+ obj.dataset.datacast_identifier,this,callPykChart);
		}
		else{
			callPykChart(chart_data.maps);
		}
	};

	//Function to load top 10 digital objects.
	var loadTop10digitalObject = function(obj,filter_details){
		top_digital_objects = top_digital_objects || obj;
		var month_arr = ['January','February','March','April','May','June','July','August','September','October','November','December'], i,prev_year = gon.selected_year - 1,current_month_index = month_arr.indexOf(gon.current_month) + 2,
			selector = "#"+ $(obj).attr('id'),
			filter_data;
		$("select.js-filter_top_digital_objects").on('change',function (){
			var month_gt_current_month = $("select#filter-month-select").find("option:gt("+current_month_index+")"),
			year = $('select#filter-year-select option:selected').val(),
			selected_month =  $('select#filter-month-select option:selected'),
			month = selected_month.val()	;
			if(year == gon.selected_year) {
				month_gt_current_month.each(function(){$(this).prop("disabled",true)});
				if( month_gt_current_month.first().index() < selected_month.index() ){
					month = '';
					$('select#filter-month-select').find("option").first().prop("selected",true)
				}
			} else {
				if (month_gt_current_month[0].disabled == true) {
			   	month_gt_current_month.each(function(){$(this).prop("disabled",false)});
				}
			}
			filter = year;
			if (typeof month !== "undefined" && month !== "") {
				filter  += '_'+  month;
			}
			Rumali.autoCharts.filterTopDigitalObjectsData(filter);
		});

		var filterData = function(data,filter_details){
			function aggregate_data(data, aggregate_by, aggregate_on) {
				var grouped_data = _.groupBy(data, function(obj) { return obj[aggregate_by]; }),
					keys = Object.keys(grouped_data),
					group,
					value,
					aggregated_data = [];
				for(var i =0, length = keys.length; i < length; i++) {
					group = grouped_data[keys[i]];
					value = _.reduce(group, function(memo, obj){ return memo + parseInt(obj[aggregate_on], 10); }, 0);
					var clone = JSON.parse(JSON.stringify(group[0]))
					clone[aggregate_on] = value + "";
					aggregated_data.push(clone);
				}
				return aggregated_data;
			}

			var year = filter_details.split("_")[0],
				month = filter_details.split("_")[1];

			if (typeof month !== "undefined") {
				filter_data = _.filter(data, function(obj){ return (obj.year  == year) && (obj.month == month)});
			} else {
				filter_data = _.filter(data, function(obj){ return (obj.year  == year)});
				filter_data = aggregate_data(filter_data, "title_url", "value");
			}

			filter_data = _.sortBy(filter_data,function(obj){
				return parseInt(obj.value)*-1;
			});
			filter_data = _.first(filter_data,25);
			filter_data.forEach(function(d){ if(d.title){d.title = (d.title.length < 125? d.title : d.title.substring(0,125) + "...");}});
			renderHTMLForDigitalObj(transformFilterData(filter_data));
		}

		var renderHTMLForDigitalObj = function(data){
			var source = $("#top25-template").html();
			template = Handlebars.compile(source);
			$("ol.results-list").html(template(data));
		}

		//setting up inner html content for the top 10 digital items
		var transformFilterData = function(data){
			var transformed_object = []
			for(var i=0,length=data.length;i<length;i++){
				var obj = {}
				obj.title = data[i].title
				obj.image = data[i].image_url
				obj.url = data[i].title_url
				obj.extra = "Views: "+ data[i].value
				transformed_object.push(obj)
			}
			return transformed_object;
		}
		filterData(top_digital_objects,filter_details);
	};

	//Load error div in case data is not present
	var createErrorDiv = function(selector,custommesg){
		removeErrorDiv(selector);
		var defaultmesg = 'Data not available';
		var error_html =  "<span id=error_"+selector+">"+(custommesg ? custommesg : defaultmesg)+"</span>";
		$(error_html).insertBefore("#"+selector);
	};

	//removing a div for error
	var removeErrorDiv = function(selector){
		$('#error_'+selector).remove();
	};

	var filterTopDigitalObjectsData = function(filter_details){
		loadTop10digitalObject(top_digital_objects,filter_details);
	};

	return{
		loadReportChart:loadReportChart,
		filterTopDigitalObjectsData:filterTopDigitalObjectsData,
	}
}());