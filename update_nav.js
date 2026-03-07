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
            if (file.endsWith('.html')) {
                results.push(file);
            }
        }
    });
    return results;
}

const htmlFiles = getFiles(publicDir);

let modifiedCount = 0;

htmlFiles.forEach(file => {
    let content = fs.readFileSync(file, 'utf8');
    let original = content;

    // Specifically target nav items in the sidebar.
    // They look like: <a href="/practice.html" class="nav-item" ...> ... <span class="nav-label">Practice</span> </a>
    // We can use a regex that strictly requires 'class="nav-item' or similar.

    // Remove Practice nav-item
    content = content.replace(/<a[^>]*href="[^"]*practice\.html"[^>]*class="[^"]*nav-item[^"]*"[^>]*>[\s\S]*?<\/a>\s*/gi, '');

    // Remove Topics nav-item
    content = content.replace(/<a[^>]*href="[^"]*topics\.html"[^>]*class="[^"]*nav-item[^"]*"[^>]*>[\s\S]*?<\/a>\s*/gi, '');

    if (content !== original) {
        fs.writeFileSync(file, content, 'utf8');
        console.log('Updated:', file);
        modifiedCount++;
    }
});

console.log('Total files modified:', modifiedCount);
