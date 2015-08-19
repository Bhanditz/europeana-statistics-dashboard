var getApiFromString = function(api){
  api = api.split(".");
  return PykCharts[api[1]][api[2]];
}

