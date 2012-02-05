// this presentation expects a 110x30 terminal

function Presentation() {
	this.slides = [];
}
Presentation.prototype.clearScreen = function() {
	console._print("\033[H\033[2J");
};
Presentation.prototype.addSlide = function(slide) {
    if(slide.length) {
        for(var i = 0; i < slide.length; i++) {
            this.slides.push(slide[i]);
        }
    } else {
        this.slides.push(slide);
    }
};
Presentation.prototype.showSlide = function(slide) {
    this.clearScreen();
	slide.render(this);
	console._print("\033[30;110H");
};
Presentation.prototype.present = function() {
    this.currentSlide = 0;
    this.resume();
};
Presentation.prototype.resume = function() {
    for(; this.currentSlide < this.slides.length; this.currentSlide++) {
        this.showSlide(this.slides[this.currentSlide]);
        var input = console._gets();
        if(input === "\n" && this.slides[this.currentSlide].breakToRepl) {
            this.currentSlide++;
            break;
        } else if(input === "b\n") {
            this.currentSlide -= 2; // subtract two to compensate for `this.currentSlide++`
        }
    }
    this.clearScreen();
};

function FirstSlide() { }
FirstSlide.prototype.render = function(presentation) {
    var banner =
    '                                                                                                              \n' +
    '                                                                                                              \n' +
    '                    #       #     #   #####   #####   #       #####   #####   #  #   #####                    \n' +
    '                    ####    #  #  #   #   #   #       ####    #       #   #   #  #   #   #                    \n' +
    '                    #       #  #  #   #   #   #####   #       #       #   #   ###    #####                    \n' +
    '                    #       #  #  #   #   #       #   #       #       #   #   #  #   #                        \n' +
    '                    #####   #######   #####   #####   #####   #       #####   #  #   #####                    \n' +
    '                                                                                                              \n' +
    '                                                                                                              \n';
    var author = 
    "                                              Charlie Somerville                                              ";
    
    console._print("\n\n\n\n\n\n\n\n");
    console._print("\033[37;44m" + banner.replace(/#/g, "\033[34;47m \033[37;44m") + "\033[0m");
    console._print("\n\n\n\n");
    console._print(author);
};

function Slide(title) {
    this.title = title;
}
Slide.createWithBulletPoints = function(title, bulletPoints, opts) {
    var slides = [];
    opts = opts || {};
    for(var i = 0; i <= bulletPoints.length; i++) {
        (function(i) {
            var slide = new Slide(title);
            slide.onRender = function() {
                for(var j = 0; j < i; j++) {
                    this.renderBulletPoint(bulletPoints[j]);
                }
            };
            slides.push(slide);
        })(i);
    }
    if(opts.breakToRepl) {
        slides[slides.length - 1].breakToRepl = true;
    }
    return slides;
}
Slide.prototype.renderTitle = function() {
    console._print("\033[37;44m" + Array(111).join(" ") + "\n");
    console._print("   \033[4m" + this.title + "\033[0m\033[37;44m" + Array(111 - 3 - this.title.length).join(" ") + "\n");
    console._print(Array(111).join(" ") + "\n\033[0m\n\n");
};
Slide.prototype.renderBulletPoint = function(text) {
    var words = text.split(" ");
    var lineLength = 110 - 8;
    var curLineLength = 0;
    console._print("   \033[34m•\033[0m ");
    for(var i = 0; i < words.length; i++) {
        if(curLineLength + words[i].length > lineLength) {
            curLineLength = 0;
            console._print("\n     ");
        }
        console._print(words[i] + " ");
        curLineLength += words[i].length + 1;
    }
    console._print("\n\n");
};
Slide.prototype.render = function(presentation) {
    this.renderTitle(this.title);
    if(typeof this.onRender === "function") {
        this.onRender(presentation);
    }
}

function TextSlide(title, text) {
    this.title = title;
    this.text = text;
}
TextSlide.prototype = new Slide();
TextSlide.prototype.onRender = function() {
    this.text.split("\n").forEach(function(line) {
        console._print("     " + line + "\n");
    });
};
var presentation = new Presentation();
presentation.addSlide(new FirstSlide());
[
    [
        "What is Twostroke?",
        [   "A Javascript implementation"
        ,   "...written in Ruby"
        ,   "...that works fairly well!"
        ]
    ],
    [
        "Why is Twostroke useful?",
        [   "Rapid prototyping of language extensions"
        ,   "Pure Ruby - no C extensions required"
        ,   "As a learning tool"
        ]
    ],
    [
        "What can Twostoke do?",
        [   "Pass all the underscore.js tests which don't rely on the DOM"
        ,   "Run the CoffeeScript compiler"
        ,   "Run the LESS.js compiler"
        ,   "Pass most Mootools core tests"
        ]
    ]
].forEach(function(slide) {
    presentation.addSlide(Slide.createWithBulletPoints.apply(Slide, slide));
});

presentation.addSlide(new Slide("How Twostroke works - a simple 'Hello World' example"));
presentation.addSlide(new TextSlide("How Twostroke works - a simple 'Hello World' example",
    "console.log(\033[32m\033[1;32m\"\033[0m\033[32mHello World!\033[1;32m\"\033[0m\033[32m\033[0m);"
));
presentation.addSlide(new TextSlide("How Twostroke works - a simple 'Hello World' example",
    "[#<\033[31mTwostroke::AST::Call\033(B\033[m\n  \033[36m@callee\033(B\033[m=\n   #<\033[31mTwostroke::AST::MemberAccess\033(B\033[m\n    \033[36m@member\033(B\033[m=\033[32m\"log\"\033(B\033[m,\n    \033[36m@object\033(B\033[m=\n     #<\033[31mTwostroke::AST::Variable\033(B\033[m \033[36m@name\033(B\033[m=\033[32m\"console\"\033(B\033[m>>,\n  \033[36m@arguments\033(B\033[m=\n   [#<\033[31mTwostroke::AST::String\033(B\033[m\n     \033[36m@string\033(B\033[m=\033[32m\"Hello World!\"\033(B\033[m>]>]\n"
));
presentation.addSlide(new TextSlide("How Twostroke works - a simple 'Hello World' example",
    '\033[4mTwostroke:\033[0m                                     \033[4mMozilla Spidermonkey:\033[0m\n\n' + 
    'main:                                          main:\n' +
    '   \033[38;5;241m0\033[m    \033[36m.line\033[0m      \033[33m1\033[0m                           \033[38;5;241m00000:\033[m  \033[36mgetgname\033[m  \033[32m"console"\033[m\n' +
    '   \033[38;5;241m1\033[m    \033[36mpush\033[0m       \033[1;31mconsole\033[0m                     \033[38;5;241m00003:\033[m  \033[36mcallprop\033[m  \033[32m"log"\033[m\n' +
    '   \033[38;5;241m2\033[m    \033[36mpush\033[0m       \033[32m"log"\033[0m                       \033[38;5;241m00006:\033[m  \033[36mstring\033[m    \033[32m"Hello World"\033[m\n' +
    '   \033[38;5;241m3\033[m    \033[36mpush\033[0m       \033[32m"Hello World!"\033[0m              \033[38;5;241m00009:\033[m  \033[36mcall\033[m      \033[33m1\033[0m\n' +
    '   \033[38;5;241m4\033[m    \033[36mmethcall\033[0m   \033[33m1\033[0m                           \033[38;5;241m00012:\033[m  \033[36mpop\033[m\n' +
    '   \033[38;5;241m5\033[m    \033[36mundefined\033[0m                              \033[38;5;241m00013:\033[m  \033[36mstop\033[m\n' +
    '   \033[38;5;241m6\033[m    \033[36mret\033[0m\n'
));


presentation.addSlide(new Slide("How Twostroke works - a more realistic example"));
presentation.addSlide(new TextSlide("How Twostroke works - a more realistic example",
    "[\033[1;34m1\033[0m,\033[1;34m2\033[0m,\033[1;34m3\033[0m].map(\033[1;31mfunction\033[0m(x) {\n\t\033[1;31mreturn\033[0m x * x;\n});\n"
));
presentation.addSlide(new TextSlide("How Twostroke works - a more realistic example",
    "[#<\033[31mTwostroke::AST::Call\033(B\033[m\n  \033[36m@arguments\033(B\033[m=\n   [#<\033[31mTwostroke::AST::Function\033(B\033[m\n     \033[36m@arguments\033(B\033[m=[\033[32m\"x\"\033(B\033[m],\n     \033[36m@as_expression\033(B\033[m=true,\n     \033[36m@statements\033(B\033[m=\n      [#<\033[31mTwostroke::AST::Return\033(B\033[m\n        \033[36m@expression\033(B\033[m=\n         #<\033[31mTwostroke::AST::Multiplication\033(B\033[m\n          \033[36m@assign_result_left\033(B\033[m=false,\n          \033[36m@left\033(B\033[m=#<\033[31mTwostroke::AST::Variable\033(B\033[m \033[36m@name\033(B\033[m=\033[32m\"x\"\033(B\033[m>,\n          \033[36m@right\033(B\033[m=#<\033[31mTwostroke::AST::Variable\033(B\033[m \033[36m@name\033(B\033[m=\033[32m\"x\"\033(B\033[m>>>]>],\n  \033[36m@callee\033(B\033[m=\n   #<\033[31mTwostroke::AST::MemberAccess\033(B\033[m\n    \033[36m@member\033(B\033[m=\033[32m\"map\"\033(B\033[m,\n    \033[36m@object\033(B\033[m=\n     #<\033[31mTwostroke::AST::Array\033(B\033[m\n      \033[36m@items\033(B\033[m=\n       [#<\033[31mTwostroke::AST::Number\033(B\033[m \033[36m@number\033(B\033[m=\033[33m1\033(B\033[m>,\n        #<\033[31mTwostroke::AST::Number\033(B\033[m \033[36m@number\033(B\033[m=\033[33m2\033(B\033[m>,\n        #<\033[31mTwostroke::AST::Number\033(B\033[m \033[36m@number\033(B\033[m=\033[33m3\033(B\033[m>]>>>]\n"
));
presentation.addSlide(new TextSlide("How Twostroke works - a more realistic example",
    'main:\n' +
    '   \033[38;5;241m0\033[m    \033[36m.line\033[0m       \033[33m1\033[0m\n' +
    '   \033[38;5;241m1\033[m    \033[36mpush\033[0m        \033[33m1\033[0m\n' +
    '   \033[38;5;241m2\033[m    \033[36mpush\033[0m        \033[33m2\033[0m\n' +
    '   \033[38;5;241m3\033[m    \033[36mpush\033[0m        \033[33m3\033[0m\n' +
    '   \033[38;5;241m4\033[m    \033[36marray\033[0m       \033[33m3\033[0m\n' +
    '   \033[38;5;241m5\033[m    \033[36mpush\033[0m        \033[32m"map"\033[0m\n' +
    '   \033[38;5;241m6\033[m    \033[36mclose\033[0m       \033[1;31mfn_1\033[0m\n' +
    '   \033[38;5;241m7\033[m    \033[36mmethcall\033[0m    \033[33m1\033[0m\n' +
    '   \033[38;5;241m8\033[m    \033[36mundefined\033[0m   \n' +
    '   \033[38;5;241m9\033[m    \033[36mret\033[0m         \n' +
    'fn_1:\n' +
    '   \033[38;5;241m0\033[m    \033[36m.arg\033[0m        \033[1;31mx\033[0m\n' +
    '   \033[38;5;241m1\033[m    \033[36m.line\033[0m       \033[33m2\033[0m\n' +
    '   \033[38;5;241m2\033[m    \033[36mpush\033[0m        \033[1;31mx\033[0m\n' +
    '   \033[38;5;241m3\033[m    \033[36mpush\033[0m        \033[1;31mx\033[0m\n' +
    '   \033[38;5;241m4\033[m    \033[36mmul\033[0m         \n' +
    '   \033[38;5;241m5\033[m    \033[36mret\033[0m         \n' +
    '   \033[38;5;241m6\033[m    \033[36mundefined\033[0m   \n' +
    '   \033[38;5;241m7\033[m    \033[36mret\033[0m'
));

presentation.present();