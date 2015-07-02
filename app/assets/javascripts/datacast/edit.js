Rumali.initDataCastGrid = function (){
  config_data.data = gon.query_output;
  if (gon.format == "xml"){
    $("#datacast_display").text(gon.query_output);
  }
  else if (gon.format == "json") {
    $("#datacast_display").text(JSON.stringify(gon.query_output,null,"\t"));
  } else {
    $("#preview_output_grid").handsontable(config_data);
  }
}