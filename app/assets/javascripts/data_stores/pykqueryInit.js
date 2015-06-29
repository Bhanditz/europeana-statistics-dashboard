
Rumali.pykqueryInit = function () {
  grid_show = new PykQuery.init("select", "local", "grid_show", "rumi");
  grid_columns = new PykQuery.init("aggregation", "local", "grid_columns", "rumi");
  divg1 = new PykQuery.init("aggregation", "global", "divg1", "rumi");
  pyk_statistics = new PykQuery.init("aggregation", "local", "pyk_statistics", "rumi");
  pyk_statistics.rumiparams = Rumali.gridoperation.restEndPoint();
  grid_unique_values = new PykQuery.init("aggregation", "local", "grid_unique_values", "rumi");
  grid_unique_values.rumiparams = Rumali.gridoperation.restEndPoint();
  pyk_histogram = new PykQuery.init("aggregation", "local", "pyk_histogram", "rumi");
  pyk_histogram.rumiparams = Rumali.gridoperation.restEndPoint();
  pyk_histogram.addImpacts(["divg1"],false);
  grid_datatypes = new PykQuery.init("datatype", "local", "grid_datatypes", "rumi");
  grid_datatypes.rumiparams = Rumali.gridoperation.restEndPoint();
  grid_datatypes.addImpacts(["divg1"],false);
  divg1.addImpacts(["grid_show"],false);
  divg1.listFilters("list_applied_filters");
  column_values_filter = new PykQuery.init("aggregation", "local", "column_values_filter", "rumi");
  // grid_unique_values.storeObjectInMemory('pyk_statistics');
  column_values_filter.addImpacts(["divg1"],false);
  divg1.addImpacts(["pyk_statistics"], false);
  column_values_filter.rumiparams = Rumali.gridoperation.restEndPoint();
}
