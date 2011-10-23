var program = "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.";
var memory = [0];
var ptr = 0;
var stack = [];
var ip = 0;
while(ip < program.length) {
	if(program[ip] === '[') {
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
	} else if(program[ip] === ']') {
		ip = stack.pop();
		continue;
	} else if(program[ip] === '>') {
		++ptr;
		memory[ptr] = memory[ptr] || 0;
	} else if(program[ip] === '<') {
		--ptr;
		memory[ptr] = memory[ptr] || 0;
	} else if(program[ip] === '+') {
		memory[ptr] += 1;
	} else if(program[ip] === '-') {
		memory[ptr] -= 1;
	} else if(program[ip] === '.') {
		console._print(String.fromCharCode(memory[ptr]));
	}
	++ip;
}

