'use strict'

// module Browser.Common

exports.createElement = function (tag) {
  return function (attributes) {
    return function (content) {
      return function () {
        var node = document.createElement(tag);
        for (var i in attributes) {
          node.setAttribute(attributes[i].key, attributes[i].value);
        }
        node.innerHTML = content;
        return node;
      };
    };
  };
};

exports.appendElement = function (parent) {
  return function (child) {
    return function () {
      parent.appendChild(child);
    };
  };
};


// Probably should deal with maybes
exports.readAttribute = function (node) {
  return function (attr) {
    return function () {
      return node.getAttribute(attr);
    };
  };
};

exports.getNodeName = function (node) {
  return function () {
    return node.nodeName;
  };
};

exports.querySelectorAll = function (node) {
  return function (selector) {
    return function () {
      return node.querySelectorAll(selector);
    };
  };
};
