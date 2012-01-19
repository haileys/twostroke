JSON = {
  stringify: function(obj) {
    switch(typeof obj) {
      case "string":
        return '"' + obj.replace(/["\\]/g, function(x) { return "\\" + x; }).replace(/[\x00-\x1F]/g, function(x) {
            if(x == "\n") return "\\n";
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
          return "[" + obj.map(function(x) { return JSON.stringify(x); }).filter(function(o) { return o !== undefined; }).join(",") + "]";
        } else {
          var keys = [];
          for(var k in obj) {
            if(obj.hasOwnProperty(k)) {
              keys.push(k);
            }
          }
          return "{" + keys.map(function(k) {
              var v = JSON.stringify(obj[k]);
              if(v) {
                return '"' + k + '":' + JSON.stringify(obj[k]);
              }
            }).filter(function(o) { return o !== undefined; }).join(",") + "}";
        }
      default:
        return undefined;
    }
  }
};