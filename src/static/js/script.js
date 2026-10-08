function timeAgo(dateString) {
	const date = new Date(dateString.replace(" ", "T"));
	const now = new Date();
	const diff = now - date;

	const units = [
		["year", 365 * 24 * 60 * 60 * 1000],
		["month", 30 * 24 * 60 * 60 * 1000],
		["day", 24 * 60 * 60 * 1000],
		["hour", 60 * 60 * 1000],
		["minute", 60 * 1000],
		["second", 1000],
	];

	for (const [unit, ms] of units) {
		const value = Math.floor(diff / ms);

		if (value >= 1) {
			return `${value} ${unit}${value !== 1 ? "s" : ""} ago`;
		}
	}

	return "just now";
}

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
document.querySelectorAll(".time-ago").forEach(element => {
	element.textContent = timeAgo(element.textContent.trim());
});
