'use strict';

// module Browser.Storage

exports.putInStorage = function (name) {
  return function (data) {
    return function () {
      localStorage.setItem('cryptopia.' + name, JSON.stringify(data));
    }
  };
}

exports.getFromStorage = function (name) {
  return function () {
    var item = localStorage.getItem('cryptopia.' + name);
    // Note, they say to just pass in arguments.
    if (item === undefined || item === null) return PS['Data.Maybe'].Nothing.create();
    else return PS['Data.Maybe'].Just.create(JSON.parse(item));
  };
};
