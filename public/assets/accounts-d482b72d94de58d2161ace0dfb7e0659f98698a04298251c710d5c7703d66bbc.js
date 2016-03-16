var getApiFromString = function(api){
  api = api.split(".");
  return PykCharts[api[1]][api[2]];
}

;
window.onload = function () {

  switch (gon.scopejs) {
    case "scopejs_themes_new":
    case "scopejs_themes_create":
    case "scopejs_themes_edit":
    case "scopejs_themes_update":
      Rumali.ConfigThemeSubmitForm();
      Rumali.liveEditor();
      break;
    case "scopejs_vizs_new":
    case "scopejs_vizs_create":
      Rumali.chartView();
    break;
    case "scopejs_vizs_edit":
    case "scopejs_vizs_update":
      if (chart_name !== "Grid" && chart_name !== "One Number indicators") {
        Rumali.liveEditor();
      } else if(chart_name !== "One Number indicators"){
        Rumali.showAndEditGridPage();
      }else{
         Rumali.showAndEditBoxPage();
      }
      break;
    case "scopejs_datacast_pulls_create":
    case "scopejs_datacasts_file":
    case "scopejs_datacasts_upload":
      Rumali.newDataStorePage();
      break;
    case "scopejs_vizs_show":
      if (chart_name !== "Grid") {
        Rumali.showChartPage();
      } else{

        Rumali.showAndEditGridPage();
      }
      break;
    case "scopejs_datacasts_new":
    case "scopejs_datacasts_create":
      Rumali.dataCastNewPage();
      break;
    case "scopejs_datacasts_edit":
    case "scopejs_datacasts_update":
      Rumali.dataCastNewPage();
      Rumali.initDataCastGrid();
      break;
    case "scopejs_reports_show": //need to break it into 2 switch cases
      Rumali.buildCharts.loadReportChart();
      break;
    case "scopejs_reports_new":
    case "scopejs_reports_create":
    case "scopejs_reports_edit":
    case "scopejs_reports_update":
      Rumali.reportsNewPage();
      break;
    case "scopejs_aggregations_provider_hit_list":
      Rumali.manualCharts.loadReportChart();
    default:
  }
};

