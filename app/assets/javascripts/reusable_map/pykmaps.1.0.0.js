PykMap = {};


PykMap.renderMap = function(mapbox_object) {
  try { 
    // L.mapbox.accessToken = mapbox_object.access_token;
    
    // map = L.mapbox.map(mapbox_object.map_container, mapbox_object.project_id,
    // {
      map = L.map(mapbox_object.map_container).setView([19.095 , 72.939],11);
      var osmAttrib='<a href="https://pykih.com"> Pykih |Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors';
      var osm = new L.TileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png',{minZoom: 2, maxZoom: 19,attribution: osmAttrib});
      map.addLayer(osm);
      // attributionControl: false,
      // infoControl: false,
      // minZoom: mapbox_object.minZoom? mapbox_object.minZoom : 2,
      // maxZoom: mapbox_object.maxZoom? mapbox_object.maxZoom : 19
   // })
    
    mapbox_object.onLoadFocus_lat = mapbox_object.onLoadFocus_lat? mapbox_object.onLoadFocus_lat : 13
    mapbox_object.onLoadFocus_long = mapbox_object.onLoadFocus_long? mapbox_object.onLoadFocus_long : 77.6
    map.setView([mapbox_object.onLoadFocus_lat, mapbox_object.onLoadFocus_long], mapbox_object.zoom_level)
    
   // map.addControl(L.mapbox.infoControl().addInfo(mapbox_object.attributions));
  }
  catch (e) {
    alert(e);
    return false;
  }
  
  return map;
};

PykMap.focusMap = function(markers) {
  var markers_group = new L.featureGroup(markers);
  map.fitBounds(markers_group.getBounds());
  return markers_group
}
PykMap.plotMarkers = function(marker_data,column_lat,column_lng, marker_config){
  is_circle = marker_config.type.show
  var config_style = marker_config.style;
  if (config_style === undefined) {
    config_style = {      
      fillOpacity:0.7,
      fillColor:"#e67e22",
      color:"red",
      title:"circle"
    };
  }
  var markerslength = marker_data.length;
  PykMap.markers = [];
  
  for ( var i = 0; i<markerslength; i++ ) {
    if( marker_data[i][column_lat] && marker_data[i][column_lng] ) {
      if(is_circle == "circle"){
        var circle =  L.circleMarker(L.latLng(marker_data[i][column_lat],marker_data[i][column_lng]),config_style);
        radius = marker_config.type.radius
        if(radius > 0){
          circle.setRadius(radius);
        }else{
          var metric_value = marker_config.type["metric_value"];
          var minValue = d3.min(marker_data, function(d) { return +d[metric_value];} );
          var maxValue = d3.max(marker_data, function(d) { return +d[metric_value];} );
          var scale = d3.scale.linear().domain([ minValue,maxValue]).range([ 1, 15 ]);
          circle.setRadius(scale(marker_data[i][metric_value]));
        }
        PykMap.markers.push(circle);
        circle.on('click', marker_config["click"]);
      }else{
        var circle =  new L.Marker(L.latLng(marker_data[i][column_lat],marker_data[i][column_lng]));
        PykMap.markers.push(circle);
      }
      
    }
  }
  return PykMap.markers;
}