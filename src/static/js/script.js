function typePerLetter(selector, speed = 100) {
	const el = document.querySelector(selector);
	if (!el) return;

	const text = el.textContent;
	el.textContent = "";
	let i = 0;

	const interval = setInterval(() => {
		if (i >= text.length) {
			clearInterval(interval);
			return;
		}

		const char = text[i];
		if (char === "\n") {
			el.appendChild(document.createElement("br"));
		} else {
			el.append(char);
		}
		i++;
	}, speed);
}

typePerLetter(".pi66-title", 120);
document.body.style.zoom = "100%";
