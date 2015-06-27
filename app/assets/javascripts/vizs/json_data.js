Rumali.JsonDataPage = function(){
  if ($("#embed-code-display").length > 0 && embed_url) {
    setTimeout(function(){ initClipBoard("#copy-link", "#embed-code-display"); }, 1000);
    $("#embed-code-display").text('<iframe src="'+embed_url+'" height=400 width=575 frameborder="0" scrolling="no"></iframe>');
  }
  var json_data = gon.data_file;

  if(gon.dataformat == "json") {
    json_data = JSON.parse(gon.data_file);
  }

  $("#chart_container_display").text(JSON.stringify(json_data,null,"\t"));

  $("#core_viz_data_format_update").click(function(){
    var data_format = $("#data_format_toggle :checked").val() || "csv";
    $("#core_viz_dataformat").val(data_format);
  });
  $("#data_format_toggle").on("change",function(){
    $("#core_viz_data_format_update").trigger("click");
  });
}