while(true) {
    (function(__ex) {
        console._print(">>> ");
        try {
            (function(result) {
                var ESC = String.fromCharCode(27);
                console._print(" => ");
                switch(typeof result) {
                case "string":
                    console._print(ESC + '[32m"' + result.replace(/"/g,'\\"') + '"');
                    break;
                case "number":
                    console._print(ESC + '[34;1m' + result);
                    break;
                case "boolean":
                    console._print(ESC + '[35m' + result );
                    break;
                case "undefined":
                    console._print(ESC + '[33mundefined');
                    break;
                default:
                    if(result === null) {
                        console._print(ESC + '[33mnull');
                    } else {
                        console._print(result);
                    }
                    break;
                }
                console._print(ESC + "[0m\n");
            })(eval(console._gets()));
        } catch(__ex) {
            (function() {
                var ESC = String.fromCharCode(27);
                console._print(ESC + "[37;41m!!!" + ESC + "[0m ");
                console.log(__ex);
            })();
        }
    })();
}