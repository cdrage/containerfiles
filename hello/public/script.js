$(document).ready(function() {
  var headerTitleElement = $("#header h1");
  var hostAddressElement = $("#host-address");

  // Set the startup as random colours
  var colors = ["#1f77b4", "#2ca02c", "#d62728", "#9467bd", "#ff7f0e"];
  var randomColor = colors[Math.floor(5 * Math.random())];
  (function setElementsColor(color) {
    headerTitleElement.css("color", color);
    entryContentElement.css("box-shadow", "inset 0 0 0 2px " + color);
    submitElement.css("background-color", color);
  })(randomColor);

  hostAddressElement.append(document.URL);
});
