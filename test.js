/*
var program = "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.";
var memory = [0];
var ptr = 0;
var stack = [];
for(var ip = 0; ip < program.length; ip++) {
	switch(program[ip]) {
		case "[":
			if(!memory[ptr]) {
				var nesting = 0;
				while(true) {
					if(program[ip] === '[') {
						++nesting;
					} else if(program[ip] === ']') {
						if(--nesting === 0) {
							break;
						}
					}
					++ip;
				}
			} else {
				stack.push(ip);
			}
			break;
		case "]":
			ip = stack.pop();
			continue;
		case ">":
			ptr++;
			memory[ptr] = memory[ptr] || 0;
			break;
		case "<":
			ptr--;
			memory[ptr] = memory[ptr] || 0;
			break;
		case "+":
			memory[ptr] += 1;
			break;
		case "-":
			memory[ptr] -= 1;
			break;
		case ".":
			console._print(String.fromCharCode(memory[ptr]));
			break;
	}
}
*/

function x() {
	try {
		throw 1;
	} catch(e) {
		throw "foo";
		return "fail";
	} finally {
		return "pass";
	}
}

console.log(x());