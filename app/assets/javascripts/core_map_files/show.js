Rumali.showMapFile = function(){

  map = L.map("map_container");
  var osmAttrib='<a href="https://pykih.com"> Pykih | </a><a href="http://openstreetmap.org">OpenStreetMap</a> contributors';
  var osm = new L.TileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png',{minZoom: 1, maxZoom: 19,attribution: osmAttrib});
  map.addLayer(osm);
  console.log(gon.file_type)        
  d3.json(data_file, function(data) {
    if(gon.file_type==="TopoJson") {
      data = topojson.feature(data, data.objects)
    }
    zipLayer = L.geoJson(data,{
      style: getStyle,
    }).addTo(map);
    map.fitBounds(zipLayer.getBounds());
  });
  var getStyle = function (feature) {
    return {
        weight: 1,
        opacity: 0.8,
        color: 'red',
        fillOpacity: 0.7,
        fillColor: "pink"
    };
  }
}