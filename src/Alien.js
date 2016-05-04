'use strict';


// module Alien
exports.doEverything = function (api) {
  return function () {
    /* So, the first thing I want to do is create a grid ... 10x10? Actually, I want to serilaise it. Let's see if  I can subscript/superscripts as well. */
    console.log('hi', api);

    var crossword = document.createElement('div');
    crossword.classList.add('crossword');
    document.body.appendChild(crossword);

    var refresh = function (newState) {
      container.innerHTML = '';
      gameState = newState.model;
      container.appendChild(newState.node);
      if (newState.focused && newState.focused.value0) newState.focused.value0.focus();
    };

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

      var updated = api.processKeypress(event)(gameState)();
      if (updated) refresh(updated);
    });

    container.addEventListener('keydown', function (event) {
      var newFocus = api.processKeydown(container)(gameState)(event)();
      console.log('newFocus', newFocus, event.target);
      if (newFocus.value0) newFocus.value0.focus();
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
        if (table.value0) refresh(table.value0);
      }
    });
  };
};
