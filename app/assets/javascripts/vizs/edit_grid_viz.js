//Page called when grid of handsontable is loaded.
Rumali.showAndEditGridPage = function(){

	var url,
		datacast_identifier,
		grid_html_tag,
		parsed_data,
		org_data,
		config;

	var loadGrid = function(){
		grid_html_tag = $('.d3-pykcharts')[0];
		datacast_identifier = grid_html_tag.dataset.datacast_identifier;
  		url = Rumali.object.datacast_url + datacast_identifier;
		getJSON(url,setFilterAndRenderChart);//Get json from the utility function.
	}

	var createGrid = function(data){
		config = gon.chart_config;
        config.data = data;
        config.colHeaders = findKeyArray(data[0]);
        $(".d3-pykcharts").handsontable(config);//Create grid using handsontable.
	}

	var setFilterAndRenderChart = function(data){
		var unique_filter_html,
			filter_val,
			parsed_data,

		org_data = data;

		//If condition is filter is present
		if(grid_html_tag.dataset.filter_present === 'true'){
			$('#filter_container').show();
			unique_filter_html = renderFilter(org_data,grid_html_tag.dataset.filter_column_name,'filter_show');
			$('#filter_container').html(unique_filter_html); 

      $('#filter_show').change(function(){
        filter_val = $('#filter_show option:selected').val();
        parsed_data = filterChart(org_data,grid_html_tag.dataset.filter_column_name,filter_val);
        createGrid(parsed_data);
      });

      $("select#filter_show").prop('selectedIndex', 0);
      filter_val = $('#filter_show option:selected').val();
      parsed_data = filterChart(org_data,grid_html_tag.dataset.filter_column_name,filter_val);
      createGrid(parsed_data);

		}else{
			$('#filter_container').hide();
			parsed_data = org_data;
			createGrid(parsed_data);
		}
	}

	loadGrid();
}
