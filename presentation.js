// this presentation expects a 110x25 terminal

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
	console._print("\033[25;110H");
};
Presentation.prototype.present = function() {
    for(var i = 0; i < this.slides.length; i++) {
        this.showSlide(this.slides[i]);
        console._gets();
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
    
    console._print("\n\n\n\n\n");
    console._print("\033[37;44m" + banner.replace(/#/g, "\033[34;47m \033[37;44m") + "\033[0m");
    console._print("\n\n\n\n");
    console._print(author);
};

function Slide(title) {
    this.title = title;
}
Slide.createWithBulletPoints = function(title, bulletPoints) {
    var slides = [];
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
        this.onRender();
    }
}

var presentation = new Presentation();
presentation.addSlide(new FirstSlide());
presentation.addSlide(Slide.createWithBulletPoints(
    "What is Twostroke?",
    [   "A Javascript implementation"
    ,   "...written in Ruby"
    ,   "...that works fairly well!"
    ]));
presentation.present();