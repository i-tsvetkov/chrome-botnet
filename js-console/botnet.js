function get_data(url, func) {
  var xhr = new XMLHttpRequest();
  xhr.onload = () => func(xhr.responseText);
  xhr.open('GET', url);
  xhr.send();
}

var _tab_id_ = '&id=' + Math.random().toString(36).slice(2);

setInterval(function () {
  get_data('https://localhost:8000/js?' + _tab_id_, function (js) {
    if (js != '')
      get_data('https://localhost:8000/result?r='
              + encodeURIComponent(eval(js))
              + _tab_id_,
              function () {});
  });
}, 750);

