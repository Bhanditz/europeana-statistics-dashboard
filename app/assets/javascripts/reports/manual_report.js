// Load Europeana level data
Rumali.manualCharts = (function(){

	var index;
	var charts_array = [];
	var utility =Rumali.utility;
	var global_obj = Rumali.object;

	var provider_rank = {};
	//This is a automated report in the page.Migrate the code when the page is made.

	var loadReportChart = function(){
		var length;

		var id;//This is for provider ranking table.Migrate the code.

		charts_array = $('.d3-pykcharts');//Loading class for charts.
		length = charts_array.length;//Number of charts to be loaded.

		for(index = 0;index < length;index++){
			var api_data = charts_array[index].dataset.api; //Getting api data attribute of the chart
			
			switch(api_data){//Every chart type should have corresponding case. 
				
				case 'PykCharts.multiD.column':
					loadMultiDCol(charts_array[index]);
					break;	
				case 'PykCharts.oneD.pie':
					loadOnedPie(charts_array[index]);	
				
			}
		}

		provider_rank = $('.box_table')[0];//Fetching class for provider rank table.
		id = provider_rank.id;//Getting id for the class.
		utility.getJSONforTable(global_obj.datacast_url+provider_rank.dataset.datacast_identifier,id,renderHTMLForTable);

	}

	//Global function to filter the data out


	//Generic function for loading any manual multi-d column chart.
	var loadMultiDCol = function(data){
		
		var htmlcontent = '';
		//step 1 : get json
		var filter_data_multid_col = [];



		//get selector id
		var selector; 
		//load pykchart
		var callPykChart = function(){

			var multid_obj = {
				selector: selector,//Getting id for the element as expected by the pykihcharts.
				data:filter_data_multid_col,
				//Api for fetching the data.
        axis_x_formatting_enable: "no",
				chart_margin_left:60
				};

			var chartobj = new PykCharts.multiD.column(
					multid_obj
				);
			chartobj.execute(); 
		}

		//step 2 : filter the json
		var filterData = function(url_data){
			//case 1 : if filter is present in the data
			//case 2 : if filter is not present in the data	

			if(data.dataset.filter_present === 'false'){
				filter_data_multid_col = url_data;
				callPykChart();
			}
			else{
				//Code needs to be written and to be made generic if possible.
			}
		}

		htmlcontent += '<span class = header id ='+ $(data).attr('id')+'_header></span>';
		htmlcontent += '<span class = header id ='+ $(data).attr('id')+'_body></span>';
		htmlcontent += '<span class = header id ='+ $(data).attr('id')+'_footer></span>';

		selector = "#"+ $(data).attr('id');

		$(selector).html(htmlcontent);

		selector = "#"+ $(data).attr('id')+ "_body";

		utility.setHTMLheaderForChart('This chart is for pageviews of Europeana', $(data).attr('id')+ "_header");


		utility.getJSON(global_obj.datacast_url + data.dataset.datacast_identifier,this,filterData);		
		//step 3 : load the actual chart.
	}

	//Rendering string for rank column only
	renderHTMLforTableRank = function(rank_for_europeana,rank_for_europeana_diff){
		
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
	//Render html for table value
	var renderHTMLforTableValue = function(sum,diff_in_value_in_percentage,value_contribution_for_europeana){
		var string = '<span class="col-sm-12">';
		var cond_class = '';
		if(+diff_in_value_in_percentage > 0){
			cond_class = utility.applyConditionalCssPositiveOrNegative(Rumali.object.value_change.positive);
		}
		else if(+diff_in_value_in_percentage < 0){
			cond_class = utility.applyConditionalCssPositiveOrNegative(Rumali.object.value_change.negative);
		}
		else{
			cond_class = utility.applyConditionalCssPositiveOrNegative(Rumali.object.value_change.no_change);	
		}

		string += '<span class='+cond_class+' data-toggle="tooltip" data-placement="bottom" data-original-title="'+utility.tooltipLayout(diff_in_value_in_percentage)+'">';
		string += utility.applyConditionalFormatting(sum);
		string += '</span>(';
		string += value_contribution_for_europeana+'%)';
		string += '</span>';
		return string;	
	}

	var renderContentForProviderRanking = function(filter_data){
		var title ='',
			rank_for_europeana = '',
			rank_for_europeana_diff = '',
			sum = '',
			diff_in_value_in_percentage = '',
			value_contribution_for_europeana = '',
			i=0,
			htmlcontent = '';

		//running loop for each row within the html	
		for(i=0;i<filter_data.length;i++){
			title = filter_data[i].impl_aggregation_name;
			rank_for_europeana = filter_data[i].rank_for_europeana;
			rank_for_europeana_diff = filter_data[i].diff_in_rank_for_europeana;
			sum = filter_data[i].sum;
			diff_in_value_in_percentage = filter_data[i].diff_in_value_in_percentage;
			value_contribution_for_europeana = filter_data[i].contribution_to_europeana;
			htmlcontent += '<span class = "col-sm-12 border_top">';
				htmlcontent += '<span class = "col-sm-5 text-center">';
				//Title logic
				htmlcontent += utility.renderHTMLforTableTitle(title);
				htmlcontent += '</span>';

				htmlcontent += '<span class = "col-sm-3 text-center">';
				//Ranking logic
				htmlcontent += renderHTMLforTableRank(rank_for_europeana,rank_for_europeana_diff);
			
				htmlcontent += '</span>';

				htmlcontent += '<span class = "col-sm-4 text-right">';
				//value logic
				htmlcontent += renderHTMLforTableValue(sum,diff_in_value_in_percentage,value_contribution_for_europeana);
				htmlcontent += '</span>';
			htmlcontent += '</span>';
		}

		return htmlcontent;
	}

	//This is the ranking table object function.
	var renderHTMLForTable = function(data,id){
		//Ranking table 
		var htmlcontent = '',
			filter_data = [],
			original_data = data;

		htmlcontent += '<h3 class="ranking_header">Provider Rankings.</h3>'

		filter_data = utility.filterData(data,'metric','pageviews');

		htmlcontent += utility.renderFilter(data,'metric','id_dropdown_provider_rank');//attribute name over which dropdown should be created.	

			htmlcontent += '<span class = "col-sm-12 box_layout border_top">';
				htmlcontent += '<span class = "col-sm-12 box_layout_header_span">';
					htmlcontent += '<span class = "col-sm-5 box_layout_header"><b>Provider Name';
					htmlcontent += '</b></span>';	
					htmlcontent += '<span class = "col-sm-3 box_layout_header"><b>Rank';
					htmlcontent += '</b></span>';
					htmlcontent += '<span class = "col-sm-4 box_layout_header"><b>Value';
					htmlcontent += '</b></span>';

				htmlcontent += '<span class = "col-sm-12">';
					htmlcontent += '<span class = "col-sm-5"></span>';
					htmlcontent += '<span class = "col-sm-3 box_layout_header_subtitle">Europeana</span>';
				htmlcontent += '</span>';
				htmlcontent += '<span id="id_provider_rank_content">';

				htmlcontent += '</span>';
				htmlcontent += '<span class = "col-sm-12 border_top box_layout_header_subtitle">';
				htmlcontent += '* % in value indicates contribution to Europeana.';
				htmlcontent += '</span>';

			htmlcontent += '</span>';

		$('#'+id).html(htmlcontent);

		$('#id_dropdown_provider_rank').val('pageviews');

		$('#id_provider_rank_content').html(renderContentForProviderRanking(filter_data));

		$('#id_dropdown_provider_rank').change(function() {
			filter_data = utility.filterData(original_data,'metric',this.options[this.selectedIndex].text);
			$('#id_provider_rank_content').html(renderContentForProviderRanking(filter_data));			
			
			assignTooltip();
			
		});

		assignTooltip();
	}

	//assigning tooltip for positive and negative values.
	var assignTooltip = function(){
		$('.positive_value_css').tooltip();
		$('.negative_value_css').tooltip();
	}

	var loadOnedPie = function(data){
		var selector,selector_header,selector_body,selector_footer; 
		var filter_data_pie = [];
		var htmlcontent = '';
		var height = '';


		var callPykChart = function(){

			var oned_obj = {
				selector: "#"+selector_body,//Getting id for the element as expected by the pykihcharts.
				data:filter_data_pie,
				chart_width: 400
				};

			var chartobj = new PykCharts.oneD.pie(
					oned_obj
				);

			chartobj.execute(); 

			var height = chartobj.chart_height * 1.25;
			
			$(selector).height(height);
		}

		//step 2 : filter the json
		var filterData = function(url_data){
			//case 1 : if filter is present in the data
			//case 2 : if filter is not present in the data	
			var html_filter = '';

			if(data.dataset.filter_present === 'false'){
				filter_data_pie = url_data;
				callPykChart();

			}
			else{
				//Code needs to be written and to be made generic if possible.
				filter_data_pie = utility.filterData(url_data,data.dataset.filter_column_name,url_data[url_data.length -1][data.dataset.filter_column_name]);
				callPykChart();
				html_filter += utility.renderFilter(url_data,data.dataset.filter_column_name,selector_header+"_dropdown");//attribute name over which dropdown should be created.	
				
				$('#'+selector_header).html(html_filter);

				$('#'+selector_header+"_dropdown").val(url_data[url_data.length -1][data.dataset.filter_column_name]);

				$('#'+selector_header+"_dropdown").change(function(event) {
					filter_data_pie = utility.filterData(url_data,data.dataset.filter_column_name,this.options[this.selectedIndex].text);
					callPykChart();
				});

			}


		}

		selector = "#"+ $(data).attr('id');
		selector_header = $(data).attr('id') + "_head"; 
		selector_body =  $(data).attr('id') + "_body";
		selector_footer = $(data).attr('id') + "_footer";

		htmlcontent += '<span class = header id ='+ selector_header+'></span>';
		htmlcontent += '<div class = header id ='+ selector_body+' height= 400></div>';
		htmlcontent += '<span class = header id ='+ selector_footer+'></span>';


		$(selector).html(htmlcontent);

		utility.getJSON(global_obj.datacast_url + data.dataset.datacast_identifier,this,filterData);		
		//step 3 : load the actual chart.
	}
return{
	loadReportChart:loadReportChart	
}
}());	