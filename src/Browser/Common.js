'use strict'

// module Browser.Common

exports.createElement = function (tag) {
  return function (attributes) {
    return function (content) {
      return function () {
        var node = document.createElement(tag);
        for (var i in attributes) {
          var k = i;
          var v = attributes[i];
          node.setAttribute(k, v);
        }
        node.innerHTML = content;
        return node;
      };
    };
  };
};
