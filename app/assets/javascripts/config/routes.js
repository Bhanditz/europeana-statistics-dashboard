window.onload = function () {
  switch (gon.scopejs) {
    case "scopejs_reports_show":
      Rumali.buildCharts.loadReportChart();
      break;
    case "scopejs_aggregations_countries":
      Rumali.loadHomePage();
      break;
    case "scopejs_reports_new":
    case "scopejs_reports_create":
    case "scopejs_reports_edit":
    case "scopejs_reports_update":
      Rumali.reportsNewPage();
      break;
    default:
  }
};

