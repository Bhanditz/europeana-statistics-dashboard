Rumali.showAndEditBoxPage = function(){
	var url,
		datacast_identifier,
		card_html_tag,
		org_data,
		id;

	var loadBox = function(){
		card_html_tag = $('.card_with_value')[0];
		datacast_identifier = card_html_tag.dataset.datacast_identifier;
  		url = Rumali.object.datacast_url + datacast_identifier;
		getJSON(url,setFilterAndRenderChart);
	}

	var createGrid = function(data){
		config = gon.chart_config
        config.data = data;
        config.colHeaders = findKeyArray(data[0]);
        $(".d3-pykcharts").handsontable(config);
	}

	var setFilterAndRenderChart = function(data){
		org_data = data;
		id = card_html_tag.id;
		renderHTMLForCard(org_data,id);
	}

	loadBox();
}