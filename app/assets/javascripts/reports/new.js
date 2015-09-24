Rumali.reportsNewPage = function () {
  $(".selected-chart").click(function(event) {
    html_in = this.dataset.auto_html_div
    $("#input").insertAtCaret(html_in);    
    setTimeout(function(){$("svg").remove(); genereteChartInMarkdown();},500);
    $("#chart-selector").modal("hide");
    event.preventDefault();
  });

  $("#input").change(function() {
    setTimeout(function(){$("svg").remove(); genereteChartInMarkdown();},100);
  });
}