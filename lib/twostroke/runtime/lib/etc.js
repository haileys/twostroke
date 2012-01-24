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
    },
    parse: function(str) {
        return new JSON.Parser(str).parse();
    }
};

JSON.Parser = function(str) {
    this.str = str;
    this.i = 0;
}

JSON.Parser.ParseError = function(message) {
    var self = new Error();
    self.name = "ParseError"
    self.message = message;
    return self;
};

JSON.Parser.prototype.tokens = [
    [ "OPEN_BRACE",     "{" ],
    [ "CLOSE_BRACE",    "}" ],
    [ "COLON",          ":" ],
    [ "COMMA",          "," ],
    [ "OPEN_BRACKET",   "[" ],
    [ "CLOSE_BRACKET",  "]" ],
    [ "TRUE",           "true" ],
    [ "FALSE",          "false" ],
    [ "NULL",           "null" ]
];

JSON.Parser.prototype.stringEscapes = {
    '"': '"',
    "\\": "\\",
    "/": "/",
    "b": "\b",
    "f": "\f",
    "n": "\n",
    "r": "\r",
    "t": "\t"
};

JSON.Parser.prototype.numberStates = {
    "start": {
        "-": "after_minus",
        "0": "int", "1": "int", "2": "int", "3": "int", "4": "int", "5": "int",
        "6": "int", "7": "int", "8": "int", "9": "int"
    },
    "after_minus": {
        "0": "int", "1": "int", "2": "int", "3": "int", "4": "int", "5": "int",
        "6": "int", "7": "int", "8": "int", "9": "int"
    },
    "int": {
        "0": "int", "1": "int", "2": "int", "3": "int", "4": "int", "5": "int",
        "6": "int", "7": "int", "8": "int", "9": "int", ".": "frac",
        "e": "exp", "E": "exp"
    },
    "frac": {
        "0": "frac", "1": "frac", "2": "frac", "3": "frac", "4": "frac",
        "5": "frac", "6": "frac", "7": "frac", "8": "frac", "9": "frac",
        "e": "exp", "E": "exp"
    },
    "exp": {
        "0": "expd", "1": "expd", "2": "expd", "3": "expd", "4": "expd",
        "5": "expd", "6": "expd", "7": "expd", "8": "expd", "9": "expd",
        "-": "expd", "+": "expd"
    },
    "expd": {
        "0": "expd", "1": "expd", "2": "expd", "3": "expd", "4": "expd",
        "5": "expd", "6": "expd", "7": "expd", "8": "expd", "9": "expd"
    }
};

JSON.Parser.prototype.read_token = function() {
    if(this.i >= this.str.length) {
        return ["END", ""];
    }
    if(/\s/.test(this.str[this.i])) {
        this.i++;
        return this.read_token();
    }
    if(this.str[this.i] === '"') {
        var str = "";
        this.i++;
        while(this.i < this.str.length && this.str[this.i] !== '"') {
            if(this.str[this.i] === "\\") {
                this.i++;
                if(this.stringEscapes[this.str[this.i]]) {
                    this.str += this.str[this.i];
                } else if(this.str[this.i] == "u") {
                    this.i++;
                    // need four chars for unicode escape
                    if(this.i + 4 >= this.str.length) {
                        throw new JSON.Parser.ParseError("unterminated string");
                    } else {
                        str += String.fromCharCode(parseInt(this.str.substr(this.i, 4), 16));
                        this.i += 4;
                    }
                } else {
                    throw new JSON.Parser.ParseError("unterminated string");
                }
            } else {
                str += this.str[this.i++];
            }
        }
        if(this.str[this.i++] != '"') {
            throw new JSON.Parser.ParseError("unterminated string");
        }
        return ["STRING", str];
    } else if(this.numberStates["start"][this.str[this.i]]) {
        var num = "";
        var state = this.numberStates["start"];
        while(this.i < this.str.length && state[this.str[this.i]]) {
            num += this.str[this.i];
            state = this.numberStates[state[this.str[this.i]]];
            this.i++;
        }
        return ["NUMBER", parseFloat(num)];
    }
    for(var i = 0; i < this.tokens.length; i++) {
        var pattern = this.tokens[i][1];
        if(typeof pattern === "string") {
            if(this.str.substr(this.i, pattern.length) === pattern) {
                this.i += pattern.length;
                return [this.tokens[i][0], pattern];
            }
        }
    }
    throw new JSON.Parser.ParseError("Illegal character '" + this.str[this.i] + "'");
};

JSON.Parser.prototype.next_token = function() {
    if(this._peek) {
        var p = this._peek;
        this._peek = null;
        return p;
    }
    return this.read_token();
};

JSON.Parser.prototype.peek_token = function() {
    if(!this._peek) {
        this._peek = this.next_token();
    }
    return this._peek;
};

JSON.Parser.prototype.expect_token = function() {
    var tok = this.next_token();
    for(var i = 0; i < arguments.length; i++) {
        if(tok[0] === arguments[i]) {
            return tok;
        }
    }
    throw new JSON.Parser.ParseError("Illegal token " + tok[0]);
};

JSON.Parser.prototype.parse = function() {
    var val = this.value();
    this.expect_token("END");
    return val;
};

JSON.Parser.prototype.value = function() {
    var type = this.peek_token()[0];
    switch(type) {
    case "OPEN_BRACE":      return this.object();
    case "OPEN_BRACKET":    return this.array();
    case "TRUE":            this.next_token(); return true;
    case "FALSE":           this.next_token(); return false;
    case "NULL":            this.next_token(); return null;
    case "STRING":
    case "NUMBER":          return this.next_token()[1];
    default:
        throw new JSON.Parser.ParseError("Illegal token " + type);
    }
};

JSON.Parser.prototype.string = function() {
    return this.expect_token("STRING")[1];
};

JSON.Parser.prototype.object = function() {
    this.expect_token("OPEN_BRACE");
    var obj = {};
    while(this.peek_token()[0] !== "CLOSE_BRACE") {
        var k = this.string();
        this.expect_token("COLON");
        obj[k] = this.value();
        var next = this.peek_token()[0];
        if(next == "COMMA") {
            this.next_token();
        } else if(next != "CLOSE_BRACE") {
            throw new JSON.Parser.ParseError("Illegal token " + type);
        }
    }
    this.expect_token("CLOSE_BRACE");
    return obj;
};

JSON.Parser.prototype.array = function() {
    this.expect_token("OPEN_BRACKET");
    var ary = [];
    while(this.peek_token()[0] !== "CLOSE_BRACKET") {
        ary.push(this.value());
        var next = this.peek_token()[0];
        if(next == "COMMA") {
            this.next_token();
        } else if(next != "CLOSE_BRACKET") {
            throw new JSON.Parser.ParseError("Illegal token " + type);
        }
    }
    this.expect_token("CLOSE_BRACKET");
    return ary;
};