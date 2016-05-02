'use strict';


// module Alien
exports.doEverything = function (api) {
  return function () {
    /* So, the first thing I want to do is create a grid ... 10x10? Actually, I want to serilaise it. Let's see if  I can subscript/superscripts as well. */
    console.log('hi', api);

    var crossword = document.createElement('div');
    crossword.classList.add('crossword');
    document.body.appendChild(crossword);

    var NUM_ROWS = 15;
    var NUM_COLS = 15;

    var container = document.querySelector('.crossword');

    var save = document.createElement('button');
    save.innerHTML = "Save";
    save.classList.add('save');
    document.body.appendChild(save);

    var restore = document.createElement('button');
    restore.innerHTML = "Restore";
    restore.classList.add('restore');
    document.body.appendChild(restore);

    var gameState = api.createGrid({ width: 5, height: 5 });
    var table = api.renderGrid(gameState)();
    container.appendChild(table);

    container.addEventListener('keypress', function (event) {
      var ch = event.which;
      console.log('ch', ch, event.target, event);
      if (event.target !== null && event.target.nodeName.toLowerCase() === 'td') {
        if (ch === 32) event.target.setAttribute('class', 'black');
        else {
          api.updateGrid(gameState, event.target, String.fromCharCode(ch).toUpperCase());
          // event.target.setAttribute('class', 'open');
          //
          // event.target.querySelector('.square').innerHTML = String.fromCharCode(ch).toUpperCase();
        }
      }
    });

    container.addEventListener('keydown', function (event) {
      if (event.target !== null && event.target.nodeName.toLowerCase() === 'td') {
        // current index in row
        var column = Array.prototype.indexOf.call(event.target.parentNode.childNodes, event.target);
        var row = Array.prototype.indexOf.call(event.target.parentNode.parentNode.childNodes, event.target.parentNode);

        var nextPosition = api.getNextPosition({ x: column, y: row })(event)({ width: NUM_COLS, height: NUM_ROWS });
        document.querySelector('.crossword').querySelectorAll('tr')[nextPosition.y].querySelectorAll('td')[nextPosition.x].focus();

        console.log('event', row, column);
      }
    });

    document.querySelector('.save').addEventListener('click', function () {
      var file = prompt('Save as');
      if (file !== null && file !== undefined && file.length > 0) {
        api.save(file)(gameState)();
      }
    });

    document.querySelector('.restore').addEventListener('click', function () {
      var file = prompt('Restore');
      if (file !== null && file !== undefined) {
        var table = api.load(file)();

        // Breaking abstraction
        if (table.value0) {
          document.querySelector('.crossword').innerHTML = '';
          document.querySelector('.crossword').appendChild(table.value0.node);
          gameState = table.value0.model;
        }
      }
    });
  };
};
