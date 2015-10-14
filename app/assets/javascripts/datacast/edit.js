Rumali.initDataCastGrid = function (){
  if (gon.format == "xml"){
    $("#datacast_display").text(gon.query_output);
  }
  else if (gon.format == "json") {
    $("#datacast_display").text(JSON.stringify(gon.query_output,null,"\t"));
  } else {
    config_data.data = JSON.parse(gon.query_output);
    $("#preview_output_grid").handsontable(config_data);
  }
}