
Rumali.histogram = function (field_name,dataType,obj,brush_min,brush_max) {
  var total_bars = 5;
  // if no value for brush_min amd brush_max then initilize with zeros
  if (!brush_min ) {
    brush_min = 0;
    $("#min_value").val("Min");
  }
  if (!brush_max) {
    brush_max = 0;
    $("#max_value").val("Max");
  }
  $("#histogram-chart").empty();
  var azaxcall = function (max,min) {
    var column_name = field_name;
    new_column_name = field_name;
    $("#filter_toggle").show();
    Rumali.executeAfterHistogramFilter();
    var prev_min = $("#min_value").attr("data-prev_val")
      , prev_max = $("#max_value").attr("data-prev_val")
      , new_min = parseFloat(min).toFixed(2)
      , new_max = parseFloat(max).toFixed(2);
    $("#min_value").val(new_min);
    $("#max_value").val(new_max);
    $("#min_value").attr("data-prev_val",new_min);
    $("#max_value").attr("data-prev_val",new_max);
    if (prev_min != new_min || prev_max != new_max) {
      var toggle_val = $("#filter_toggle :checked").val()
        , is_not = false;
      if(toggle_val == "notin"){
        is_not = true;
      }
      pyk_histogram.addFilter([[{"column_name": new_column_name, "condition_type": "range", "condition": {"min": min, "max": max, "not": is_not}, "override_filter" : true, "next": "AND"}]], true ,true);
    }
  }
  if (dataType === "integer" || dataType === "double") {
    $("#histogram-chart").show();
    $("#histogram-chart").html("<span style='float:left'><h5 style='margin-top: 0px; font-size: 14px; padding-top: 0px;'>Filter by value</h5></span><a id='reset'><u>Reset</u></a>");
    var data = [];
    for (var key in obj) {
      if (key && !isNaN(key) && key!=="undefined") {
        data.push({
          key: parseFloat(key),
          value: parseInt(obj[key],10)
        });
      }
    }
    var xRange = d3.extent(data, function (d) { return d.key; })
      , xMin = xRange[0]
      , xMax = xRange[1] + parseFloat((((xRange[1]-xRange[0]) / 10)).toFixed(2))
      , incrementby = ((xRange[1] - xRange[0]) / total_bars)
      , new_data = []
      , incremented = xRange[0]
      , increment = xRange[0] + incrementby
      , previous_incremented = xRange[0] - 1
      , count = 0;
    if (brush_min == 0 || brush_max == 0) {
      $("#min_value").val(parseFloat(xMin).toFixed(2));
      $("#min_value").attr("data-val",parseFloat(xMin).toFixed(2));
      $("#max_value").val(parseFloat(xMax).toFixed(2));
      $("#max_value").attr("data-val",parseFloat(xMax).toFixed(2));
      $("#filter_toggle").hide();
      $("#min_value").attr("placeholder",parseFloat(xMin).toFixed(2));
      $("#max_value").attr("placeholder",parseFloat(xMax).toFixed(2));
    } else{
      $("#min_value").val(parseFloat(brush_min).toFixed(2));
      $("#max_value").val(parseFloat(brush_max).toFixed(2));
      $("#filter_toggle").show();
    }
    for (var i = 0; i < total_bars; i++) {
      count = data.filter(function (d) {
        return d.key <= increment && d.key > previous_incremented;
      });
      new_data.push({
        key: incremented,
        value: d3.sum(count, function (d) { return d.value })
      });
      previous_incremented = increment;
      increment = increment + incrementby;
      incremented = incremented + incrementby;
    }
    //console.log(new_data, xMin,xMax);

    var yRange = d3.extent(new_data, function (d) { return d.value; })
      , whitespace = parseFloat(((yRange[1] - yRange[0]) / 10).toFixed(2))
      , yMin = 0
      , yMax = yRange[1] + whitespace
      , formatCount = d3.format(",.0f")
      , margin = {top: 10, right: 20, bottom: 30, left: 10}
      , width = 250 - margin.left - margin.right
      , height = 120 - margin.top - margin.bottom
      , x = d3.scale.linear()
        .domain([xMin, xMax])
        .range([0, width])
      , y = d3.scale.linear()
        .domain([yMin, yMax])
        .range([height, 0])
      , xAxis = d3.svg.axis()
        .scale(x)
        .ticks(3)
        .orient("bottom");

    svg = d3.select("#histogram-chart").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var bar = svg.selectAll(".bar")
      .data(new_data)
      .enter().append("g")
      .attr("class", "bar")
      .attr("transform", function (d) { return "translate(" + x(d.key) + "," + y(d.value) + ")"; });

    bar.append("rect")
      .attr("x", 1)
      .attr("width", width / (total_bars + 1))
      .attr("height", function (d) { return height - y(d.value); });

    bar.append("text")
      .attr("dy", ".75em")
      .attr("y", -12)
      .attr("x", (width / total_bars) / 2)
      .attr("text-anchor", "middle")
      .text(function (d) { return formatCount(d.value); });

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

    var min_value = xMin
      , max_value = xMax;
    if (brush_min && brush_min > 0) {
      min_value = brush_min;
      max_value = brush_max;
    } else {
      min_value = 0;
      max_value = 0;
    }

    function brushend () {
      brush_extent = d3.event.target.extent()
      brush_min = brush_extent[0]
      brush_max = brush_extent[1];
      if(brush_max != brush_min){
        azaxcall(brush_max,brush_min);
      }
    }
    global_brush = d3.svg.brush().x(x).extent([min_value,max_value])
      .on("brushend", brushend)
    brush = svg.append("g")
      .attr("class", "brush")
      .call(global_brush);
    brush.selectAll("rect")
      .attr("height", height);
    var resizeHandlePath = function (d) {
        var e = +(d == "e"), x = e ? 1 : -1, y = height / 3;
        return "M" + (0.5 * x) + "," + y
            + "A6,6 0 0 " + e + " " + (6.5 * x) + "," + (y + 6)
            + "V" + (2 * y - 6)
            + "A6,6 0 0 " + e + " " + (0.5 * x) + "," + (2 * y)
            + "Z"
            + "M" + (2.5 * x) + "," + (y + 8)
            + "V" + (2 * y - 8)
            + "M" + (4.5 * x) + "," + (y + 8)
            + "V" + (2 * y - 8);
    };

    brush.selectAll(".resize").append("path").attr("d", resizeHandlePath);
    //brush.extent([110001,428749.7]);
    $("#pyk_histogram").show();
    $("#histogram_min_max").show();
    $("#merge").hide();
  } else if (dataType === "date") {
      // histogram not for date
      return false;
      $("#histogram-chart").html("<span style='float:left'><h5>Distribution <span class='gray thin'>of data</span></h5></span><a id='reset'><u>Reset</u></a>");

      var data = [];
      for (var key in obj) {
        if (key && key!=="undefined") {
          data.push({
            key: new Date(key),
            value: parseInt(obj[key],10)
          });
        }
      }

      var xRange = d3.extent(data, function (d) { return new Date(d.key); })
        , xMin = xRange[0]
        , xMax = new Date(new Date(xRange[1]).getTime() + Math.ceil((xRange[1] - xRange[0]) / 10))
        , incrementby = Math.ceil((xRange[1] - xRange[0]) / total_bars)
        , new_data = []
        , incremented = xRange[0]
        , increment = new Date(xRange[0]).getTime() + incrementby
        , previous_incremented = new Date(new Date(xRange[0]).getTime() - 86400000)
        , count = 0;


      for (var i = 0; i < total_bars; i++) {
        count = data.filter(function (d) {
          return new Date(d.key).getTime() <= new Date(increment).getTime() && new Date(d.key).getTime() > new Date(previous_incremented).getTime();
        });
        //console.log(count);
        new_data.push({
          key: new Date(incremented),
          value: d3.sum(count, function (d) { return d.value; })
        });
        previous_incremented = increment;
        increment = new Date(new Date(increment).getTime() + incrementby);
        incremented = new Date(new Date(incremented).getTime() + incrementby);
      }

    var yRange = d3.extent(new_data, function (d) { return d.value; })
      , whitespace = parseFloat(((yRange[1] - yRange[0]) / 10).toFixed(2))
      , yMin = 0
      , yMax = yRange[1] + whitespace
      , formatCount = d3.format(",.0f")
      , margin = {top: 10, right: 20, bottom: 30, left: 10}
      , width = 250 - margin.left - margin.right
      , height = 120 - margin.top - margin.bottom
      , x = d3.time.scale()
        .domain([xMin, xMax])
        .range([0, width])
      , y = d3.scale.linear()
        .domain([yMin, yMax])
        .range([height, 0])
      , xAxis = d3.svg.axis()
        .scale(x)
        .ticks(3)
        .orient("bottom");

    svg = d3.select("#histogram-chart").append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    var bar = svg.selectAll(".bar")
      .data(new_data)
      .enter().append("g")
      .attr("class", "bar")
      .attr("transform", function (d) { return "translate(" + x(d.key) + "," + y(d.value) + ")"; });

    bar.append("rect")
      .attr("x", 1)
      .attr("width", width/(total_bars+1))
      .attr("height", function (d) { return height - y(d.value); });

    bar.append("text")
      .attr("dy", ".75em")
      .attr("y", -12)
      .attr("x", (width/total_bars) / 2)
      .attr("text-anchor", "middle")
      .text(function (d) {return formatCount(d.value); });

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

    brush = svg.append("g")
      .attr("class", "brush")
      .call(d3.svg.brush().x(x)
      .on("brushend", brushend1));

    brush.selectAll("rect")
      .attr("height", height);

    var resizeHandlePath = function (d) {
        var e = +(d == "e"), x = e ? 1 : -1, y = height / 3;
        return "M" + (0.5 * x) + "," + y
            + "A6,6 0 0 " + e + " " + (6.5 * x) + "," + (y + 6)
            + "V" + (2 * y - 6)
            + "A6,6 0 0 " + e + " " + (0.5 * x) + "," + (2 * y)
            + "Z "
            + "M" + (2.5 * x) + "," + (y + 8)
            + "V" + (2 * y - 8)
            + "M" + (4.5 * x) + "," + (y + 8)
            + "V" + (2 * y - 8);
    };

    brush.selectAll(".resize").append("path").attr("d", resizeHandlePath);

    function brushend1() {
      svg.classed("selecting", !d3.event.target.empty());
      brush_extent = d3.event.target.extent()
      brush_min = brush_extent[0]
      brush_max = brush_extent[1];
    }
  } else{
      $("#histogram_min_max").hide();
  }
}

var check_histogram_min_max_values = function() {
  var hist_min = parseFloat($("#min_value").attr("data-val"))
    , hist_max = parseFloat($("#max_value").attr("data-val"))
    , prev_min = parseFloat($("#min_value").attr("data-prev_val"))
    , prev_max = parseFloat($("#max_value").attr("data-prev_val"))
    , new_min = parseFloat($("#min_value").val())
    , new_max = parseFloat($("#max_value").val());
  $("#min_value").attr("data-prev_val",new_min);
  $("#max_value").attr("data-prev_val",new_max);
  if (prev_min != new_min || prev_max != new_max) {
    if ((new_min < hist_max && new_min >= hist_min) && (new_max > hist_min && new_max <= hist_max) && (new_max > new_min)) {
      var toggle_val = $("#filter_toggle :checked").val()
        , is_not = false;
      if(toggle_val == "notin"){
        is_not = true
      }
      Rumali.executeAfterHistogramFilter(new_min,new_max);
      pyk_histogram.addFilter([[{"column_name": new_column_name, "condition_type": "range", "condition": {"min": new_min, "max": new_max, "not": is_not}, "override_filter" : true,"next": "AND"}]], true ,true);
    }
  }
}  
Rumali.sidebarHistogram = function(){  
  $(document).on('blur', '.histogram-val', function() {
    $("#filter_toggle").show();
    check_histogram_min_max_values();
  });
}
$(document).on('click', '#reset', function () {
    d3.select("rect.extent")
      .attr("x", 0)
      .attr("width", 0);
    d3.selectAll("g.resize")
      .style("display", "none");
    divg1.destroyColumn(new_column_name);
    Rumali.gridoperation.showFilterCount();
});
