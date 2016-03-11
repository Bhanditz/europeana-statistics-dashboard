//Load automated charts.
Rumali.autoCharts = (function(){
	//Global objects to be used within  aggregators report.
	var chart_data = {},
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
		// loadYearMenuBar();//year filter
		// loadQuarterMenuBar();//quarter filter
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
			//renderHTMLForTable(table_json,i);
		}
		loadTop10digitalObject(gon.top_digital_objects,(gon.selected_year-1).toString());
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
				//Api for fetching the data.
      	tooltip_enable: "yes", //enabling tool tip for the gven chart
      	//shade_color: "#1A8AC7","#095F90","#4BC0F0"]
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

			var chartobj = new PykCharts.oneD.electionDonut(
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
					//chart_color: ["#B0E2FF","#60AFFE"],
					chart_color: ["#1A8AC7","#095F90","#4BC0F0"],
					data_sort_enable: "no",
					axis_x_time_value_datatype:"month",
					chart_width: 1200
				};
			var chartobj = new PykCharts.multiD.multiSeriesLine(
						loadonedmap_obj
					);

			chartobj.execute();
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
			      	//palette_color:"Red",
			      	//total_no_of_colors: 5,
			      	default_color:["#E4E4E4"],//,
					    color_mode: "saturation",
							//chart_color: ["#B0E2FF","#60AFFE"],
							saturation_color: "#4BC0F0",

			      	// saturation_color: "#255AEE",
			      	// color_mode: "saturation"
				};

			var chartobj = new PykCharts.maps.oneLayer(
						loadonedmap_obj
					);

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
		var month_arr = ['January','February','March','April','May','June','July','August','September','October','November','December'], i,prev_year = gon.selected_year - 1,current_month_index = month_arr.indexOf(gon.current_month) + 2,
			selector = "#"+ $(obj).attr('id'),
			filter_data;

		$("select.js-filter_top_digital_objects").on('change',function (){
			debugger;
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
			renderHTMLForDigitalObj(transformFilterData(filter_data));
		}

		var renderHTMLForDigitalObj = function(data){
			//var source = $("#top25-template").html(),
			var source = '{{#each this}}<li><div class="listitem media"><img class="listitem-image media-figure" src="{{ image_root }}{{ image }}" alt="{{ title }}"><div class="media-body">{{#if url}}<a href="{{ url }}"><h3>{{ title }}</h3></a>{{else}}<h3>{{ title }}</h3>{{/if}}<div class="listitem-text">{{ description }}</div>{{#if extra }}<div class="listitem-extra">{{ extra }}</div>{{/if}}</div></div></li>{{/each}}',
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
		filterData(gon.top_digital_objects,filter_details);
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

	var renderHTMLForTable = function(data,id){
		var i =0,
			title = '',
			rank_for_country = '',
			rank_for_country_diff = '',
			rank_for_europeana = '',
			rank_for_europeana_diff = '',
			value = '',
			is_positive_diff = '',
			diff_value = '',
			value_contribution_for_country = '',
			value_contribution_for_europeana = '',
			htmlcontent = '';

		htmlcontent += '<span class = "col-sm-12 box_layout border_top">';
		htmlcontent += '<span class = "col-sm-12 box_layout_header_span">';
		htmlcontent += '<span class = "col-sm-3 box_layout_header"><b>Metric';
		htmlcontent += '</b></span>';
		htmlcontent += '<span class = "col-sm-4 box_layout_header"><b>Rank';
		htmlcontent += '</b></span>';
		htmlcontent += '<span class = "col-sm-5 box_layout_header"><b>Value';
		htmlcontent += '</b></span>';
		htmlcontent += '</span>';
		htmlcontent += '<span class = "col-sm-12">';
		htmlcontent += '<span class = "col-sm-3"></span>';
		/* Add it when it is applied
			htmlcontent += '<span class = "col-sm-4 box_layout_header_subtitle">Country/Europeana</span>';
		*/
		htmlcontent += '<span class = "col-sm-4 box_layout_header_subtitle">Europeana</span>';
		htmlcontent += '</span>';

		//running loop for each row within the html

		for(i=0;i<data.length;i++){

			title = data[i].metric;
			rank_for_europeana = data[i].rank_for_europeana;
			rank_for_europeana_diff = data[i].diff_in_rank_for_europeana;
			value = data[i].value_of_last_month;
			value_contribution_for_europeana = data[i].contribution_to_europeana;
			diff_value = data[i].diff_value;
			htmlcontent += '<span class = "col-sm-12 border_top">';
			htmlcontent += '<span class = "col-sm-3 text-center">';
			//Title logic
			htmlcontent += utility.renderHTMLforTableTitle(title);

			htmlcontent += '</span>';

			htmlcontent += '<span class = "col-sm-4 text-center">';
			//Ranking logic
			htmlcontent += renderHTMLforTableRank(rank_for_country,rank_for_country_diff,rank_for_europeana,rank_for_europeana_diff);

			htmlcontent += '</span>';

			htmlcontent += '<span class = "col-sm-5 text-right">';
			//value logic
			htmlcontent += renderHTMLforTableValue(value,diff_value,value_contribution_for_country,value_contribution_for_europeana);
			htmlcontent += '</span>';

			htmlcontent += '</span>';

		}

		htmlcontent += '<span class = "col-sm-12 border_top box_layout_header_subtitle">';
		htmlcontent += '* % in value indicates contribution to Europeana.';
		htmlcontent += '</span>';

		htmlcontent += '</span>';

		$('#'+id).html(htmlcontent);
		$('.positive_value_css').tooltip();
		$('.negative_value_css').tooltip();
	}

	//Rendering string for rank column only
	var renderHTMLforTableRank = function(rank_for_country,rank_for_country_diff,rank_for_europeana,rank_for_europeana_diff){
		var string = '<span class="col-sm-12">';
		string += '<span class="important_val">';
		string += rank_for_europeana + '</span>(' ;
		if(rank_for_europeana_diff > 0){
			string += '<span class="'+utility.applyConditionalCssPositiveOrNegative(Rumali.object.value_change.negative)+'">';
			string += rank_for_europeana_diff + ' &#9660;';
		}
		else if(rank_for_europeana_diff < 0){
			string += '<span class="'+utility.applyConditionalCssPositiveOrNegative(Rumali.object.value_change.positive)+'">';
			string += (rank_for_europeana_diff*-1)+ ' &#9652;';
		}
		else{
			string += '<span class="'+utility.applyConditionalCssPositiveOrNegative(Rumali.object.value_change.no_change)+' ">';
			string += (rank_for_europeana_diff*-1)+ ' -';
		}

		string += '</span>';
		string += ')';

		string += '</span>';
		return string;
	}

	//Rendering html for value table
	var renderHTMLforTableValue = function(value,diff_value,value_contribution_for_country,value_contribution_for_europeana){
		var string = '<span class="col-sm-12">';
		var cond_class = '';
		if(+diff_value > 0){
			cond_class = utility.applyConditionalCssPositiveOrNegative(Rumali.object.value_change.positive);
		}
		else if(+diff_value < 0){
			cond_class = utility.applyConditionalCssPositiveOrNegative(Rumali.object.value_change.negative);
		}
		else{
			cond_class = utility.applyConditionalCssPositiveOrNegative(Rumali.object.value_change.no_change);
		}
		string += '<span class='+cond_class+' data-toggle="tooltip" data-placement="bottom" data-original-title="'+utility.calculateChangeFromPreviousValue(value,diff_value)+'">';
		string += utility.applyConditionalFormatting(value);
		string += '</span>(';
		//assiging value and conditional css to it.
		/* Add it later
		string += '('+(value_contribution_for_country)+'% / '
		*/
		string += value_contribution_for_europeana+'% )';
		string += '</span>';
		return string;
	}

	var filterTopDigitalObjectsData = function(filter_details){
		loadTop10digitalObject(gon.top_digital_objects,filter_details);
	};

	return{
		loadReportChart:loadReportChart,
		filterTopDigitalObjectsData:filterTopDigitalObjectsData,
	}
}());