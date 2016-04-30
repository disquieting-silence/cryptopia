'use strict';

// module Alien
exports.doEverything = function () {
  /* So, the first thing I want to do is create a grid ... 10x10? Actually, I want to serilaise it. Let's see if  I can subscript/superscripts as well. */
  console.log('hi');

  var crossword = document.createElement('div');
  crossword.classList.add('crossword');
  document.body.appendChild(crossword);

  var NUM_ROWS = 15;
  var NUM_COLS = 15;

  var container = document.querySelector('.crossword');
  var table = document.createElement('table');
  var tbody = document.createElement('tbody');

  var save = document.createElement('button');
  save.innerHTML = "Save";
  save.classList.add('save');
  document.body.appendChild(save);

  var restore = document.createElement('button');
  restore.innerHTML = "Restore";
  restore.classList.add('restore');
  document.body.appendChild(restore);

  for (var r = 0; r < NUM_ROWS; r++) {
    var tr = document.createElement('tr');
    tbody.appendChild(tr);
    for (var c = 0; c < NUM_COLS; c++) {
      var td = document.createElement('td');
      var clazz = 'black';
      td.setAttribute('tabindex', '-1');
      td.classList.add(clazz);
      var num = document.createElement('span');
      num.classList.add('num');
	    td.appendChild(num);
      num.innerHTML = '10';

	    var square = document.createElement('span');
	    square.classList.add('square');
	    td.appendChild(square);
      square.innerHTML = 'C';
      tr.appendChild(td);
    }
  }

  table.appendChild(tbody);
  container.appendChild(table);


  // Keypress listeners for adding characters
  table.addEventListener('keypress', function (event) {
    var ch = event.which;
    console.log('ch', ch, event.target, event);
    if (event.target !== null && event.target.nodeName.toLowerCase() === 'td') {
      if (ch === 32) event.target.setAttribute('class', 'black');
      else {
        event.target.setAttribute('class', 'open');
        event.target.querySelector('.square').innerHTML = String.fromCharCode(ch).toUpperCase();
      }
    }
  });

  table.addEventListener('keydown', function (event) {
    if (event.target !== null && event.target.nodeName.toLowerCase() === 'td') {
      // current index in row
      var column = Array.prototype.indexOf.call(event.target.parentNode.childNodes, event.target);
      var row = Array.prototype.indexOf.call(event.target.parentNode.parentNode.childNodes, event.target.parentNode);

      var delta = (function () {
        if (event.which === 37) return { x: -1, y: 0 };
        else if (event.which === 39) return { x: +1, y: 0 };
        else if (event.which === 38) return { x: 0, y: -1 };
        else if (event.which === 40) return { x: 0, y: +1 };
        else return { x: 0, y: 0 };
      })();

      var nextRow = ((row + delta.y) + NUM_ROWS) % NUM_ROWS;
      var nextCol = ((column + delta.x) + NUM_COLS) % NUM_COLS;

      table.querySelectorAll('tr')[nextRow].querySelectorAll('td')[nextCol].focus();

      console.log('event', row, column);
    }
  });


  var serialize = function () {
    var data = Array.prototype.map.call(table.querySelectorAll('tr'), function (row) {
      return Array.prototype.map.call(row.querySelectorAll('td'), function (cell) {
        if (cell.classList.contains('black')) return '*';
        else return cell.querySelector('.square').innerHTML;
      });

    });

    console.log('data', data);
    return data;
  };

  var deserialize = function (data) {
    var cells = table.querySelectorAll('td');
    for (var r = 0; r < data.length; r++) {
      for (var c = 0; c < data[r].length; c++) {
        var index = r * NUM_COLS + c;
        var val = data[r][c];
        if (val === '*') cells[index].setAttribute('class', 'black');
        else {
          cells[index].setAttribute('class', 'open');
          cells[index].querySelector('.square').innerHTML = val;
        }
      }
    }
  };

  window.serialize = serialize;
  window.deserialize = deserialize;

  document.querySelector('.save').addEventListener('click', function () {
    var data = serialize();
    var file = prompt('Save as');
    if (file !== null && file !== undefined && file.length > 0) {
      localStorage.setItem('sword.' + file, JSON.stringify(data));
    }
  });

  document.querySelector('.restore').addEventListener('click', function () {
    var file = prompt('Restore');
    if (file !== null && file !== undefined) {
      var item = localStorage.getItem('sword.' + file);
      if (item !== null) deserialize(JSON.parse(item));
    }
  });
};
