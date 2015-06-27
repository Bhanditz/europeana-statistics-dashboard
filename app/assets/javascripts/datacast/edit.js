Rumali.initDataCastGrid = function (){
  Rumali.plugin = new Rumali.plugins();
  config_data.data = gon.query_output;
  $("#preview_output_grid").handsontable(config_data);
}