window.onload = function () {      
  $("#loader .centered").slideUp(function(){
    $("#loader").fadeOut(function(){
      $("#loader").remove();
    });
  });
  
  var html_body_id = document.getElementsByTagName("body")[0].id
  switch (html_body_id) {
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
      if (chart_name !== "Grid") {
        Rumali.liveEditor();
      } else {
        (gon.dataformat == "csv") ? Rumali.showAndEditGridPage() : Rumali.JsonDataPage();
      }
      break;
    case "scopejs_data_stores_new":
    case "scopejs_data_store_pulls_create":
      Rumali.newDataStorePage();
      break;
    case "scopejs_vizs_show":
      if (chart_name !== "Grid") {
        Rumali.showChartPage();
      } else {
        (gon.dataformat == "csv") ? Rumali.showAndEditGridPage() : Rumali.JsonDataPage();
      }
      break;
    default:
  }
};

