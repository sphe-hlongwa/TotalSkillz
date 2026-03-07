const { JSDOM } = require("jsdom");

const html = `
<div class="topic-grid" id="topicGrid">
    <div class="topic-chip" data-id="algebra" onclick="toggleTopic(this)">Algebra</div>
    <div class="topic-chip" data-id="patterns" onclick="toggleTopic(this)">Patterns</div>
    <div class="topic-chip" data-id="functions" onclick="toggleTopic(this)">Functions</div>
    <div class="topic-chip" data-id="finance" onclick="toggleTopic(this)">Finance</div>
</div>
`;

const dom = new JSDOM(html);
const document = dom.window.document;
let selectedTopics = [];

function toggleTopic(el) {
    const id = el.dataset.id;
    if (el.classList.contains('selected')) {
        el.classList.remove('selected');
        selectedTopics = selectedTopics.filter(t => t !== id);
    } else {
        if (selectedTopics.length >= 3) {
            // Flash the element to signal limit
            el.style.animation = 'none';
            el.style.border = '1.5px solid var(--accent-red)';
            setTimeout(() => el.style.border = '', 700);
            return;
        }
        el.classList.add('selected');
        selectedTopics.push(id);
    }
}

try {
    const chips = document.querySelectorAll('.topic-chip');
    toggleTopic(chips[0]);
    toggleTopic(chips[1]);
    toggleTopic(chips[2]);
    toggleTopic(chips[3]);
    console.log("Success. Selected topics: ", selectedTopics);
} catch (e) {
    console.error("Error: ", e);
}
