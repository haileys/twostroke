JSON = {
  stringify: function(obj) {
    switch(typeof obj) {
      case "string":
        return '"' + obj.replace(/["\\]/g, function(x) { return "\\" + x; }).replace(/[\x00-\x1F]/g, function(x) {
            var s = x.charCodeAt(0).toString(16);
            while(s.length < 4) s = "0" + s;
            return "\\u" + s;
          }) + '"';
      case "number":
      case "boolean":
        return obj.toString();
      case "undefined":
        return "null";
      case "object":
        if(obj === null) {
          return "null";
        } else if(obj instanceof Array) {
          return "[" + obj.map(function(x) { return JSON.stringify(x); }).join(",") + "]";
        } else {
          var keys = [];
          for(var k in obj) {
            keys.push(k);
          }
          return "{" + keys.map(function(k) { return '"' + k + '":' + JSON.stringify(obj[k]); }).join(",") + "}";
        }
    }
  }
};