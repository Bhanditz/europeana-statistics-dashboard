$(document).ready(function() {
  $(".s3-publish-details").click(function(event) {
    var link = "<a href='"+$(this).attr("s3-url")+"' target='_blank'>"+$(this).attr("s3-url")+"</a>"
    $("#s3-published-url").html(link);
    $("#s3-published-last-updated").html($(this).attr("s3-published-at"));
    $("#s3-published-requested-at").html($(this).attr("s3-requested-at"));
    event.preventDefault();
  });
});
