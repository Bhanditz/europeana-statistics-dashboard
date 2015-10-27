//Load automated charts.
Rumali.autoCharts = (function(){
	//Global objects to be used within  aggregators report.
	var chart_data = {},
		content_data = {},//data for the top 10 digital items,
	//Loading all the charts with .d3-pykcharts as a class.
		card_data = {},
	//Loading all the table boxes
		table_data = {},
	//Utility class have functions which have common functions
		utility = Rumali.utility,
		global_obj = Rumali.object,
		country_chart_data = "",
		current_year = 2012;
		chart_data.onelayer =[];
	var loadReportChart = function(){
		//These are the classes applied by ruby, we need to apply content to these classes.
		chart_data.charts = $('.d3-pykcharts');//pykcharts
		content_data.content = $('.top_digital_objects');//custom code
		card_data.cards = $('.card_with_value');//card layout
		table_data.tables = $('.box_table');//tables within boxes.

		var charts_length = chart_data.charts.length,
			index = 0,
			digital_api,
			cards_length = card_data.cards.length,
			table_length = table_data.tables.length;
		chart_data.year_no = gon.selected_year;
		chart_data.quarter_no = gon.selected_quarter;
		loadYearMenuBar();//year filter
		loadQuarterMenuBar();//quarter filter
		//loop to consider pykih charts loop
		for(;index<charts_length;index++){
			var api_data = chart_data.charts[index].dataset.api; //Getting api data attribute of the chart
			switch(api_data){ //calling function to render the chart as per the data attribute value.
				case 'PykCharts.oneD.pie'://pie chart
					loadOnedPie(chart_data.charts[index],chart_data.year_no,chart_data.quarter_no);//load one d pie chart
					break;
				case 'PykCharts.multiD.column'://multi-dimensional column chart.
					loadMultiDCol(chart_data.charts[index],chart_data.year_no,chart_data.quarter_no); //loading multi d column chart 
					break;
				case 'PykCharts.multiD.groupedColumn'://multi-dimensional grouped column chart.
					loadMultiDGroupedCol(chart_data.charts[index],chart_data.year_no,chart_data.quarter_no); //loading multi d grouped column chart 
					break;
				case 'PykCharts.multiD.multiSeriesLine':
					loadMultiSeriesLine(chart_data.charts[index]);
					break;
				case 'PykCharts.maps.oneLayer'://topojson chart.
					loadMapOneLayer(chart_data.charts[index],chart_data.year_no,chart_data.quarter_no);
					break;
				default:
					break;
			}
		}
		index = 0;
		for(;index<cards_length;index++){//rendering card layout.
			var id = card_data.cards[index].id;
			//common utlity function
			utility.getJSONForCard(global_obj.datacast_url+ card_data.cards[index].dataset.datacast_identifier,id,renderHTMLForCard);
		}
		index = 0;
		for(;index<table_length;index++){//rendering a table.
			var id = table_data.tables[index].id;
			//id which specifies on which html tag table needs to be rendered.
			utility.getJSONforTable(global_obj.datacast_url+table_data.tables[index].dataset.datacast_identifier,id,renderHTMLForTable);
			//renderHTMLForTable(table_json,i);
		}
		loadTop10digitalObject(content_data.content[0],chart_data.year_no,chart_data.quarter_no);
		//Get top 10 digital objects for the current year and quarter.
	}
	//Set up the data for one d chart and then call function for pykchart.
	var loadOnedPie = function(obj,year,quarter){

		var selector = "#"+ $(obj).attr('id');

		var filterData = function(data,year,quarter){

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
			utility.getJSON(global_obj.datacast_url+ obj.dataset.datacast_identifier,this,filterData);
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
			//If data is not available then call the database to fetch the data.
			utility.getJSON(global_obj.datacast_url+ obj.dataset.datacast_identifier,this,filterData);
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
			filter_data = _.filter(chart_data.multidgroupcol, function(obj){ return obj.year  == year; });

			if(filter_data.length <= 0){
				createErrorDiv($(obj).attr('id'));
			}
			else{
				removeErrorDiv($(obj).attr('id'));
			}

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
			//If data is not available then call the database to fetch the data.
			utility.getJSON(global_obj.datacast_url+ obj.dataset.datacast_identifier,this,filterData);
		}
		else{
			filterData(chart_data.multidcol,year,quarter);
		}
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
				return ((+obj.year  === current_year)||(+obj.year === current_year - 1))
			});

			if(filter_data.length <= 0){
				createErrorDiv($(obj).attr('id'));
			}
			else{
				removeErrorDiv($(obj).attr('id'));
			}
			callPykChart(filter_data);

		}

		var callPykChart = function(data){
			var loadonedmap_obj = {
					selector: selector,//Getting id for the element as expected by the pykihcharts.
					data:data,
					chart_color: ["#B0E2FF","#60AFFE"],
					data_sort_enable: "no",
					axis_x_time_value_datatype:"month",
				};

			var chartobj = new PykCharts.multiD.multiSeriesLine(
						loadonedmap_obj
					);

			chartobj.execute();
		}

		if(!country_chart_data){
			utility.getJSON(rumi_api_endpoint + 'datacast/'+ obj.dataset.datacast_identifier,this,filterData);
		}
		else{
			filterData(country_chart_data);
		}
	}

	var loadMapOneLayer = function (obj,year,quarter) {

		var selector = "#"+ $(obj).attr('id'),
			quarter_val;

		var filterData = function(data,year,quarter){

			if(!chart_data.maps){
				chart_data.maps = data; //Saving the data once so that we don't need to call service again.
			}
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

			if(!chart_data.onelayer[year]){
				chart_data.onelayer[year]=[];
			}
			if(!chart_data.onelayer[year][quarter]){
				chart_data.onelayer[year][quarter] = {};

				filter_data = _.filter(chart_data.maps, function(obj){ return ((obj.year  == year) && (obj.quarter  == quarter_val)) });

				filter_data = _.sortBy(filter_data,function(obj){
						return (parseInt(obj.size))*(-1);
					});

				filter_data = _.first(filter_data,25);

				chart_data.onelayer[year][quarter] = filter_data;

			}
			//If data is not available then call the database to fetch the data.
			//We need to show only top 25 countries.

			if(chart_data.onelayer[year][quarter].length <= 0){
				createErrorDiv($(obj).attr('id'));
			}
			else{
				//Removing error div in case data is correct
				removeErrorDiv($(obj).attr('id'));
			}
			callPykChart(chart_data.onelayer[year][quarter]);	
		}
		var callPykChart = function(data){

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
			      	saturation_color: "#255AEE",
			      	color_mode: "saturation"
				};

			var chartobj = new PykCharts.maps.oneLayer(
						loadonedmap_obj
					);

			chartobj.execute(); 
		}

		if(!chart_data.maps){
			//If data is not available then call the database to fetch the data.
			utility.getJSON(global_obj.datacast_url+ obj.dataset.datacast_identifier,this,filterData);
		}
		else{
			filterData(chart_data.maps,year,quarter);
		}
	}

	//Function to load top 10 digital objects.
	var loadTop10digitalObject = function(obj,year,quarter){
		var selector = "#"+ $(obj).attr('id'),
			quarter_val,
			filter_data;

		var filterData = function(data,year,quarter){
			if(!content_data.top10digital){
				content_data.top10digital = data; //Saving the data once so that we don't need to call service again.
			}

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

			filter_data = _.filter(content_data.top10digital, function(obj){ return ((obj.year  == year) && (obj.quarter  == quarter_val)) });

			filter_data = _.sortBy(filter_data,function(obj){
				return parseInt(obj.value)*-1;
			});
			filter_data = _.first(filter_data,10);
			renderHTMLForDigitalObj(filter_data);
		}

		var renderHTMLForDigitalObj = function(data){
			var index=0,
			length = 0,
			html='';
			length = data.length > 10 ? 10 : data.length;
			for(index=0;index<length;index++){
				html += setInnerHTML(data[index],index);
			}
			$(selector).html(html);
		}

		//setting up inner html content for the top 10 digital items
		var setInnerHTML = function(obj,index){
			var html = '';
			html += '<span class = "col-sm-'+6+' ten_digital">';
			html += '<span class= col-sm-3>';
				html += '<a class=pull-left href='+obj.title_url+' target="_blank">';
				html += '<img src='+obj.image_url+ ' class="ten_digital_image">';
				html += '</a></span>';
			html += '<span class=col-sm-9>';
				html += '<span class=col-sm-12><b>';
				html += (index+1)+'.';
					html += '</b></span>';
			html += '<span class=col-sm-12>';
				html += '<a href='+obj.title_url+' target="_blank">';
				html += obj.title.substring(0,50)+"...";
				html += '</a>';
				html += '</span>';
				html += '<span class=col-sm-12><b>';
				html +=  obj.value +' views';
				html += '</b></span></span></span>';
			return html;
		}
		if(!content_data.top10digital){
			//If data is not available then call the database to fetch the data.
			utility.getJSON(global_obj.datacast_url+ obj.dataset.datacast_identifier,this,filterData);
		}
		else{
			filterData(content_data.top10digital,year,quarter);
		}	
	}

	//Load the loadMultiDGroupedCol and loadMapOneLayer for the passed year no

	//Load year filter
	var loadYearMenuBar = function(){
		var initial_year = 2012;//Assumption that data will be coming only 2012 onwards so as to save on performance hit.
		var final_year = gon.selected_year;
		var html_string = '';
		for(var year_no = initial_year;year_no <= final_year;year_no++){//apply space after using style guide
			html_string = html_string + '<span id = id_year_filters_yearno_'+year_no+' onclick="Rumali.autoCharts.filterDataYear('+
				year_no+')">'+year_no+'</span>';
		}
		document.getElementById('id_year_filters').innerHTML = html_string;
	}

	//Load quarter filter
	var loadQuarterMenuBar = function(){
		var html_string = '';
		html_string = '<span id = id_quarter_filters_quarterno_1 onclick="Rumali.autoCharts.filterQuarterData(1)">Q1</span>'
					+'<span id = id_quarter_filters_quarterno_2 onclick="Rumali.autoCharts.filterQuarterData(2)">Q2</span>'
					+'<span id = id_quarter_filters_quarterno_3 onclick="Rumali.autoCharts.filterQuarterData(3)">Q3</span>'
					+'<span id = id_quarter_filters_quarterno_4 onclick="Rumali.autoCharts.filterQuarterData(4)">Q4</span>';
		document.getElementById('id_quarter_filters').innerHTML = html_string;
	}

	//Load error div in case data is not present
	var createErrorDiv = function(selector,custommesg){
		removeErrorDiv(selector);
		var defaultmesg = 'Data not available';
		var error_html =  "<span id=error_"+selector+">"+(custommesg ? custommesg : defaultmesg)+"</span>";
		$(error_html).insertBefore("#"+selector);
	}
	//removing a div for error
	var removeErrorDiv = function(selector){
		$('#error_'+selector).remove();
	}

	var loadTopCountryCard = function(obj,year,quarter){
		var title = "",
			country_name = "",
			total_views = 0,
			content = "",
			filter_data,
			quarter_val;


		var filterData = function(data,year,quarter){
			if(!chart_data.maps){
				chart_data.maps = data; //Saving the data once so that we don't need to call service again.
			}

			quarter_val = 'Q'+quarter;

		
			filter_data = _.filter(chart_data.maps, function(obj){ 
				return  ((+obj.year  === year) && (obj.quarter  === quarter_val)); 
			});

				
			filter_data = _.max(filter_data, function(obj){ 
				return +obj.size; //To check numeric value instead of string value.
			});

			title = "Top Views",
			country_name = filter_data.iso2,
			total_views = filter_data.size,
			content = '<i>*previous month\'s data</i>';

		}

		//The data to be shown on the card
		if(!chart_data.maps){
			//If data is not available then call the database to fetch the data.
			utitlity.getJSON(global_obj.datacast_url+ obj.dataset.datacast_identifier,this,filterData);
		}
		else{
			filterData(chart_data.maps,year,quarter);
		}
	}

	var renderHTMLForCard = function(data,id){
		//id,title,key,value,content
		var id = id,
			title = data[0].title ? data[0].title : '',
			key = data[0].key ? data[0].key : '<br/>',
			value = data[0].value ? data[0].value : '',
			content = data[0].content ? data[0].content : '';

		if(typeof +value === "number"){
			value = +value;
			value = utility.applyConditionalFormatting(value);
		}


		var div = $('<div />').appendTo('body');
		div.attr('id', id);
		var htmlcontent = '<span class = "col-sm-12 card_layout">';
		htmlcontent += '<span class= "col-sm-12 card_layout_header_span"><h4 class="card_layout_header"><b>'+title+'</b></h4></span>';
		htmlcontent += '<span class= "col-sm-12 card_layout_key">'+key+'</b></span>';
		htmlcontent += '<span class= "col-sm-12 card_layout_value">'+value+'</b></span>';
		htmlcontent += '<span class= "col-sm-12 card_layout_content">'+content+'</span>';
		htmlcontent += '</span>';

		$('#'+id).html(htmlcontent);
	}
	/*
	*/
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

			/* Add it when it is applied
			rank_for_country = data[i].rank_for_country;
			*/

			rank_for_europeana = data[i].rank_for_europeana;
			rank_for_europeana_diff = data[i].diff_in_rank_for_europeana;

			value = data[i].value_of_last_month;

			/* Add it when it is applied
			value_contribution_for_country = data[i].value_contribution_for_country;
			*/
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
		/* Add it later
		string += '<span class="important_val">';
		string += rank_for_country + '</span>(' ;
		if(rank_for_country_diff > 0){
			string += '<span class="'+utility.applyConditionalCssPositiveOrNegative(Rumali.object.value_change.negative)+'">';
			string += rank_for_country_diff + '&#9660;' ;
		}
		else if(rank_for_country_diff < 0){
			string += '<span class="'+utility.applyConditionalCssPositiveOrNegative(Rumali.object.value_change.positive)+' ">';
			string += (rank_for_country_diff*-1)+ ' &#9652;';
		}
		else{
			string += '<span class="'+utility.applyConditionalCssPositiveOrNegative(Rumali.object.value_change.no_change)+' ">';
			string += (rank_for_country_diff*-1)+ ' -';	
		}

		string += '</span>';
		string += ')';
		
		string += ' / ';
		*/

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

	var filterDataYear = function(year_no){
		chart_data.year_no = year_no;
		loadMultiDGroupedCol(chart_data.charts[2],chart_data.year_no,chart_data.quarter_no);
		loadMapOneLayer(chart_data.charts[4],chart_data.year_no,chart_data.quarter_no);
		loadTop10digitalObject(content_data.content[0],chart_data.year_no,chart_data.quarter_no);
	}
	var filterQuarterData = function(quarter_no){
		chart_data.quarter_no = quarter_no;
		loadMapOneLayer(chart_data.charts[4],chart_data.year_no,chart_data.quarter_no);	
		loadTop10digitalObject(content_data.content[0],chart_data.year_no,chart_data.quarter_no);
	}

	return{
		loadReportChart:loadReportChart,
		filterDataYear:filterDataYear,
		filterQuarterData:filterQuarterData
	}
}());