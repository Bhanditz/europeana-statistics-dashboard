var data1,data2,count=0,marker_groups={},all_markers={},cluster_flag=false,previous_group,i=0;
Rumali.bangaloreGeo = function () {
	execute();
}

//execute function which calls all function
var execute = function () {
var mapbox_object = JSON.parse ( gon.map_object )
	, data_store_params = JSON.parse ( gon.data_store_params )
	,map;

  fill_cluster_column ( data_store_params );
  render ( mapbox_object );
  query ( data_store_params );
  document.getElementById("show_cluster_column").onchange = function () { 
    var cluster_value_selected = document.getElementById("show_cluster_column").value;
    if(cluster_value_selected!="none"){
      clusterMarkers(all_markers[cluster_value_selected],marker_groups[cluster_value_selected],cluster_flag);
      cluster_flag=true;
    }
  }
	//query1 ( data_store_params );
//  console.log(data_store_params,"data")
}

//render function to load map into div
var render = function ( mapbox_object ) {
	mapbox_object.map_container = "map_container";
  PykMap.renderMap(mapbox_object);
  // L.mapbox.accessToken = mapbox_object.access_token;
	// map = L.mapbox.map('map_container',mapbox_object.project_id,
	// {
 //    attributionControl: false,
 //    infoControl: false,
 //    minZoom: mapbox_object.minZoom? mapbox_object.minZoom : 2,
 //    maxZoom: mapbox_object.maxZoom? mapbox_object.maxZoom : 14
	// }).setView([13,77.6],mapbox_object.zoom_level)
	//map.addControl(L.mapbox.infoControl().addInfo('Pykih'));
	//document.getElementById("map_container")
  if(gon.heat_map_file!=undefined){
    renderHeatMap();
    console.log(gon.heat_map_file,"heat_map_file");
  }

}

var renderHeatMap = function(){
  $.getJSON(gon.heat_map_file, function(data) {
    var zipLayer = L.geoJson(data,{
      style: getStyle,
     }).addTo(map);
  });
}

var getStyle = function (feature) {
  return {
      weight: 1,
      opacity: 1,
      color: '#066f7f',
      fillOpacity: 0.8,
      fillColor:getColor()
  };
}
var getColor = function(){
    i+=1;
    if(i===6){i=0;}; 
     return i === 1 ? '#0ddfff' :
          i === 2  ? '#0bc8e5' :
          i === 3  ? '#0ab2cc' :
          i === 4  ? '#099cb2' :
          i === 5   ? '#078599' :
          '';
}
//funciton for getting data from one file
var query = function ( data_store_params ) {

  for( var i in data_store_params ) {
 //   console.log(data_store_params[i]["rumi_params"])
    var div_for_query = document.createElement("div");
    div_for_query.id="map_container"+count;
 //   console.log(div_for_query.id);
    window['map_container'+count] = new PykQuery.init("aggregation", "local",div_for_query.id, "rumi");
    window['map_container'+count].rumiparams = data_store_params[i]["rumi_params"]+"/";
    window['map_container'+count].addImpacts(["divg1"],true);
    window['map_container'+count].metrics ={"id":["count"]};
    window['map_container'+count].dimensions =[data_store_params[i]["latitude"], data_store_params[i]["longitude"]];
    window['map_container'+count].limit = 2000;
    window['map_container'+count].dataformat = 'csv';
    window['map_container'+count].call();
    var my_map_data =  window['map_container'+count].flushToGet().data;
    if(my_map_data != undefined) {
    	data1 =  d3.csv.parse(my_map_data);
 //     console.log(data1,"my_map_data")
      plotMarkers(data1,data_store_params[i])
    }else{
      console.log("lala2");
    }
   count++;
  }  

}

//function for plotting markers
var plotMarkers = function (marker_data,data_store_params) {
 // console.log(marker_data.length);
  var markerlength = marker_data.length
  ,markers=[];
//  console.log(marker_data,data_store_params["latitude"],"data_store_params");
  var lat = data_store_params["latitude"],
  lng = data_store_params["longitude"];

	for( var i = 0 ; i < markerlength; i++){
		if(marker_data[i][lat] && marker_data[i][lng]){
      marker =  L.circleMarker(new L.LatLng( marker_data[i][lat], marker_data[i][lng]),{
          fill:true,
          fillOpacity:0.7,
          fillColor:"#e67e22",
          color:"red",
          title:"ak",
          radius:4
        })
			markers.push(marker);
		}
  }

//  console.log(data_store_params,"hhhh");
	marker_groups[data_store_params["name"]] = new L.featureGroup(markers);
  all_markers[data_store_params["name"]] = markers;
	map.addLayer(marker_groups[data_store_params["name"]]);
//  console.log(all_markers,"all_markers");
}

//function for filling dropdown list of clusters
var fill_cluster_column = function (data_store_params) {
  count1 = 0;
  var cluster_column = document.getElementById("show_cluster_column");
//  console.log(data_store_params[i],"data")
  cluster_column.options[0] = new Option("", "none");
  for ( var i in data_store_params ) {
    count1++;
    cluster_column.options[count1] = new Option(i,i);
//    console.log(count)
  }
} 


//function for clustering markers
var clusterMarkers = function (marker_data_selected,marker_group,cluster_flag) {
 if(cluster_flag){
  map.removeLayer(previous_group);
 } 
//  console.log(marker_data_selected,marker_group,"datadata"); 
  var marker_cluster = new L.MarkerClusterGroup();
  map.removeLayer(marker_group);
  marker_cluster.addLayers(marker_data_selected).addTo(map);
  previous_group = marker_group;
}

// //get all column api
// var cal_get_allcolumn_api = function ( data_store_params ) {
//   console.log(data_store_params)
//   var api_request_parameters = {};
//   api_request_parameters["original_names"] = true;
//   api_request_parameters["data_types"] = true;
//   api_request_parameters["token"] = gon.token;
//   api_request_parameters['sub_types'] = true;
//   $.ajax({
//     url: rumi_api_endpoint + data_store_params["Earthquake.csv"]["rumi_params"] + "/column/all_columns",
//     data: api_request_parameters, //return  data
//     dataType: 'json',
//     type: 'GET',
//     //async:false,
//     success: function ( res ) {
//       grid_getallcolumns = res;
//       var latlng = getlatlng_columns(grid_getallcolumns);
//       console.log(latlng);
//     },
//     error: function () {
//       console.error('Error in fetch data from server');
//     }
//   });
// }

// //get name of all lat lng in the dataset
// var getlatlng_columns = function ( grid_getallcolumns ) {
//   console.log(grid_getallcolumns,"columns")
//   var sub_types = grid_getallcolumns.columns.sub_types,latflag=false,lngflag=false;
//   var latitude=[],longitude=[];
//   for(var i in sub_types){
//     if(sub_types[i]==="latitude"){
//       latitude.push(i);
//       latflag=true;
//     }else if (sub_types[i]==="longitude"){
//       longitude.push(i);
//       lngflag=true;
//     }
//   }
//   return([latitude,longitude])
// };
