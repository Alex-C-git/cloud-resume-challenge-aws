// Javascript code for counter

const counter = document.querySelector(".counter-number");
async function updateCounter() {
    let response = await fetch("https://zn4xaqqmocl5b5f62gthtjpfyy0vqiky.lambda-url.us-east-1.on.aws/");
    let data = await response.json();
    counter.innerHTML = ` Views: ${data}`;
}

updateCounter();
