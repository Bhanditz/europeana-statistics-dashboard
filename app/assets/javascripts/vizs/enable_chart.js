Rumali.loadChartFromDropdown = function(){
	////console.log('loadChartFromDropdown');
	var chart_data = {};
	var current_chart;
	var filter_array = [];
	var data_avail = '';
	var datacast_data = {};
	var filter_name = '';
	var default_theme = {};
	//Bind dropdown value to validate which charts to show.
	var bindDropdownValue = function(){
		//console.time("bindDropdownValue");
		////console.log('bindDropdownValue');
		//keep the checkbox disabled.
		default_theme = JSON.parse(gon.default_theme);
		$("#id_manual_chart_filter").attr("disabled", true);
		$("#id_manual_chart_filter").attr('checked', false); 
		toggleFilterPanel();

		$('#core_datacasts').change(function() {
			hideChartFilter();//
			if(this.selectedIndex !== 0 ){
				data_avail = 'new_data';
				$("#id_manual_chart_filter").attr("disabled", false);
				$("#id_manual_chart_filter").attr('checked', false); 
				toggleFilterPanel();
				validateChartsToBeShown(this.options[this.selectedIndex]);	
			}
			else{
				$("#id_manual_chart_filter").attr("disabled", true);
				$("#id_manual_chart_filter").attr('checked', false); 
				toggleFilterPanel();
			}				
		});	
		//Show filter when the enable filter is checked.
		displayFilterColumn();
		//console.timeEnd("bindDropdownValue");
	}

	var validateChartsToBeShown = function(obj,filter){
		//console.time("validateChartsToBeShown");
		////console.log('validateChartsToBeShown');
		var metric_array = [],metric_array_string;
		var dimension_array = [],dimension_array_string;
		var obj_metrics,obj_metrics_string;
		var obj_dimensions,obj_dimensions_string;
		
		chart_data = obj;

		if(typeof obj.dataset.metrics !== 'undefined'){
			obj_metrics = JSON.parse(obj.dataset.metrics);

			if(typeof filter !== 'undefined'){
				obj_metrics = _.without(obj_metrics,filter);
			}

			obj_metrics_string = obj_metrics.sort().join(',');	
		}
		else{
			obj_metrics = [];
			obj_metrics_string = '';
		}
		if(typeof obj.dataset.metrics !== 'undefined'){
			obj_dimensions = JSON.parse(obj.dataset.dimensions);

			if(typeof filter !== 'undefined'){
				obj_dimensions = _.without(obj_dimensions,filter);
			}
			obj_dimensions_string = obj_dimensions.sort().join(',');
		}
		else{
			obj_dimensions = [];
			obj_dimensions_string = '';	
		}
		//Getting all the image tags inside the tag 
		$('#chart_selector_list img').each(function(){
			var html_tag = $(this)[0];
			if(typeof html_tag.dataset.dimensions_alias === 'undefined' || html_tag.dataset.metrics_alias === 'undefined' || html_tag.dataset.dimensions_alias.length === 0 || html_tag.dataset.metrics_alias.length === 0){
				$(this).removeClass('disabled');
				$(this).addClass('enabled');	

				$(this).unbind("click");
				$(this).click(getData);
			}
			else{
				metric_array = html_tag.dataset.metrics_alias;
				dimension_array = html_tag.dataset.dimensions_alias;
				
				metric_array_string =  JSON.parse(metric_array).sort().join(',');
				dimension_array_string = JSON.parse(dimension_array).sort().join(',');

				if((obj_metrics_string === metric_array_string)&&(obj_dimensions_string === dimension_array_string)){
					$(this).removeClass('disabled');
					$(this).addClass('enabled');

					$(this).unbind("click");
					$(this).click(getData);	
				}
				else{
					$(this).removeClass('enabled');
					$(this).addClass('disabled');
					$(this).prop('onclick',null).off('click');	
				}
			}
		});

		//console.timeEnd("validateChartsToBeShown");
		$('#chart_selector_list img')[0].click();			

	}

	var renderChart = function(data){
		////console.log('renderChart');
		var chart_api;
		var config = {},k;
		
		clearChart();


		//console.log(current_chart);
		if(current_chart.dataset.api === 'handsontable'){

			$("#table_show").show();
			config = {
			  "readOnly": true,
			  "fixedRowsTop": 0,
			  "manualColumnMove": true,
			  "outsideClickDeselects": false,
			  "contextMenu": false
			}
            config.data = data;
            config.colHeaders = findKeyArray(data[0]);
            $("#table_show").handsontable(config);	

		}else{
			$("#chart_show").show();
			config = $.extend({}, default_theme);
			chart_api = getApiFromString(current_chart.dataset.api);
			//config
			config.selector = "#chart_show";
			config.data = data;
			config.chart_width = $(window).width() * 0.6;
			config.chart_height = 450;
			config.map_code = 'world';
			k = new chart_api(config);
	  		k.execute();	
		}
		
	}

	var setFilterAndRenderChart = function(data){
		////console.log('setFilterAndRenderChart');
		//console.time("setFilterAndRenderChart");
		setFilterContent();
		datacast_data = data;
		renderChart(data);
		//console.timeEnd("setFilterAndRenderChart");
	}

	var getData = function(){
		var filtered_data = [];
		//console.time("getData");
		if(data_avail === 'new_data'){
			var url = Rumali.object.datacast_url;
			url = url + chart_data.value;
			current_chart = this;
			filter_name = '';
			getJSON(url,setFilterAndRenderChart);
		}
		else{
			current_chart = this;
			filtered_data = filterChart();
			renderChart(filtered_data);		
		}
		//console.timeEnd("getData");	
	}

	var clearChart = function(){
		$("#table_show").hide();
		$("#chart_show").hide();
	}
	//Filtering chart data and data is already available.
	var filterChart = function(){
		console.time("filterChart");
		var filtered_data = [],index,filter_value,count=-1;
		if(filter_name !== ''){
			filter_value = $("#filter_show option:selected").text();

			/*
			filtered_data = datacast_data.filter(function(element,index){
				return element[filter_name] === filter_value;
			});

			for(index=0;index < filtered_data.length ;index++){
				delete filtered_data[filter_name];
			}*/

			for(index = 0;index < datacast_data.length;index++){
				if(filter_value === datacast_data[index][filter_name]){
					filtered_data[++count] = {};
					for(var k in datacast_data[index]){
						if(k !== filter_name){
							filtered_data[count][k]=datacast_data[index][k];
							//Copying all the items from original array to new array.
							//value to be pushed in the new array 
						}
					} 
					//Filter data is the data that is to be displayed on the ui.
				}		
			}
			return filtered_data;
		}
		else{
			filtered_data = datacast_data;
			////console.log(3);
			return filtered_data;
		}
		console.timeEnd("filterChart");	
	}

	//Set up filter content on report page.
	var setFilterContent = function(){
		//console.time("setFilterContent");
		var filter_array = JSON.parse(chart_data.dataset.metrics).concat(JSON.parse(chart_data.dataset.dimensions));

		$('#core_datacasts_filter')
    		.find('option')
    		.remove()
    		.end();

    	$('#core_datacasts_filter').append($('<option>', {
        		value: 'Select filter column',
        		text : 'Select filter column' 
    		}));


		$.each(filter_array, function (i, item) {
    		$('#core_datacasts_filter').append($('<option>', { 
        		value: item,
        		text : item 
    		}));
		});
		// sets selected index to first item using jQuery (can work on multiple elements)
		$("select#core_datacasts_filter").prop('selectedIndex', 0);

		$( "#core_datacasts_filter").unbind("change");

		$('#core_datacasts_filter').change(function() {
			////console.log('setFilterContent');
			if(this.selectedIndex !== 0){
				data_avail = 'existing_data';
				filter_name = this.options[this.selectedIndex].text;
				showUniqueFilterValues(filter_name);
				validateChartsToBeShown(chart_data,this.options[this.selectedIndex].text);
			}	
		});	
		//console.timeEnd("filterChart");	
		return filter_array;
	}

	//Method to be used when we enable the filter
	var displayFilterColumn = function(){
		//console.time("displayFilterColumn");
		var is_datacast_filter_enable ;
		var x = document.getElementById("core_datacasts");
		$('#id_manual_chart_filter').unbind("change");
		$('#id_manual_chart_filter').change(function(){
			toggleFilterPanel();
			hideChartFilter();
			showUnfilteredData();
			validateChartsToBeShown(x.options[x.selectedIndex]);	
		});
		//console.timeEnd("displayFilterColumn");	
	}

	//toggle filter panel depending on the value of the checkbox.
	var toggleFilterPanel = function(){
		//console.time("toggleFilterPanel");
		is_datacast_filter_enable = $('#id_manual_chart_filter').is(":checked");
		if(is_datacast_filter_enable){
			$('#core_datacasts_filter').show(); 
		}
		else{
			$('#core_datacasts_filter').hide();
			//
		}
		//console.timeEnd("toggleFilterPanel");	
	} 	

	//Hiding chart filter
	var hideChartFilter = function(){
		//console.time("hideChartFilter");
		////console.log('hideChartFilter');
		$('#filter_show').hide();
		//console.timeEnd("hideChartFilter");	
	} 

	var showUnfilteredData = function(){
		//console.time("showUnfilteredData");
		data_avail = 'existing_data';
		filter_name = '';
		//getData();
		//console.timeEnd("showUnfilteredData");		
	}

	//Showing unique values for the filter.
	var showUniqueFilterValues = function(filter_name){
		//console.time("showUniqueFilterValues");
		//console.log('showUniqueFilterValues',filter_name);
		var unique_filter_name_values = [];
		$('#filter_show').show();
		unique_filter_html = renderFilter(datacast_data,filter_name,'filter_show');	
		$('#filter_show').html(unique_filter_html);

		$('#filter_show').unbind("change");
		$('#filter_show').change(function(){
			data_avail = 'existing_data';
			getData.call(current_chart);
		});
		//console.timeEnd("showUniqueFilterValues");	
	}
			
	//Call function on load of this function.
	bindDropdownValue();
}
