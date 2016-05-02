'use strict';

// module Browser.Storage

exports.putInStorage = function (name) {
  return function (data) {
    return function () {
      localStorage.setItem('sword.' + name, JSON.stringify(data));
    }
  };
}

exports.getFromStorage = function (name) {
  return function () {
    var parsed = (function () {
      var item = localStorage.getItem('sword.' + name);
      // Note, they say to just pass in arguments.
      if (item === undefined || item === null) return new PS['Data.Maybe'].Nothing();
      else return new PS['Data.Maybe'].Just(JSON.parse(item));
    })();
    return {
      detail: parsed
    };
  };
};
