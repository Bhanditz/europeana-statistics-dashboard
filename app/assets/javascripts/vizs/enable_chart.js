Rumali.loadChartFromDropdown = function(){
	var chart_data = {};
	var current_chart;
	//Bind dropdown value to validate which charts to show.
	var bindDropdownValue = function(){

		validateChartsToBeShown(document.getElementById('core_datacasts').options[0]);

		$('#core_datacasts').change(function() {

			validateChartsToBeShown(this.options[this.selectedIndex]);	
		});	
	}

	var validateChartsToBeShown = function(obj){
		var metric_array = [],metric_array_string;
		var dimension_array = [],dimension_array_string;
		var obj_metrics,obj_metrics_string;
		var obj_dimensions,obj_dimensions_string;
		

		chart_data = obj;
		obj_metrics = JSON.parse(obj.dataset.metrics);
		obj_dimensions = JSON.parse(obj.dataset.dimensions);

		obj_metrics_string = obj_metrics.sort().join(',');
		obj_dimensions_string = obj_dimensions.sort().join(',');
		//Getting all the image tags inside the tag 
		$('#chart_selector_list img').each(function(){
			var html_tag = $(this)[0];

			if(typeof html_tag.dataset.dimensions_alias === 'undefined'){
				$(this).removeClass('disabled');
				$(this).addClass('enabled');	
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
					$(this).click(getData);	
				}
				else{
					$(this).removeClass('enabled');
					$(this).addClass('disabled');
					$(this).prop('onclick',null).off('click');	
				}
			}
			//console.log();
		});

	}

	var renderChart = function(data){
		var chart_api;
		var config = {},k;

		chart_api = getApiFromString(current_chart.dataset.api);
		config.selector = "#data_container";
		config.data = data;
		config.chart_width = 500;
		config.chart_height = 500;
		k = new chart_api(config);
  		k.execute();
	}

	var getData = function(){
		var url = Rumali.object.datacast_url;
		url = url + chart_data.value;

		current_chart = this;

		getJSON(url,renderChart);
	}
	//Call function on load of this function.
	bindDropdownValue();
}