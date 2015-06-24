(function () {
	var grid_getallcolumns
		,	map
		, markers = []
		, marker
		, circles = []
		, circle_group
		, metricflag = false
		, circle_cluster
		, circle_data
		, marker_cluster
		, metric_value
		, menuflag = false
		, radiusflag = false
		, displayed_circle
		, group
		, latitude
		, longitude
		, marker_data;

	$(".scopejs.data_stores.map").ready(function () {
		callGetAllColumnApi();
	  Rumali.showStatistics("id","string");

		//function for handling on click of focus button
		document.getElementById('focus').onclick = function () {
			metric_value = document.getElementById('show_metrics_column').value;
			if (metric_value == "none") {
				PykMap.focusMap(PykMap.markers);
			} else {
				PykMap.focusMap(PykMap.markers);
			}
		};

		document.getElementById("show_latitude_column").onchange = function () {
			changeDimensionOnMetricSelection();
		}

		document.getElementById("show_longitude_column").onchange = function () {
			changeDimensionOnMetricSelection();
		}

		//function for handling cluster checkbox
		document.getElementById( 'cluster_markers' ).onclick = function() {
			metric_value = 	document.getElementById("show_metrics_column").value;
			var cluster = document.getElementById('cluster_markers');
			//console.log(group,"length")
			if (cluster.checked && metric_value == "none") {
				document.getElementById("circle_radius").disabled = true;
				document.getElementById("circle_radius").value = " ";
				map.removeLayer(group);
				plotMarkers(marker_data, true);
				if (map.hasLayer(displayed_circle)) {
					map.removeLayer(displayed_circle);
				}
			} else if (!cluster.checked && metric_value == "none") {
				document.getElementById("circle_radius").disabled = false;
				map.removeLayer(marker_cluster);
				plotMarkers(marker_data, false);
			} else if (cluster.checked && metric_value != "none") {
				document.getElementById("circle_radius").disabled = true;
				document.getElementById("circle_radius").value="";
				map.removeLayer(circle_group);
				changeDimensionOnMetricSelection();
				if (map.hasLayer(displayed_circle)) {
					map.removeLayer(displayed_circle);
				}
				//plotCircles(circle_data,true);
			} else if (!cluster.checked && metric_value!="none") {
				document.getElementById("circle_radius").disabled = false;
				map.removeLayer(circle_cluster);
				changeDimensionOnMetricSelection();
			//	plotCircles(circle_data,false);
			}
		};
		//function for handling dropdown list of metric list
		document.getElementById("show_metrics_column").onchange = function () {
			var cluster = document.getElementById('cluster_markers');
			metric_value = 	document.getElementById("show_metrics_column").value;
			if (metric_value != "none") {
				if (metricflag == true) {
					if (cluster.checked) {
					//	map.removeLayer(circle_cluster);
					} else {
					//	map.removeLayer(circle_group);
					}
				}
				changeDimensionOnMetricSelection();
				metricflag = true;
			} else {
				metricflag = false;
				if (cluster.checked) {
					map.removeLayer(circle_cluster);
					changeDimensionOnMetricSelection();
					//plotMarkers(marker_data, true);
				} else {
					map.removeLayer(circle_group);
					changeDimensionOnMetricSelection();
					//plotMarkers(marker_data, false);
				}
			}
		};

		//function for handling circle on the map
		document.getElementById("circle_radius").onchange = function () {
			markercount =  document.getElementsByClassName("leaflet-marker-icon").length;
			var radius = (document.getElementById("circle_radius").value) * 1000;
		  if ( (radiusflag == true && radius != 0) || (radiusflag == true && markercount > 0) ) {
				map.removeLayer(displayed_circle);
				radiusflag = false;
			} else if (radiusflag == true && radius == 0) {
				map.removeLayer(displayed_circle);
			  divg1.resetFilters();
			  //grid_map.flushToGet().data;
			  self.json_data = grid_show.flushToGet().data;
				Rumali.gridoperation.reloadGrid();
				Rumali.refreshStatistics();
			}
	  	markercount =  document.getElementsByClassName("leaflet-marker-icon");
			if (radius != 0 && markercount.length == 0) {
				displayed_circle = L.circle (
						[ map.getBounds().getCenter().lat , map.getBounds().getCenter().lng ]
					,	radius
					, {weight: 2, fill: true, fillOpacity: 0.3}
				);
			  map.addLayer(displayed_circle);
	  		radiusflag = true;
	  		updateGrid();
		  	displayed_circle.on ({
		    	mousedown: function () {
		        map.on('mousemove', function (e) {
	        		var circles_tobe_displayed = []
								,	markerlength = PykMap.markers.length
								, markercount = [];
	            displayed_circle.setLatLng(e.latlng);
		        });
		    	}
				});

				map.on ('mouseup', function (e) {
					if (displayed_circle.getBounds().contains(e.latlng)) {
						updateGrid();
					}
				});
			}
		};
	});

	var updateGrid = function() {
		var latitude = $("#show_latitude_column").val()
			, longitude = $("#show_longitude_column").val()
			,	filter_array = []
			, pykmap_markers_length = PykMap.markers.length;
	  for (var i = 0; i < pykmap_markers_length; i++) {
	  	var filter_group_array = [];
	  	if ( displayed_circle.getBounds().contains(PykMap.markers[i].getBounds().getCenter()) ) {
	  		filter_group_array.push({
					"column_name": latitude,
					"condition_type": "values",
					"in": [PykMap.markers[i].getLatLng().lat],
					"next":"AND"
				});
				filter_group_array.push({
					"column_name": longitude,
					"condition_type": "values",
					"in": [PykMap.markers[i].getLatLng().lng],
					"next": "OR"
				});
				filter_array.push(filter_group_array);
	  	}
	  }
		map.removeEventListener('mousemove');
		grid_show.executeOnFilter = function () {
			self.json_data = grid_show.flushToGet().data;
			Rumali.gridoperation.reloadGrid();
		};
		grid_map.executeOnFilter = function () {
		};
		divg1.resetFilters();
		grid_map.addFilter(filter_array, true);
		//grid_map.call();
		
	};

	var callGetAllColumnApi = function () {
		var api_request_parameters = {};
	  api_request_parameters["data_types"] = true;
	  api_request_parameters["token"] = gon.token;
	  api_request_parameters['sub_types'] = true;
	 	api_request_parameters['original_names'] = true;
    Rumali.api.originalColumnName(api_request_parameters,function(res){
      grid_getallcolumns = res;
      var latlng = getAllLatLngColumns(grid_getallcolumns);
      console.log(res);
      fillLatLngDropdown(latlng);
      initializePykQuery();
    });
	}

	var getDimensionsMetrics = function () {
	  var obj = {};
	  obj['token'] = gon.token;
    Rumali.api.getDemensionsAndMetricsApiCall(obj,function(data) {
        fillMertricsDropdown(data.metrics);
    });

	};

	var fillMertricsDropdown = function (metrics) {
	 var mertics_dropdown = document.getElementById("show_metrics_column")
		 , metric_length = metrics.length;
		mertics_dropdown.options[0] = new Option("", "none");
		for (var i = 0; i < metric_length; i++) {
			mertics_dropdown.options[i+1] = new Option(metrics[i], metrics[i]);
		}
	}

	var render = function () {
	  var mapbox_config = {
	    "access_token": 'pk.eyJ1IjoiYWtzaGF5YWdyYXdhbCIsImEiOiJXaFJrNDFrIn0.ixJz483ci_-spQCDRHUlRQ',
	    "project_id": 'akshayagrawal.kidg6aa5',
	    "map_container": 'grid_map',
	    "attributions": "Pykih"
	  };
	  if (map = PykMap.renderMap(mapbox_config)) {
	    plotMarkers(marker_data,false);
	    getDimensionsMetrics();
	  }

		map.on("zoomend", function () {
			cluster = document.getElementById("cluster_markers");
			if (cluster.checked ) {
				markercount=[];
				setTimeout(function () {
					markercount = document.getElementsByClassName("leaflet-marker-icon");
		  		if (markercount.length == 0) {
						document.getElementById("circle_radius").disabled = false;
					} else {
						document.getElementById("circle_radius").value = "";
						document.getElementById("circle_radius").disabled = true;

						if (displayed_circle) {
							map.removeLayer(displayed_circle);
						};
					}
				}, 500)
			}

		})

	}

	var initializePykQuery = function(){
		grid_map = new PykQuery.init("aggregation", "local", "grid_map", "rumi");
	  grid_map.rumiparams = Rumali.gridoperation.restEndPoint();
		grid_map.addImpacts(["divg1"], true);
	  grid_map.metrics = {"id":["count"]};
	  grid_map.dimensions = [$("#show_latitude_column").val(), $("#show_longitude_column").val()];
	  grid_map.limit = 2000;
	  grid_map.dataformat = 'csv';
	  grid_map.executeOnFilter = function(){
	  	var my_map_data = grid_map.flushToGet().data;
		  if (my_map_data != undefined) {
		  	marker_data =  d3.csv.parse(my_map_data);
		    self.my_map_data = my_map_data.data;
		    render();
		  } else {
		  	console.log("lala2");
		  }
	  }
	  grid_map.call();
	  
	}

	//api call for getting all column name
	var getAllLatLngColumns = function (grid_getallcolumns) {
		var sub_types = grid_getallcolumns.columns.sub_types
			,	latflag = false
			,	lngflag = false
			,	latitude = []
			, longitude = []
			, index
			,	edit_url = window.location.href;
		for (var i in sub_types) {
			if (sub_types[i] === "latitude") {
				latitude.push({"name":grid_getallcolumns.columns.original_column_names[i],"value":i});
				latflag = true;
			} else if (sub_types[i] === "longitude") {
				longitude.push({"name":grid_getallcolumns.columns.original_column_names[i],"value":i});
				lngflag = true;
			}
		}
    edit_url = edit_url.split('/');
    index = edit_url.indexOf("map");
    edit_url[7] = "edit";
    edit_url = edit_url.join("/");
		if (latflag == false && lngflag == true) {
	    alert("You have set following columns "+ longitude +" as Longitude, however we could not find any column which is set as Latitude. Please, select a column, go to the Format menu and set the Sub Type as Latitude to continue.");
	    window.location = edit_url;
	    $("#explore_on_map_button").attr("selected", false);
	  } else if (lngflag == false && latflag == true){
	    alert(" You have set following columns "+ latitude +" as Latitude, however we could not find any column which is set as Longitude. Please, select a column, go to the Format menu and set the Sub Type as Longitude to continue.");
	    window.location = edit_url;
	    $("#explore_on_map_button").attr("selected", false);
	  } else if (lngflag == false && latflag == false) {
	    alert("The \"Explore on Map\" functionality is only for data sets with latitudes and longitudes. Please, select a column, go to the Format menu and set the Sub Type as Latitude and Longitude to continue.");
	    window.location = edit_url;
	    $("#explore_on_map_button").attr("selected", false);
	  }
	  return([latitude,longitude]);
	};

	//function for filling dropdown of available lat and lng
	var fillLatLngDropdown = function (latlng) {
		console.log(latlng[1][1])
		var lat = document.getElementById("show_latitude_column")
			, lat_length = latlng[0].length
			, lng = document.getElementById("show_longitude_column")
			, lng_length = latlng[1].length;
		for (var i = 0; i < lat_length; i++) {
			lat.options[i] = new Option(latlng[0][i]["name"], latlng[0][i]["value"]);
		}
		for (var i = 0; i < lng_length; i++) {
			lng.options[i] = new Option(latlng[1][i]["name"], latlng[1][i]["value"]);
		}
	};


	//function for displaying markers on map
	var plotMarkers = function (marker_data, cluster_status) {
		var markerlength = marker_data.length
			, latitude = $("#show_latitude_column").val()
			, longitude = $("#show_longitude_column").val();
		marker_cluster = new L.MarkerClusterGroup();

	  marker_config = {
	    "click": onClickOfMarkers,
	    "type": {
	      "show": "circle",
	      "radius": 4
	    }
	  }

	  PykMap.plotMarkers(marker_data, latitude, longitude, marker_config)

		if (cluster_status) {
			marker_cluster.addLayers(PykMap.markers)
			map.addLayer(marker_cluster);
		} else {
			group = PykMap.focusMap(PykMap.markers);
			map.addLayer(group);
		}
	}

	//function used to display circles when metric is selected

	var plotCircles = function (circle_data, cluster_status) {
		var latitude = $("#show_latitude_column").val()
			, longitude = $("#show_longitude_column").val()
			, circle_length = circle_data.length;

		circle_cluster = new L.MarkerClusterGroup();
		metric_value = document.getElementById("show_metrics_column").value;
		circles = [];

		marker_config = {
	    "click": onClickOfMarkers,
	    "type": {
	      "show": "circle",
	      "metric_value": document.getElementById("show_metrics_column").value
	    }
	  }
	  PykMap.plotMarkers(circle_data, latitude, longitude, marker_config);
		if (cluster_status && metric_value != "none") {
			circle_cluster.addLayers(PykMap.markers);
			map.addLayer(circle_cluster);
		} else if (!cluster_status && metric_value != "none") {
	    circle_group = PykMap.focusMap(PykMap.markers);
			map.addLayer(circle_group);
		}
	};


	var addRemoveCircleAndMarkerLayer = function () {
	//grid_map.call();
		metric_value = 	document.getElementById("show_metrics_column").value;
		var cluster = document.getElementById('cluster_markers')
			, my_map_data =  grid_map.flushToGet().data;

	  if (my_map_data) {
	  	marker_data = d3.csv.parse(my_map_data);
	    self.my_map_data = my_map_data.data;
		  if (cluster.checked && metric_value == "none") {
				map.removeLayer(marker_cluster)
				plotMarkers(marker_data, true);
			} else if (!cluster.checked && metric_value == "none") {
				map.removeLayer(group);
				//map.removeLayer(marker_cluster)
				plotMarkers(marker_data, false);
			} else if (cluster.checked && metric_value != "none") {
				if (circle_cluster && metricflag) {
					map.removeLayer(circle_cluster);
					plotCircles(marker_data, true);
				} else {
					// circle_data =  changeDimensionOnMetricSelection();
					map.removeLayer(marker_cluster);
					plotCircles(marker_data, true);
				}
			} else if (!cluster.checked && metric_value != "none") {
				if (circle_group && metricflag) {
					map.removeLayer(circle_group);
					plotCircles(marker_data, false);
				} else if (group && metricflag) {
					map.removeLayer(group);
					plotCircles(marker_data, false);
				} else if (group && !metricflag) {
					map.removeLayer(group);
					plotCircles(marker_data, false);
				} else if (circle_cluster) {
					map.removeLayer(circle_cluster);
					plotCircles(marker_data, false);
				}
				// circle_data =  changeDimensionOnMetricSelection();
			}
		}
	}

	var changeDimensionOnMetricSelection = function () {
		metric_value = document.getElementById("show_metrics_column").value;
		grid_map.resetDimensions();
	//	console.log(metric_value,"changeDimensionOnMetricSelection1")
		if (metric_value != "none") {
	//		console.log(metric_value,"changeDimensionOnMetricSelection not")
			grid_map.dimensions = [$("#show_latitude_column").val(), $("#show_longitude_column").val(), metric_value];
		} else {
	//		console.log(metric_value,"changeDimensionOnMetricSelection yes")
			grid_map.dimensions = [$("#show_latitude_column").val(),$("#show_longitude_column").val()];
		}
		grid_map.executeOnFilter = function(){
			addRemoveCircleAndMarkerLayer();
		}
		grid_map.call();
		//console.log(metric_value, "executed")
		// circle_data = grid_map.flushToGet().data;
		// circle_data = d3.csv.parse(circle_data);
		// return circle_data;
	}

	var onClickOfMarkers = function (e) {
		var latitude = $("#show_latitude_column").val()
			, longitude = $("#show_longitude_column").val()
			, filter_group_array = []
			,	filter_array=[];
		filter_group_array.push({
			"column_name": latitude,
			"condition_type": "values",
			"in": [this.getLatLng().lat],
			"next":"AND"
		});
		filter_group_array.push({
			"column_name": longitude,
			"condition_type": "values",
			"in": [this.getLatLng().lng],
			"next": "OR"
		});
		filter_array.push(filter_group_array);
		grid_show.executeOnFilter = function () {
			self.json_data = grid_show.flushToGet().data;
			Rumali.gridoperation.reloadGrid();
		};
		grid_map.executeOnFilter = function () {};
		grid_map.addFilter(filter_array, true,true);
		//grid_map.call();
    
		//grid_map.addFilter([[{"column_name": latitude, "condition_type": "values", "in": [this.getLatLng().lat], "next": "AND"},{"column_name": longitude, "condition_type": "values", "in": [this.getLatLng().lng], "next": "AND"}]], true);
		//grid_show.call();
		//$("#mapConfigure").removeClass("active");
		//$("#hide_when_column_is_selected_2").addClass("active");
		//$("#column").addClass("active");
		//$("#map_options").removeClass("active");
		//$("#hide_when_column_is_selected_2").show();
		//$("#column").show();
		//console.log(this.getLatLng().lng);
		
	}
})();
