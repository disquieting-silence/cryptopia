'use strict'

// module Browser.Common

exports.createElement = function (tag) {
  return function (classes) {
    return function (content) {
      return function () {
        var node = document.createElement(tag);
        for (var i in classes) {
          node.classList.add(classes[i]);
        }
        node.innerHTML = content;
        return node;
      };
    };
  };
};
