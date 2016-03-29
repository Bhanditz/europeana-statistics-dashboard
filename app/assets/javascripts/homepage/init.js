Rumali.loadHomePage = function(){
  var k = new PykCharts.maps.oneLayer({
    selector: "#europeana_navigator_map",
    data: "/static-data/map_data.json",
    map_code: "europe",
    click_enable:true,
    default_color:["#E4E4E4"],
    chart_onhover_effect: "color_saturation",
    chart_onhover_highlight_enable: true,
    click_enable: false,
    legends_enable: 'no',

    // optional
    chart_height: 800,
    chart_width: 1200
  });
  k.execute();
}