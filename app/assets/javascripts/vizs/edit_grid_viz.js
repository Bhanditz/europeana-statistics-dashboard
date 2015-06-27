Rumali.showAndEditGridPage = function(){
  if(chart_name === "Grid"){
    if ($("#embed-code-display").length > 0 && embed_url){
      setTimeout(function(){ initClipBoard("#copy-link", "#embed-code-display"); }, 1000);
      $("#embed-code-display").text('<iframe src="'+embed_url+'" height=400 width=575 frameborder="0" scrolling="no"></iframe>');
    }
    config_data.data = d3.csv.parse(gon.data_file);
    $.ajax({
      url: rumi_api_endpoint + gon.rumiparams + "column/all_columns?data_types=true&original_names=true&token=" + gon.token,
      type: "GET",
      data: obj,
      dataType: "json",
      success: function (data1) {
        var headers = Object.keys(config_data.data[0])
          , headers_length = headers.length
          , original_column_names = data1.columns.original_column_names;
        for (var i = 0; i < headers_length; i++) {
          var original_column_name_to_set = original_column_names[headers[i]];
          if (original_column_name_to_set) {
            headers[i] = original_column_name_to_set;
          }
        }
        config_data.colHeaders = headers;
        $(selector)[initializer](config_data);
      }
    });
  }

  $("#core_viz_data_format_update").click(function(){
    var data_format = $("#data_format_toggle :checked").val() || "csv";
    $("#core_viz_dataformat").val(data_format);
  });

  $("#data_format_toggle").on("change",function(){
    $("#core_viz_data_format_update").trigger("click");
  });

}
