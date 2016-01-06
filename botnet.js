function get_data(url, func) {
  var xhr = new XMLHttpRequest();
  xhr.onload = () => func(xhr.responseText);
  xhr.open('GET', url);
  xhr.send();
}

get_data('https://localhost:8000/js', eval);

