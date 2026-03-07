const fs = require('fs');
const path = require('path');

const publicDir = 'c:/Users/Wits student/OneDrive/Desktop/prac/MathGrade12/public';

function getFiles(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(file => {
        file = path.join(dir, file);
        const stat = fs.statSync(file);
        if (stat && stat.isDirectory()) {
            results = results.concat(getFiles(file));
        } else {
            if (file.endsWith('.html') && !file.includes('index.html')) {
                results.push(file);
            }
        }
    });
    return results;
}

const htmlFiles = getFiles(publicDir);

const desktopNavHTML = `
            <div class="header__center">
                <nav class="header__nav">
                    <a href="practice.html" class="header__nav-link">
                        <i class="fa-solid fa-dumbbell"></i>
                        <span>Practice</span>
                    </a>
                    <a href="topics.html" class="header__nav-link">
                        <i class="fa-solid fa-book-open"></i>
                        <span>Topics</span>
                    </a>
                    <a href="exam.html" class="header__nav-link">
                        <i class="fa-solid fa-stopwatch"></i>
                        <span>Exam Mode</span>
                    </a>
                </nav>
            </div>`;

let modifiedCount = 0;

htmlFiles.forEach(file => {
    let content = fs.readFileSync(file, 'utf8');

    // If header__center already exists, skip or replace.
    if (content.includes('header__center')) return;

    // We want to insert desktopNavHTML between header__left and header__right.
    // Standard structure:
    // <header class="header">
    //     <div class="header__left">...</div>
    //     --INSERT HERE--
    //     <div class="header__right">...</div>
    // </header>

    const insertRegex = /<\/div>\s*(?=<div class="header__right">)/i;

    if (insertRegex.test(content)) {
        content = content.replace(insertRegex, `</div>\n${desktopNavHTML}\n`);
        fs.writeFileSync(file, content, 'utf8');
        console.log('Injected desktop nav into:', file);
        modifiedCount++;
    }
});

console.log('Total files updated with desktop nav:', modifiedCount);
